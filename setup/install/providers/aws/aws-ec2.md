---
layout: single
title:  "Amazon EC2"
sidebar:
  nav: setup
---

{% include toc %}

> :warning: These instructions were updated, on **2020-08-22**, to manually set up the AWS provider with [Option-3](#option-3-configure-with-aws-iam-console). <br>

> The other options [Option-1](#option-1-configure-with-aws-cloudformation-console) and [Option-2](http://0.0.0.0:4000/setup/install/providers/aws/aws-ec2/#option-2-configure-with-aws-cli) are out-of-date and a new version has been worked on [PR2020](https://github.com/spinnaker/spinnaker.github.io/pull/2020). In the meantime, please use the following
> [AWS tutorial: Continuous Delivery using Spinnaker on Amazon EKS](https://aws.amazon.com/blogs/opensource/continuous-delivery-spinnaker-amazon-eks/).

The AWS EC2 Provider allows you to deploy AWS EC2 resources with Spinnaker. The most common use case is the deployment of ready-to-go baked AMIs.

Use the AWS EC2 Provider if you want to manage EC2 Instances via Spinnaker. Refer to the [AWS Cloud Provider Overview](https://spinnaker.io/setup/install/providers/aws/) to understand how AWS IAM must be set up with the Spinnaker AWS EC2 provider.

The AWS EC2 and AWS ECS legacy providers depend on the AWS IAM structure that must be set up before trying to deploy resources to AWS EC2. Refer to the [Concepts overview page](http://spinnaker.io/setup/install/providers/aws/)

Spinnaker will use an [AWS IAM structure](https://aws.amazon.com/iam/) with users, roles, policies, and so on, to access AWS services and resources securely. There are 3 options to set up the AWS IAM structure

1. AWS CloudFormation templates deployed with the CloudFormation Console
2. AWS CloudFormation templates deployed with AWS CLI
3. Manually creating the IAM structure with the AWS IAM Console

In [AWS](https://aws.amazon.com/){:target="\_blank"}, an [__Account__](/concepts/providers/#accounts)
maps to a credential able to authenticate against a given [AWS
account](https://aws.amazon.com/account/){:target="\_blank"}.

## Option 1: Configure with AWS CloudFormation Console

Use this option to deploy Spinnaker, if you are familar with deployment using [AWS Console](https://console.aws.amazon.com/) .

### Managing Account
1. Navigate to [Console](https://console.aws.amazon.com/){:target="\_blank"} > CloudFormation and [select](https://docs.aws.amazon.com/awsconsolehelpdocs/latest/gsg/getting-started.html#select-region) your preferred region.
2. Download [the template](https://www.spinnaker.io/downloads/aws/managing.yaml) locally to your workstation.

    2.a (Optional). Add additional managed account as shown on line 158 in the SpinnakerAssumeRolePolicy section of the downloaded template file.
3. Creating the CloudFormation Stack
    * __Create Stack__ > __Upload a template to Amazon S3__ > __Browse to template you downloaded in Step-2 above__ > __Next__
    * Enter __Stack Name__ as spinnaker-**managing**-infrastructure-setup and follow the prompts on screen to create the stack
4. Once the stack is select the stack you created in Step-3 > Outputs and note the values. You will need these values for subsequent configurations.
5. If you set UseAccessKeyForAuthentication to "true" for the stack, retrieve the access key credentials.
    * Navigate to the Secrets Manager console.
    * Select the secret created by your CloudFormation stack.  The name of the secret was shown in the __SpinnakerUserSecret__ output value for the stack.
    * Click __Retrieve secret value__ and note the values. You will need these values for subsequent configurations.

### In each of the Managed Account

> These steps need to be carried out for the managing account as well.

1. Navigate to [Console](https://console.aws.amazon.com/){:target="\_blank"} > CloudFormation and [select](https://docs.aws.amazon.com/awsconsolehelpdocs/latest/gsg/getting-started.html#select-region) your preferred region.
2. Download [the template](https://www.spinnaker.io/downloads/aws/managed.yaml) locally to your workstation.
3. Creating the CloudFormation Stack
    * __Create Stack__ > __Upload a template to Amazon S3__ > __Browse to template you downloaded in Step-2 above__ > __Next__
    * Enter __Stack Name__ as spinnaker-**managed**-infrastructure-setup and follow the prompts on screen to create the stack
    * Enter __AuthArn__ and __ManagingAccountId__ as the value noted above and follow the prompts on screen to create the stack

![](../outputs_cloudformation.png)

## Option 2: Configure with AWS CLI

This option assumes that you have AWS CLI [installed](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) ,
[configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) and have access to managing and each of the managed account.


### Managing Account

If you want to use AccessKeys and Secrets to run Spinnaker

```bash

curl -O https://www.spinnaker.io/downloads/aws/managing.yaml
echo "Optionally add Managing account to the file downloaded as shown on line 158 in the SpinnakerAssumeRolePolicy section of the downloaded file."
aws cloudformation deploy --stack-name spinnaker-managing-infrastructure-setup --template-file managing.yaml \
--parameter-overrides UseAccessKeyForAuthentication=true --capabilities CAPABILITY_NAMED_IAM --region us-west-2
```

If you want to use InstanceProfile run Spinnaker

```bash

curl -O https://www.spinnaker.io/downloads/aws/managing.yaml
echo "Optionally add Managing account to the file downloaded as shown on line 158 in the SpinnakerAssumeRolePolicy section of the downloaded file."
aws cloudformation deploy --stack-name spinnaker-managing-infrastructure-setup --template-file managing.yaml \
--parameter-overrides UseAccessKeyForAuthentication=false --capabilities CAPABILITY_NAMED_IAM --region us-west-2
```

After deploying the stack, retrieve the outputs for the created stack:

```bash

aws cloudformation describe-stacks --stack-name spinnaker-managing-infrastructure-setup  --region us-west-2 --query 'Stacks[0].Outputs'
```

If you chose to use AccessKeys and Secrets to run Spinnaker, retrieve the values from Secrets Manager using the secret ARN in the stack's SpinnakerUserSecret output:

```bash

aws secretsmanager get-secret-value --secret-id FROM_ABOVE --region us-west-2
```

### In each of the Managed Account

> These steps need to be carried out for the managing account as well.


```bash

curl -O https://www.spinnaker.io/downloads/aws/managed.yaml
aws cloudformation deploy --stack-name spinnaker-managed-infrastructure-setup --template-file managed.yaml \
--parameter-overrides AuthArn=FROM_ABOVE ManagingAccountId=FROM_ABOVE --capabilities CAPABILITY_NAMED_IAM --region us-west-2
```

## Option 3: Configure with AWS IAM Console

Option 3 focuses on using two roles, a Spinnaker **Managing** role and a Spinnaker **managed** role. The Spinnaker **Managing** role AWS account assumes the Spinnaker **Managed** role AWS account in a target AWS account using AWS IAM resources, including policies, roles, users, and trust relationship. This allows Spinnaker to control the AWS cloud resources.

For the example below, the AWS Account **spinnakerManaging** assumes the **spinnakerManaged** role in the AWS accounts **develop** and **staging**. The account **spinnakerManaging** is where Spinnaker lives.

A great use case for this set up is to deploy pre-built AWS AMIs to AWS EC2.

![Example AWS IAM structure for Spinnaker AWS Provider](/setup/install/providers/images/example-aws-provider.svg)

Before you start, create a table that maps the account names to account IDs for your desired set up. An example table is shown:

| Name              | Account Id   |
|-------------------|--------------|
| spinnakerManaging | 100000000001 |
| develop           | 200000000002 |
| staging           | 300000000003 |

These examples are used in the subsequent sections.

### AWS IAM user or roles

For IAM, you can either create IAM users or roles based on your requirements:

1. Set Up AWS IAM structure and use an AWS IAM User *spinnakerManaging* with AccessKey and Secret. This option is useful for creating users with AWS Access Key and secret. This is a common configuration.
2. Using AWS IAM Roles, such as creating a *ManagingRole* and *ManagedRoles*. This option might be needed for environments that have extra security considerations. The EC2 instance where Spinnaker is used to deploy AWS resources has the *ManagingRole* attached. The *ManagingRole* contains the AWS IAM policies required to manage AWS resources.

### Create AWS IAM user

1. Navigate to the AWS IAM console.
2. Switch to the **spinnakerManaging** AWS Account.
3. Add a user and name it **spinnakerManaging**.
4. Check the “Programmatic access” checkbox.
5. Add tags to help you identify this user, such as "spinnakerManaging".
6. Create the user.
7. Save the “Access key ID” and “Secret access key” somewhere secure, such as a secret management system like Vault, AWS Secrets manager, or 1Password.
8. Save the AWS ARN for the user, for example: `arn:aws:iam::100000000001:user/spinnakerManaging`. You need the ARN later when you configure the managed accounts to trust the managing account (IAM user).

### Create Roles

#### Create Managed Roles in each target AWS Account

First, create the **spinnakerManaged** role for the **develop ID=200000000002**. Then, repeat the same steps to create **spinnakerManaged** in **staging ID=300000000003**.

1. Navigate to the AWS IAM console.
2. Switch to the AWS Account you want to create the roll for.
3. Go to **Roles > Create Role**.
4. Select EC2. You can change this later, because we want to specify an explicit consumer of this role in a later stage.
5. For permissions, search for "PowerUserAccess" and select this policy. This gives the role permission to access AWS services.
6. Add tags that will help you identify this role.
7. Enter a role name: spinnakerManaged.
8. Create the roll.
9. Select the created role and add an inline policy using the following JSON snippet: 

   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Action": [
                   "iam:ListServerCertificates",
                   "iam:PassRole"
               ],
               "Resource": [
                   "*"
               ],
               "Effect": "Allow"
           }
       ]
   }
   ```

10. Name the policy "PassRole-and-Certificates".
11. Create the policy.

Repeat these steps for the second AWS environment. In this example, that is the **staging** environment.

### Create the role BaseIAMRole

BaseIAMRole is the default role that Spinnaker will use if the **spinnakerManaged** role is not found.

1. Navigate to the AWS IAM console. 
2. Create the role.
3. Select **EC2**, and click **Next: Permissions**
4. Click **Next: Tags**
5. Add tags that will identify this Role. Spinnaker
6. Specify the Role Name as **BaseIAMRole**

Repeat this process for all the accounts.

### Create AWS Policy

The AWS IAM policy gives permissions to the **spinnakerManaging** user to assume the **spinnakerManaged** role for the different target accounts (**develop** and **staging**).

1. Select the AWS account where Spinnaker lives **spinnakerManaging**.
2. Access AWS IAM console.
3. List the AWS ARN of the **spinnakerManaged** accounts **develop** and **staging**. For example, the list below shows 3 AWS ARNs for different AWS accounts, each corresponding to an environment:

   ```bash
   "arn:aws:iam::200000000002:role/spinnakerManaged",
   "arn:aws:iam::300000000003:role/spinnakerManaged"
   ```

4. Add a policy using the following JSON. Make sure to update it with the correct AWS ARNs for the **spinnakerManaged** accounts **develop** and **staging**:

   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Action": [
                   "ec2:*",
                   "cloudformation:*",
                   "ecr:*"
               ],
               "Resource": [
                   "*"
               ]
           },
           {
               "Action": "sts:AssumeRole",
               "Resource": [
                   "arn:aws:iam::200000000002:role/spinnakerManaged",
                   "arn:aws:iam::300000000003:role/spinnakerManaged"
               ],
               "Effect": "Allow"
           }
       ]
   }
   ```

   Note that this policy has access to EC2, CloudFormation, and ECR.

5. Give the policy a descriptive name, such as **SpinnakerManagingAccountPolicy**.
6. Create the policy.

### Add permissions to AWS IAM user spinnakerManaging

1. In the AWS IAM console, go to **User** and select **spinnakerManaging**.
2. Add Permissions.
3. Attach an existing policy: **SpinnakerManagingAccountPolicy**.

### Configure the trust relationship between the managed Roles and managing User

Set up the AWS trust relationship for the SpinnakerManaged AWS IAM role with the **spinnakerManaging** AWS IAM user.

#### Configure the managed accounts to trust the managing account (IAM user) spinnakerManaging

The managed accounts (**develop** and **staging** in this example) need to be configured to trust the **spinnakerManaging** to use AWS resources under their control. For this example, **spinnakerManaging** assumes the **spinnakerManaged** role in the AWS Accounts **develop** and **staging**.

This trust relationship and is configured for each of the target managed roles.

1. Navigate to the AWS IAM Console and select one of the managed accounts. For this example, this is **develop** and **staging**.
2. In the **Roles** section, find and select the managed role for the AWS Account, **spinnakerManaged** in this example.
3. Go to the **Trust relationship** tab.
4. Edit the trust relationship. Use the following policy, making sure to replace the example ARN with the actual ARN from [Create AWS IAM User](#create-aws-iam-user):

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
           "AWS": [
             "arn:aws:iam::100000000001:user/spinnakerManaging"
           ]
         },
         "Action": "sts:AssumeRole"
       }
     ]
   }
   ```
5. Repeat this process for any managed accounts. This example requires the both **develop** and **staging** to have a trust relationship with the IAM user **spinnakerManaging**.

After you set up the AWS IAM user, roles, policies and trust relationship, enable the AWS Provider in the Spinnaker. You can use the CLI tool *Halyard* to configure and enable the AWS Provider.

## Halyard Configurations

After the AWS IAM structure (user, roles, policies, and trust relationship) has been set up, the next step is to add the AWS configurations to Spinnaker via Halyard CLI:

### Enable the AWS provider

Before you start, you must have Halyard installed. Additionally, you should understand how to run Halyard commands. Specifically, how you access Halyard depends on how and where you installed Halyard. For example, if you installed Halyard in a Docker container, you need to use the `docker exec` command.

1. Add the AWS accounts to Spinnaker:

   ```bash
   hal config provider aws [parameters] [subcommands]
   ```

   For information about the available parameters, see [hal config provider AWS](https://www.spinnaker.io/reference/halyard/commands/#hal-config-provider-aws).

   The following examples add the ****spinnakerManaging** and **develop** accounts from the previous examples. Repeat the command for every account you want to add.

   ```bash
# Adds spinnakerManaging for the regions us-east-1 and us-west-2
   export AWS_ACCOUNT_NAME=""
   export ACCOUNT_ID="100000000001"
   
   hal config provider aws account add $AWS_ACCOUNT_NAME \
       --account-id ${ACCOUNT_ID} \
       --assume-role role/spinnakerManaged \
       --regions us-east-1, us-west-2
   ```

   ```bash
   # Adds the develop account for the regions us-east-1 and us-west-2.
   export AWS_ACCOUNT_NAME=develop
   export ACCOUNT_ID="200000000002"
   
   hal config provider aws account add $AWS_ACCOUNT_NAME \
       --account-id ${ACCOUNT_ID} \
       --assume-role role/spinnakerManaged \
       --regions us-east-1, us-west-2
   ```

2. Enable the AWS provider:

   ```bash
   hal config provider aws enable
   ```

After you configure the Spinnaker AWS provider you can manage AWS resources depending on what you included in the [AWS policy](#create-aws-policy). You would be able to deploy EC2 resources with Spinnaker.

#### Configure Spinnaker AWS provider to use AccessKeys (if using AWS IAM user)

> These steps need to be carried out only if you selected [Option-1 AWS IAM user](#aws-iam-user-or-roles) with key id and secret.

```bash
hal config provider aws edit --access-key-id ${ACCESS_KEY_ID} \
    --secret-access-key # do not supply the key here, you will be prompted
```

### Advanced config for AWS provider
You can view the available configuration flags for the Spinnaker AWS provider within the
the [Halyard command reference](/reference/halyard/commands#hal-config-provider-aws-account-add).

## Next steps

Optionally, you can enable other AWS Providers:
* [Manage containers in AWS ECS with Spinnaker](/setup/install/providers/aws/aws-ecs/)
* [Manage containers in AWS EKS with Spinnaker](https://aws.amazon.com/eks/)
* [Enable AWS Lambda support with Spinnaker](https://aws.amazon.com/lambda/) 
* [Set up another cloud provider](/setup/install/providers/)

Otherwise you are ready to [choose an environment](/setup/install/environment/)
in which to install Spinnaker.
