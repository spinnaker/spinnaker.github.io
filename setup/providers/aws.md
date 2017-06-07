---
layout: single
title:  "Amazon Web Services"
sidebar:
  nav: setup
---

{% include toc %}

In [AWS](https://aws.amazon.com/), an [__Account__](/setup/providers/#accounts)
maps to a credential able to authenticate against a given [AWS
account](https://aws.amazon.com/account/).

## Prerequisites

Whatever account you want to manage with AWS needs a few things configured
before Spinnaker can manage it.

These steps assume that you will be naming this account `${MY_AWS_ACCOUNT}`
and is assigned region `us-west-1`.

### Create a VPC

> This is the VPC instances will be deployed to.

Navigate to [Console](https://console.aws.amazon.com/) > VPC.

1. Select __Start VPC wizard__
2. Select create a __VPC with a Single Public Subnet__
3. Enter `defaultvpc` as the __VPC name__
4. Enter `defaultvpc.internal.us-west-1` as the __Subnet name__
5. Select __Create VPC__

### Create an EC2 Role

> This is the role instances launched/deployed with Spinnaker will assume.

Navigate to [Console](https://console.aws.amazon.com/) > IAM > Roles.

1. Select __Create new role__
2. Select __Amazon EC2__
3. Skip __Attach policy__ and go directly to __Next step__
4. Enter `BaseIAMRole` as the __Role name__
5. Select __Create role__

### Create an EC2 Key Pair

> This is the key pair instances launched with Spinnaker will be configured
> with, allowing you to SSH into them if need-be.

Navigate to [Console](https://console.aws.amazon.com/) > EC2 > Key Pairs.

1. Select __Create key pair__
2. Enter `${MY_AWS_ACCOUNT}-keypair` as the keypair name.
3. Download the resulting `${MY_AWS_ACCOUNT}-keypair.pem`, and run `chmod 400`
   against the file

## Adding an Account

There are two types of Accounts in the Spinnaker AWS provider; however, the
distinction is not made in how they are configured using Halyard, but instead
how they are configured in AWS.

1. Managing accounts. There is always exactly one managing account, this
   account is what Spinnaker authenticates as, and if necessary, assumes roles
   in the managed accounts.
2. Managed accounts. Every account that you want to modify resources in is a
   managed account. These will be configured to grant AssumeRole access to the
   managed account. __This includes the managing account!__

### Configuring the Managing Account

Assume the managing account has 12-digit account id `${MANAGING_ACCOUNT_ID}`,
and there is at least one (optional) managed account with 12-digit account id
`${MANAGED_ACCOUNT_ID}`.

Now we will create a policy that allows the managing account to assume roles in
each managed account.

#### Create the SpinnakerAssumeRolePolicy

Navigate to [Console](https://console.aws.amazon.com/) > IAM > Policies.

1. Select __Create policy__
2. Select __Create your own policy__
3. Enter `SpinnakerAssumeRolePolicy` as the policy name
4. Enter the following policy, subsituting all `${*}` values and adding extra
   entries for your other managed accounts.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Resource": [
                "arn:aws:iam::${MANAGING_ACCOUNT_ID}:role/spinnakerManaged",
                "arn:aws:iam::${MANAGED_ACCOUNT_ID}:role/spinnakerManaged"
            ],
            "Effect": "Allow"
        }
    ]
}
```

You can always add more accounts in the future by editing this policy.

#### Configure an Authentication mechanism

You can have Spinnaker authenticate via a user or role. If Spinnaker is
running outside of EC2, you must use a user and access key/secret key pair. If
Spinnaker is running inside of EC2, you may use your role on the instances
Spinnaker is installed on. In either case, the user or role must have the
`SpinnakerAssumeRolePolicy` attached, as well as the Amazon __PowerUserAccess__
policy.

If you are authenticating as a user via an access key/secret key pair
(`${ACCESS_KEY_ID}`/`${SECRET_ACCESS_KEY}`) you must run the following Halyard
command:

```bash
hal config provider aws edit --access-key-id ${ACCESS_KEY_ID} \
    --secret-access-key # do not supply the key here, you will be prompted
```

In either case, record the ARN of the authentication mechanism (either
`arn:aws:iam::${MANAGED_ACCOUNT_ID}:role/<some role name>` or
`arn:aws:iam::${MANAGED_ACCOUNT_ID}:user/<some user name>`).

### Configuring the Managed Account

> These steps need to be carried out for the managing account as well.

First, we will create the role that will be assumed by our managing account.

#### Create the spinnakerManaged

Using the ARN of the managing account recorded above (as `${AUTH_ARN}`), first
create a role like so:

Navigate to [Console](https://console.aws.amazon.com/) > IAM > Roles.

1. Select __Create new role__
2. Select __Amazon EC2__
3. Select __PowerUserAccess__ and hit __Continue__
4. Enter `spinnakerManaged` as the __Role name__
5. Select __Create role__
6. Navigate to the __Trust relationships__ tab
7. Select __Edit trust relationship__
8. Enter the following trust relationship, substituting for the `${AUTH_ARN}`
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "1",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${AUTH_ARN}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

Now add the account to the list of AWS accounts in Spinnaker using halyard:

```bash
$AWS_ACCOUNT_NAME={name for AWS account in Spinnaker, e.g. my-aws-account}

hal config provider aws account add $AWS_ACCOUNT_NAME \
    --account-id ${ACCOUNT_ID} \
    --assume-role role/spinnakerManaged
```

## Advanced Account Settings

You can view the available configuration flags for AWS within the
[Halyard reference](/reference/halyard/commands#hal-config-provider-aws-account-add).
