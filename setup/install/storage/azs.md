---
layout: single
title:  "Azure Storage"
sidebar:
  nav: setup
redirect_from: /setup/storage/azs/
---

{% include toc %}

Using [Azure Storage](https://azure.microsoft.com/services/storage/) (AZS) as a
storage source means that Spinnaker will store all of its persistent data in a
[Storage Account](https://docs.microsoft.com/azure/storage/storage-create-storage-account).

## Prerequisites

The next steps assume the use of the [Azure CLI 2.0](https://docs.microsoft.com/cli/azure/install-azure-cli) in order to create a Storage Account. You can check that you have `az` installed by running:

```bash
az --version
```

First, log in and set your subscription:

```bash
az login
az account list
az account set --subscription <Insert Subscription ID>
```

Next, create a resource group for your Storage Account. Make sure to specify a location (e.g. westus) available in your account:

```bash
az account list-locations --query [].name
RESOURCE_GROUP="SpinnakerStorage"
az group create --name $RESOURCE_GROUP --location <Insert Location>
```

Finally, create your storage account, using a globally unique name:

```bash
STORAGE_ACCOUNT_NAME=<Insert name>
az storage account create --resource-group $RESOURCE_GROUP --sku STANDARD_LRS --name $STORAGE_ACCOUNT_NAME
STORAGE_ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT_NAME --query [0].value | tr -d '"')
```

## Editing Your Storage Settings

First, edit the storage settings:

```bash
hal config storage azs edit \
  --storage-account-name $STORAGE_ACCOUNT_NAME \
  --storage-account-key $STORAGE_ACCOUNT_KEY
```

There are more options described [here](/reference/halyard/commands#hal-config-storage-azs-edit) if you need more control over your configuration.

Finally, set the storage source to AZS:

```bash
hal config storage edit --type azs
```
