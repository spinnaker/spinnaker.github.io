---
layout: single
title:  "Oracle"
sidebar:
  nav: setup
redirect_from: /setup/providers/oracle/
---
{% include toc %}

In [Oracle Cloud](https://cloud.oracle.com/){:target="\_blank"}, a Spinnaker
[__Account__](/concepts/providers/#accounts) maps to an [Oracle Cloud Infrastructure user]( https://cloud.oracle.com/en_US/tryit){:target="\_blank"}.

When setting up your Oracle Cloud provider account, you will [use halyard to add
the account](#add-an-oracle-cloud-account).

## Prerequisites

You will need the following to enable Oracle Cloud provider in Spinnaker:
- A user in IAM for the person or system who will be using Spinnaker, and put that user in at 
least one IAM group with any desired permissions. 
See [Adding Users](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/addingusers.htm#one){:target="\_blank"}. 
- The user's home region. 
See [Managing Regions](https://docs.cloud.oracle.com/iaas/Content/Identity/Tasks/managingregions.htm){:target="\_blank"}. 
(e.g. `--region us-ashburn-1`)
- RSA key pair in PEM format (minimum 2048 bits).
See [How to Generate an API Signing Key](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#How){:target="\_blank"}. 
(e.g. `--ssh-private-key-file-path /home/ubuntu/.oci/myPrivateKey.pem`)
- Fingerprint of the public key. 
See [How to Get the Key's Fingerprint](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#How3){:target="\_blank"}. 
(e.g. `--fingerprint 11:22:33:..:aa`)
- Tenancy's OCID and user's OCID.
See [Where to Get the Tenancy's OCID and User's OCID](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#Other){:target="\_blank"}. 
(e.g. `--tenancyId ocid1.tenancy.oc1..aa... --user-id ocid1.user.oc1..aa...`)
- Compartment OCID: On Oracle Cloud Console, open the navigation menu. Under Governance and Administration, go to Identity and click Compartments. 
See [Managing Compartments](https://docs.cloud.oracle.com/iaas/Content/Identity/Tasks/managingcompartments.htm){:target="\_blank"}. 
(e.g. `--compartment-id ocid1.compartment.oc1..aa...`)
- Upload the public key from the key pair in the Console. 
See [How to Upload the Public Key](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#How2){:target="\_blank"}. 

## Add an Oracle Cloud account

1. Run the following `hal` command to add an account named `my-oci-acct` to your list of Oracle Cloud accounts:

   ```bash
   hal config provider oracle account add my-oci-acct \
       --compartment-id $COMPARTMENT_OCID \
       --fingerprint $API_KEY_FINGERPRINT \
       --region $REGION \
       --ssh-private-key-file-path $PRIVATE_KEY_FILE \
       --tenancyId $TENANCY_OCID \
       --user-id $USER_OCID
   ```

   For example

   ```bash
   hal config provider oracle account edit my-oci-acct \
       --compartment-id ocid1.compartment.oc1..aaaaaaaatjuwhxwkspkxhumqke4o73b2b \
       --fingerprint 8f:05:f4:94:f3:5f:e3:30:ec:35 \
       --region us-phoenix-1 \
       --ssh-private-key-file-path /home/user/.oci/oci_api_key.pem \
       --tenancyId ocid1.tenancy.oc1..aaaaaaaa225wmphohi3iiyxxxjruo \
       --user-id ocid1.user.oc1..aaaaaaaagosdr3zsh67tvgpnmw42ywqc
   ```
   
2. Enable the Oracle Cloud provider:

   ```bash
   hal config provider oracle enable
   ```



