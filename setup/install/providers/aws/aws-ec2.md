---
layout: single
title:  "Amazon EC2"
sidebar:
  nav: setup
---

{% include toc %}

> :warning: These instructions were updated, on **2020-08-22**, to manually set up the AWS provider with [Option-3](#option-3--configure-with-aws-iam-console). <br>

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

## Option 2: Configure with AWS CLI

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
The Spinnaker **Managing** role AWS account assumes the Spinnaker **Managed** role AWS account in a target AWS account via AWS IAM resources (policies, roles, users, trust relationship, etc). This allows Spinnaker to control the AWS cloud resources.

For the Example below the AWS Account **spinnakerManaging** assumes the **spinnakerManaged** role in the AWS accounts **develop** and **staging**. The account **spinnakerManaging** is where Spinnaker lives.

A great use case for this set up is to deploy pre-built AWS AMIs to AWS EC2.

![Example AWS IAM structure for Spinnaker AWS Provider](/setup/install/providers/images/example-aws-provider.svg)

Before you start, create a simple table that maps the Account names to account IDs for your desired set up. An example table is shown below.

| Name              | Account Id   |
|-------------------|--------------|
| spinnakerManaging | 100000000001 |
| develop           | 200000000002 |
| staging           | 300000000003 |

### AWS IAM user or Roles
There are 2 options here
1. Set Up AWS IAM structure and use an AWS IAM User *spinnakerManaging* with AccessKey and Secret. This option is useful for creation of user with AWS Access Key and secret. This is a common configuration. 
2. Using AWS IAM Roles. Option 2 uses the IAM roles *ManagingRole* and *ManagedRoles*. This setting is applied on some environments that have extra security considerations. For Example the EC2 instance where Spinnaker is used to deploy AWS resources has the *ManagingRole* attached. The *ManagingRole* contains the AWS IAM policies required to manage AWS resources.

### Create AWS IAM user
- Access AWS IAM console
- Switch to spinnakerManaging AWS Account
- Add user and name it **spinnakerManaging**
- Check the “Programmatic access” checkbox
- Add tags that will identify this user e.g. spinnakerManaging
- Create user
- Copy the “Access key ID” and “Secret access key” to your secret management system i.e. Vault, AWS Secrets manager, 1Password
- Copy the AWS ARN of the Created User `arn:aws:iam::100000000001:user/spinnakerManaging`

### Create Roles
#### Create Managed Roles in each target AWS Account
The order of creation should be

1. Create **spinnakerManaged** in **develop ID=200000000002**
2. Create **spinnakerManaged** in **staging ID=300000000003**

- Access AWS IAM console
- Switch to develop AWS Account
- Roles > Create Role
- Select EC2. We can change this later, because we want to specify an explicit consumer of this role in a later stage.
- Search for PowerUserAccess in the search filter, and select the Policy called PowerUserAcces (This is what gives access to AWS services)
- Add tags that will identify this Role
- Enter a Role Name. **spinnakerManaged**
- Click Create role
- Select the Created Role > Click on **Add inline policy** (on the right) > Click on the **JSON** tab
- Add the following code for the Inline Policy and name it **PassRole-and-Certificates**
- Create Policy

```
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

- Repeat Steps for creation of **spinnakerManaged** on the next target AWS account. For this example **staging**

### Create Role BaseIAMRole
BaseIAMRole is the default role that Spinnaker will use if a **spinnakerManaged** Role is not found

- Access AWS IAM console For each of the desired target accounts. e.g. spinnakerManaging, develop and staging
- Roles > Create Role
- Select **EC2**, and click **Next: Permissions**
- Click **Next: Tags**
- Add tags that will identify this Role. Spinnaker
- Specify the Role Name as **BaseIAMRole**

### Create AWS Policy
The AWS IAM policy gives permissions the user **spinnakerManaging** to assume the role of the **spinnakerManaged** for the different target accounts **develop** and **staging**

- Select the AWS account where Spinnaker lives **spinnakerManaging**
- Access AWS IAM console
- List the AWS ARN of the **spinnakerManaged** accounts **develop** and **staging**. For example see the list below with 3 AWS ARN for different AWS Accounts each corresponding to an environment.
```
"arn:aws:iam::200000000002:role/spinnakerManaged",
"arn:aws:iam::300000000003:role/spinnakerManaged"
```

- From AWS IAM Policies > Create Policy > JSON Enter the policy attached below with the correct AWS ARNs for the **spinnakerManaged** accounts **develop** and **staging**
- Enter as the input name the policy myOrgSpinnakerManagingAccountPolicy e.g. **SpinnakerManagingAccountPolicy**
- Create policy. Note that this policy has access to EC2, cloudformation and ECR.

```
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

### Add Permissions to AWS IAM user/spinnakerManaging
- From AWS IAM console > User
- Permissions tab > Add Permissions
- Attach existing policies directly
- Add policy **SpinnakerManagingAccountPolicy**

### Configure Trust relationship between Managed Roles and managing User
This step sets the AWS trust relationship for the SpinnakerManaged AWS IAM role with the spinnakerManaging AWS IAM user

#### Configure the Managed Accounts To Trust The Managing Account IAM USER spinnakerManaging
The Managed Roles (Target Accounts develop and staging) must be configured to trust and allow the Managing (Assuming) User **spinnakerManaging**. For our example, in this step **spinnakerManaging** will be configured to assume the **spinnakerManaged** Role in AWS Accounts **develop** and **staging**.

This is called a **Trust Relationship** and is configured each of the Managed Roles (Target Roles) SpinnakerManagedRoleAccount

- Access AWS IAM Console in each of the required AWS target Accounts
- Roles > Find and select the Managed Role for the AWS Account e.g. **spinnakerManaged**
- Click on the Trust relationships tab.
- Obtain the AWS ARN of the user created in step [Create AWS IAM User](#create-aws-iam-user)
```
"arn:aws:iam::100000000001:user/spinnakerManaging"
```

- Edit the Trust Relationship **Edit trust relationship**
- Replace the Policy with the new policy that includes the AWS ARN of the Spinnaker Managing User **spinnakerManaging**

```
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

After setting the AWS IAM structure you can enable the AWS Provider in the Spinnaker configuration file. In the next section you can use the CLI tool *Halyard* to configure and enable the AWS Provider.

## Halyard Configurations
After the AWS IAM structure (user, roles, policies, and trust relationship) has been set up, the next step is to add the AWS configurations to Spinnaker via Halyard CLI:

### Enable AWS Provider
1. Access Halyard (Compute Instance, Pod, container locally, etc)
2. Add the configurations for AWS provider with `hal` command. Please check [hal config provider AWS](https://www.spinnaker.io/reference/halyard/commands/#hal-config-provider-aws).
3. Enable the AWS provider `hal config provider aws enable`. More details with the example to deploy to **develop** and **staging** AWS accounts below.

### Map AWS Accounts in Spinnaker Configuration

#### Add **spinnakerManaging** Account to Spinnaker
Add the managing account and specify an AWS region.
```bash
$AWS_ACCOUNT_NAME=""
ACCOUNT_ID="100000000001"

hal config provider aws account add $AWS_ACCOUNT_NAME \
    --account-id ${ACCOUNT_ID} \
    --assume-role role/spinnakerManaged \
    --regions us-east-1, us-west-2
```

#### Add **spinnakerManaged** Accounts to Spinnaker
```bash
$AWS_ACCOUNT_NAME={name for AWS account in Spinnaker, e.g. my-aws-account or develop as in the example presented in this document}
ACCOUNT_ID="200000000002"

hal config provider aws account add $AWS_ACCOUNT_NAME \
    --account-id ${ACCOUNT_ID} \
    --assume-role role/spinnakerManaged \
    --regions us-east-1, us-west-2
```

#### Configure Spinnaker AWS provider to use AccessKeys (if using AWS IAM user)

> These steps need to be carried out only if you selected [Option-1 AWS IAM user](#aws-iam-user-or-roles) with key id and secret.

```bash
hal config provider aws edit --access-key-id ${ACCESS_KEY_ID} \
    --secret-access-key # do not supply the key here, you will be prompted
```

### Enable the Spinnaker AWS provider
After having added the desired accounts you can enable the AWS provider
```bash
hal config provider aws enable
```

After you configure the Spinnaker AWS provider you can manage AWS resources depending on what you included in the [AWS policy](#create-aws-policy). You would be able to deploy EC2 resources with Spinnaker.

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
