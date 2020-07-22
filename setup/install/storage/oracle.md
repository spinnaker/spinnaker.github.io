---
layout: single
title:  "Oracle Cloud Infrastructure Object Storage"
sidebar:
  nav: setup
---

Using [Oracle Object Storage](https://docs.cloud.oracle.com/iaas/Content/Object/Concepts/objectstorageoverview.htm){:target="\_blank"} as a storage source means that Spinnaker will store all of its persistent data in a
[Bucket](https://docs.cloud.oracle.com/iaas/Content/Object/Tasks/managingbuckets.htm){:target="\_blank"}.

## Prerequisites

If you have enabled [Oracle Cloud provider](/setup/install/providers/oracle/) in Spinnaker, you may use the same region, Tenancy’s OCID, user’s OCID, Compartment's OCID, private key file, and fingerprint to enable Oracle Object Storage. You will need the following to enable Oracle Object Storage in Spinnaker:

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
   
* Compartment OCID: On Oracle Cloud Console, open the navigation menu. Under Governance and Administration, go to Identity and click Compartments. 
   
   See [Managing Compartments](https://docs.cloud.oracle.com/iaas/Content/Identity/Tasks/managingcompartments.htm){:target="\_blank"}. 
   (e.g. `--compartment-id ocid1.compartment.oc1..aa...`)
   
* Upload the public key from the key pair in the Console. 
   
   See [How to Upload the Public Key](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#How2){:target="\_blank"}.
   
* Namespace: this is your Tenancy name. On Oracle Cloud Console, click on the user menu. The Tenancy name is next to your user name. 

   See [Object Storage Namespaces](https://docs.cloud.oracle.com/iaas/Content/Object/Tasks/understandingnamespaces.htm){:target="\_blank"}, and [Managing Compartments](https://docs.cloud.oracle.com/iaas/Content/Identity/Tasks/managingcompartments.htm){:target="\_blank"}. 
   (e.g. `--namespace my-tenancy`)
   
* A bucket to store persistent data within the Object Storage namespace. If you do not already have a bucket that you want to use, Halyard will create one for you (either with the `--bucket-name` value provided, or `_spinnaker_front50_data` by default).
   
   See [Managing Buckets](https://docs.cloud.oracle.com/iaas/Content/Object/Tasks/managingbuckets.htm){:target="\_blank"}. 
   (e.g. `--bucket-name my-spinnaker-bucket`) 

## Add Oracle Object Storage to Spinnaker

1. Run the following `hal` command to edit your storage settings. See [command reference](/reference/halyard/commands#hal-config-storage-oracle-edit).

   ```bash
   hal config storage oracle edit \
       --bucket-name $BUCKET_NAME \
       --compartment-id $COMPARTMENT_OCID \
       --fingerprint $API_KEY_FINGERPRINT \
       --namespace $TENANCY_NAME \
       --region $REGION \
       --ssh-private-key-file-path  $PRIVATE_KEY_FILE \
       --tenancy-id $TENANCY_OCID \
       --user-id $USER_OCID 
   ```
For example: 

  ```bash
    hal config storage oracle edit \
       --bucket-name spinnaker \
       --compartment-id ocid1.compartment.oc1..aaaaaaaatjuwhxwkspkxhumqke \
       --fingerprint 8f:05:f4:94:f3:5f:e3:30:ec:35:8e:77:3e:40:34:10 \
       --namespace oracle-cloud-tenancy \
       --region us-phoenix-1 \
       --ssh-private-key-file-path /Users/.oci/oci_api_key.pem \
       --tenancy-id ocid1.tenancy.oc1..aaaaaaaa225wmphohitdve3d2qmq4a \
       --user-id ocid1.user.oc1..aaaaaaaagosdr3zsh3clobgeqqawsq
   ```


2. Set the storage source to Oracle Object Storage:

   ```bash
   hal config storage edit --type oracle
   ```

## Next steps

After you've set up Oracle Object Storage as your external storage service, you're ready to
[deploy Spinnaker](/setup/install/deploy/).
