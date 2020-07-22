---
layout: single
title:  "Amazon EC2"
sidebar:
  nav: setup
---

{% include toc %}

> :warning: These instructions are out-of-date and a new version is being
> worked on. In the meantime, please use the following
> [AWS tutorial: Continuous Delivery using Spinnaker on Amazon EKS](https://aws.amazon.com/blogs/opensource/continuous-delivery-spinnaker-amazon-eks/).

Use the AWS EC2 Provider if you want to manage EC2 Instances via Spinnaker. Refer to the [AWS Cloud Provider Overview](https://spinnaker.io/setup/install/providers/aws/) to understand how AWS IAM must be set up with the Spinnaker AWS EC2 provider.

Spinnaker will use an [AWS IAM structure](https://aws.amazon.com/iam/) of users, roles, policies, and so on, to access AWS services and resources securely. There are 3 options to set up the AWS IAM structure

1. AWS CloudFormation templates deployed with the CloudFormation Console
2. AWS CloudFormation templates deployed with AWS CLI
3. Manually creating the IAM structure with the AWS IAM Console

In [AWS](https://aws.amazon.com/){:target="\_blank"}, an [__Account__](/concepts/providers/#accounts)
maps to a credential able to authenticate against a given [AWS
account](https://aws.amazon.com/account/){:target="\_blank"}.

## Option-1 : Configure with AWS CloudFormation Console

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

## Option-2 : Configure with AWS CLI

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

## Option-3 : Configure with AWS IAM Console
### Create Roles


### Create Policies


### Associate Policies to User or Roles
The permissions defined in the policies are attached to the users or roles. This will allows Spinnaker to use either a user or a role and deploy EC2 instances in any particular region.

There are 2 options here
1. Using AWS IAM User with AccessKey and Secret
Option number 1 is useful for creation of user with AWS Access Key and secret. This is a common configuration. 
2. Using AWS IAM Roles
Option 2 uses the IAM roles *ManagingRole* and *ManagedRoles*. This setting is applied on some environments that have extra security considerations.

## Halyard Configurations
After the AWS IAM  structure (user, roles, policies and trust relationship) has been set up, the next step is to add the AWS configurations to Spinnaker via Halyard CLI:

The General steps are the following:
1. Access the Halyard Pod.
2. Add the configurations for AWS provider with `hal` command. Please check [hal config provider AWS](https://www.spinnaker.io/reference/halyard/commands/#hal-config-provider-aws).
3. Enable the AWS provider `hal config provider aws enable`.

### Configure Spinnaker AWS provider to use AccessKeys (if using AWS IAM user)

> These steps need to be carried out only if you selected UseAccessKeyForAuthentication as true in Option-1 or Option-2 above

```bash
hal config provider aws edit --access-key-id ${ACCESS_KEY_ID} \
    --secret-access-key # do not supply the key here, you will be prompted
```

### Add AWS Accounts to the AWS provider

```bash
$AWS_ACCOUNT_NAME={name for AWS account in Spinnaker, e.g. my-aws-account}

hal config provider aws account add $AWS_ACCOUNT_NAME \
    --account-id ${ACCOUNT_ID} \
    --assume-role role/spinnakerManaged
```

### Enable the Spinnaker AWS provider

```bash
hal config provider aws enable
```

## Advanced account settings
Once you configure the Spinnaker AWS provider you will be able to manage and deploy EC2 resources with Spinnaker.

You can view the available configuration flags for Spinnaker AWS provider within the
[Halyard AWS provider reference](/reference/halyard/commands#hal-config-provider-aws-account-add).

## Next steps

Optionally, you can enable other AWS Providers:
[set up Amazon's Elastic Container
Service](/setup/install/providers/aws/aws-ecs/), [manage containers in AWS EKS](https://aws.amazon.com/eks/), [enable AWS Lambda support for Spinnaker](https://aws.amazon.com/lambda/) or [set up another cloud
provider](/setup/install/providers/).

Otherwise you're ready to [choose an environment](/setup/install/environment/)
in which to install Spinnaker.
