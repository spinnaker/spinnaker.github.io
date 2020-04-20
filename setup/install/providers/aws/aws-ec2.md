---
layout: single
title:  "Amazon EC2"
sidebar:
  nav: setup
---

{% include toc %}

> :warning: These instructions are out-of-date and a new version is being
> worked on. In the meantime, please use the following
> [AWS install tutorial](https://aws.amazon.com/blogs/opensource/continuous-delivery-spinnaker-amazon-eks/).

In [AWS](https://aws.amazon.com/){:target="\_blank"}, an [__Account__](/concepts/providers/#accounts)
maps to a credential able to authenticate against a given [AWS
account](https://aws.amazon.com/account/){:target="\_blank"}.

## Option-1 : Use AWS Console to configure AWS

Use this option to deploy Spinnaker, if you are familar with deployment using [AWS Console](https://console.aws.amazon.com/) .

### Managing Account
1. Navigate to [Console](https://console.aws.amazon.com/){:target="\_blank"} > CloudFormation and [select](https://docs.aws.amazon.com/awsconsolehelpdocs/latest/gsg/getting-started.html#select-region) your preferred region.
2. Download [the template](https://d3079gxvs8ayeg.cloudfront.net/templates/managing.yaml) locally to your workstation.

    2.a (Optional). Add additional managed account as shown on line 158 in the SpinnakerAssumeRolePolicy section of the downloaded template file.
3. Creating the CloudFormation Stack
    * __Create Stack__ > __Upload a template to Amazon S3__ > __Browse to template you downloaded in Step-2 above__ > __Next__
    * Enter __Stack Name__ as spinnaker-**managing**-infrastructure-setup and follow the prompts on screen to create the stack
4. Once the stack is select the stack you created in Step-3 > Outputs and note the values. You will need these values for subsequent configurations.


### In each of the Managed Account

> These steps need to be carried out for the managing account as well.

1. Navigate to [Console](https://console.aws.amazon.com/){:target="\_blank"} > CloudFormation and [select](https://docs.aws.amazon.com/awsconsolehelpdocs/latest/gsg/getting-started.html#select-region) your preferred region.
2. Download [the template](https://d3079gxvs8ayeg.cloudfront.net/templates/managed.yaml) locally to your workstation.
3. Creating the CloudFormation Stack
    * __Create Stack__ > __Upload a template to Amazon S3__ > __Browse to template you downloaded in Step-2 above__ > __Next__
    * Enter __Stack Name__ as spinnaker-**managed**-infrastructure-setup and follow the prompts on screen to create the stack
    * Enter __AuthArn__ and __ManagingAccountId__ as the value noted above and follow the prompts on screen to create the stack

![](../outputs_cloudformation.png)

## Option-2 : Use AWS CLI to configure AWS

This option assumes that you have AWS CLI [installed](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) ,
[configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) and have access to managing and each of the managed account.


### Managing Account

If you want to use AccessKeys and Secrets to run Spinnaker

```bash

curl -O https://d3079gxvs8ayeg.cloudfront.net/templates/managing.yaml
echo "Optionally add Managing account to the file downloaded as shown on line 158 in the SpinnakerAssumeRolePolicy section of the downloaded file."
aws cloudformation deploy --stack-name spinnaker-managing-infrastructure-setup --template-file managing.yaml \
--parameter-overrides UseAccessKeyForAuthentication=true --capabilities CAPABILITY_NAMED_IAM --region us-west-2
```

If you want to use InstanceProfile run Spinnaker

```bash

curl -O https://d3079gxvs8ayeg.cloudfront.net/templates/managing.yaml
echo "Optionally add Managing account to the file downloaded as shown on line 158 in the SpinnakerAssumeRolePolicy section of the downloaded file."
aws cloudformation deploy --stack-name spinnaker-managing-infrastructure-setup --template-file managing.yaml \
--parameter-overrides UseAccessKeyForAuthentication=false --capabilities CAPABILITY_NAMED_IAM --region us-west-2
```

### In each of the Managed Account

> These steps need to be carried out for the managing account as well.


```bash

curl -O https://d3079gxvs8ayeg.cloudfront.net/templates/managed.yaml
aws cloudformation deploy --stack-name spinnaker-managed-infrastructure-setup --template-file managed.yaml \
--parameter-overrides AuthArn=FROM_ABOVE ManagingAccountId=FROM_ABOVE --capabilities CAPABILITY_NAMED_IAM --region us-west-2
```

## Option-3 : Use AWS Console UI (Manual Steps) 

There are 2 options here
1. Using AWS IAM AccessKey and Secret
Option number 1 is useful for creation of user with AWS Access Key and secret. This is a common configuration. 
2. Using AWS IAM Roles
Option 2 uses the IAM roles *ManagingRole* and *ManagedRoles*. This setting is applied on some environments that have extra security considerations.

## Halyard Configurations
After the AWS IAM user, roles, policies and trust relationship have been set up, the next step is to add the AWS configurations to Spinnaker via Halyard CLI:

1. Access the Halyard Pod.
2. Add the configurations for AWS provider with `hal` command. Please check [hal config provider AWS](https://www.spinnaker.io/reference/halyard/commands/#hal-config-provider-aws).
3. Enable the AWS provider `hal config provider aws enable`.

### Configure Halyard to use AccessKeys (if configured)

> These steps need to be carried out only if you selected UseAccessKeyForAuthentication as true in Option-1 or Option-2 above

```bash
hal config provider aws edit --access-key-id ${ACCESS_KEY_ID} \
    --secret-access-key # do not supply the key here, you will be prompted
```

### Configure Halyard to add AWS Accounts

```bash
$AWS_ACCOUNT_NAME={name for AWS account in Spinnaker, e.g. my-aws-account}

hal config provider aws account add $AWS_ACCOUNT_NAME \
    --account-id ${ACCOUNT_ID} \
    --assume-role role/spinnakerManaged
```

Now enable AWS

```bash
hal config provider aws enable
```

## Advanced account settings

You can view the available configuration flags for AWS within the
[Halyard reference](/reference/halyard/commands#hal-config-provider-aws-account-add).

## Next steps

Optionally, you can [set up Amazon's Elastic Container
Service](/setup/install/providers/aws/aws-ecs/) or [set up another cloud
provider](/setup/install/providers/), but otherwise you're ready to
[choose an environment](/setup/install/environment/)
in which to install Spinnaker.
