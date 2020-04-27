---
layout: single
title:  "Configuring Oracle Object Storage Artifact Credentials"
sidebar:
  nav: setup
---

{% include toc %}

Spinnaker stages that read data from artifacts can consume
[Oracle Object Storage](https://docs.cloud.oracle.com/iaas/Content/Object/Concepts/objectstorageoverview.htm){:target="\_blank"} objects as artifacts.

## Prerequisites

If you have enabled [Oracle Cloud provider](/setup/install/providers/oracle/) in Spinnaker, you may use the same region, Tenancy’s OCID, user’s OCID, private key file, and fingerprint to enable Oracle Object Storage Artifact. You will need the following to enable Oracle Object Storage Artifact in Spinnaker:

* A user in IAM for the person or system who will be using Spinnaker, and that user must be granted access to Object Storage or in one IAM group with permissions of Object Storage.

   See [Adding Users](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/addingusers.htm){:target="\_blank"}, and [Object Storage Policy](https://docs.cloud.oracle.com/iaas/Content/Identity/Reference/objectstoragepolicyreference.htm){:target="\_blank"}

* The user's home region. 

   See [Managing Regions](https://docs.cloud.oracle.com/iaas/Content/Identity/Tasks/managingregions.htm){:target="\_blank"}. 
   (e.g. `--region us-ashburn-1`)
   
* RSA key pair in PEM format (minimum 2048 bits).
   
   See [How to Generate an API Signing Key](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#How){:target="\_blank"}. 
   (e.g. `--ssh-private-key-file-path /home/ubuntu/.oci/myPrivateKey.pem`)
   
* Fingerprint of the public key. 

   See [How to Get the Key's Fingerprint](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#How3){:target="\_blank"}. 
   (e.g. `--fingerprint 11:22:33:..:aa`)
   
* Tenancy's OCID and user's OCID.

   See [Where to Get the Tenancy's OCID and User's OCID](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#Other){:target="\_blank"}. 
   (e.g. `--tenancyId ocid1.tenancy.oc1..aa... --user-id ocid1.user.oc1..aa...`)
   
* Upload the public key from the key pair in the Console. 
   
   See [How to Upload the Public Key](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#How2){:target="\_blank"}.
   
* Namespace: this is your Tenancy name. On Oracle Cloud Console, click on the user menu. The Tenancy name is next to your user name. 

   See [Object Storage Namespaces](https://docs.cloud.oracle.com/iaas/Content/Object/Tasks/understandingnamespaces.htm){:target="\_blank"}, and [Managing Compartments](https://docs.cloud.oracle.com/iaas/Content/Identity/Tasks/managingcompartments.htm){:target="\_blank"}. 
   (e.g. `--namespace my-tenancy`)
   
## Add Oracle Object Storage Artifact to Spinnaker

First, enable [artifact support](/reference/artifacts-with-artifactsrewrite//#enabling-artifact-support).

Next, add an artifact account:

```bash
hal config artifact oracle account add $ARTIFACT_ACCOUNT_NAME \
    --namespace $TENANCY_NAME \
    --fingerprint $API_KEY_FINGERPRINT \
    --region $REGION \
    --ssh-private-key-file-path $PRIVATE_KEY_FILE \
    --tenancy-id $TENANCY_OCID \
    --user-id $USER_OCID   
```

And enable Oracle Object Storage artifact support:

```bash
hal config artifact oracle enable
```

There are more options described
[here](/reference/halyard/commands#hal-config-artifact-oracle-account-edit)
if you need more control over your configuration.
