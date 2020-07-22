---
layout: single
title:  "Azure"
sidebar:
  nav: setup
redirect_from: /setup/providers/azure/
---

{% include toc %}

In [Azure](https://azure.microsoft.com/){:target="\_blank"}, an
[__Account__](/concepts/providers/#accounts) maps to a credential able to
authenticate against a given [Azure subscription](https://azure.microsoft.com/free/){:target="\_blank"}.

## Prerequisites

You need a [Service Principal](https://docs.microsoft.com/cli/azure/create-an-azure-service-principal-azure-cli){:target="\_blank"}
to authenticate with Azure and a [Key Vault](https://azure.microsoft.com/services/key-vault/){:target="\_blank"}
to store a default username/ssh public key for deployed [VM Scale Sets](https://docs.microsoft.com/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-overview){:target="\_blank"}.
The next steps assume the use of the [Azure CLI 2.0](https://docs.microsoft.com/cli/azure/install-azure-cli){:target="\_blank"}.
The example commands will set environment variables along the way for use when
creating an account in the final stage. You can check that you have `az` installed by running:

```bash
az --version
```

First, log in and set your subscription:

```bash
az login
az account list
SUBSCRIPTION_ID=<Insert Subscription ID>
az account set --subscription $SUBSCRIPTION_ID
```

Next, create a Service Principal (where the name is unique in your subscription) and set environment variables based on the output:

```bash
az ad sp create-for-rbac --name "Spinnaker"
APP_ID=<Insert App Id>
TENANT_ID=<Insert Tenant Id>
```

> NOTE: You will need the App Key (also called password) when creating an account, but you will be prompted on standard input for that since it is sensitive data.

Next, create a resource group for your Key Vault. Make sure to specify a location (e.g. westus) available in your account:

```bash
az account list-locations --query [].name
RESOURCE_GROUP="Spinnaker"
az group create --name $RESOURCE_GROUP --location <Insert Location>
```

Finally, create a Key Vault (where the vault name is globally unique) and add a default username/ssh public key. This credential is used to provision all Azure VM scale sets by default. You can log on to VM instances in VM scale sets with this credential.

```bash
VAULT_NAME=<Insert Vault Name>
az keyvault create --enabled-for-template-deployment true --resource-group $RESOURCE_GROUP --name $VAULT_NAME
az keyvault set-policy --secret-permissions get --name $VAULT_NAME --spn $APP_ID
az keyvault secret set --name VMUsername --vault-name $VAULT_NAME --value <Insert default username>
az keyvault secret set --name VMSshPublicKey --vault-name $VAULT_NAME --value <Insert default SSH public key>
```

If you prefer to use password instead of SSH public key, then replace
```bash
az keyvault secret set --name VMSshPublicKey --vault-name $VAULT_NAME --value <Insert default SSH public key>
```
with
```bash
az keyvault secret set --name VMPassword --vault-name $VAULT_NAME --value <Insert default password>
```
Follow the Azure VM username and password rules documented [here](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-username-requirements-when-creating-a-vm){:target="\_blank"}.

## Adding an account

First, make sure the provider is enabled:

```bash
hal config provider azure enable
```

Next, run the following `hal` command to add an account named `my-azure-account` to your list of Azure accounts:

```bash
hal config provider azure account add my-azure-account \
  --client-id $APP_ID \
  --tenant-id $TENANT_ID \
  --subscription-id $SUBSCRIPTION_ID \
  --default-key-vault $VAULT_NAME \
  --default-resource-group $RESOURCE_GROUP \
  --packer-resource-group $RESOURCE_GROUP \
  --app-key
```

> NOTE:
> 1. You will be prompted for the App Key on standard input. If necessary,
you can generate a new key: `az ad sp credential reset --name $APP_ID`
> 2. Starting from Halyard v1.19, SSH public key will be used to provision VM scale set by default. If you prefer to use password, add the parameter\
`--useSshPublicKey "false" \`\
Prior to Halyard v1.19, the default credential option is password and halyard does not support the above parameter to switch the option to SSH public key.\
Secret values of either the SSH public key or password are stored in the Azure key vault specified by the parameter `--default-key-vault`, in which the stored secret names are called "VMPassword" and "VMSshPublicKey", separately.
> 3. The Azure regions used by default are "eastus" and "westus". If you would like to add custom regions, add the parameter\
`--regions <input regions seperated by comma without quotation marks> \`

## Advanced account settings

You can view the available configuration flags for Azure within the
[Halyard reference](/reference/halyard/commands#hal-config-provider-azure-account-add).

## Next steps

Optionally, you can [set up another cloud provider](/setup/install/providers/),
but otherwise you're ready to [choose an environment](/setup/install/environment/)
in which to install Spinnaker.
