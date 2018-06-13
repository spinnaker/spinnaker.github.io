---
layout: single
title:  "Using AWS CLI"
sidebar:
  nav: setup
---

{% include toc %}

## Assumptions
In [AWS](https://aws.amazon.com/){:target="\_blank"}, an [__Account__](/concepts/providers/#accounts)
maps to a credential able to authenticate against a given [AWS
account](https://aws.amazon.com/account/){:target="\_blank"}.

Whatever account you want to manage with AWS needs a few things configured before Spinnaker can manage it.

* AWS CLI is [installed](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) and [configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).
* You will be naming this account `${MY_AWS_ACCOUNT}` and is assigned region `${AWS_REGION}`.


## Changes in Managed Account

Following are the steps required in the Managed Account

* Create a VPC
* Configure Authentication mechanism
    * Option 1: Add an IAM role to the Spinnaker EC2 instance
    * Option 2: Add a user and access key / secret pair


## Create a VPC in Managed Account
In case you dont have a VPC already created in your account,you can create it using the following script.
Copy and Paste the following script to your command line.

```bash

AWS_REGION="us-west-2"
VPC_CIDR="10.0.0.0/16"
VPC_NAME="defaultvpc"
SUBNET_PUBLIC_NAME="defaultvpc.public"
SUBNET_PUBLIC_CIDR="10.0.1.0/24"
SUBNET_PUBLIC_AZ="us-west-2a"

VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --query 'Vpc.{VpcId:VpcId}' --output text --region $AWS_REGION)
echo "  VPC ID '$VPC_ID' CREATED in '$AWS_REGION' region."

# Add Name tag to VPC

aws ec2 create-tags --resources $VPC_ID --tags "Key=Name,Value=$VPC_NAME" --region $AWS_REGION
echo "  VPC ID '$VPC_ID' NAMED as '$VPC_NAME'."

# Create Public Subnet

echo "Creating Public Subnet..."
SUBNET_PUBLIC_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_PUBLIC_CIDR --availability-zone $SUBNET_PUBLIC_AZ \
  --query 'Subnet.{SubnetId:SubnetId}' --output text --region $AWS_REGION)

echo "  Subnet ID '$SUBNET_PUBLIC_ID' CREATED in '$SUBNET_PUBLIC_AZ'" "Availability Zone."

# Add Name tag to Public Subnet
aws ec2 create-tags --resources $SUBNET_PUBLIC_ID --tags "Key=Name,Value=$SUBNET_PUBLIC_NAME" --region $AWS_REGION

echo "  Subnet ID '$SUBNET_PUBLIC_ID' NAMED as" "'$SUBNET_PUBLIC_NAME'."

# Create Internet gateway
echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' \
  --output text \
  --region $AWS_REGION)
echo "  Internet Gateway ID '$IGW_ID' CREATED."

# Attach Internet gateway to your VPC
aws ec2 attach-internet-gateway \
  --vpc-id $VPC_ID \
  --internet-gateway-id $IGW_ID \
  --region $AWS_REGION
  
echo "  Internet Gateway ID '$IGW_ID' ATTACHED to VPC ID '$VPC_ID'."

# Create Route Table
echo "Creating Route Table..."
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --query 'RouteTable.{RouteTableId:RouteTableId}' \
  --output text \
  --region $AWS_REGION)
echo "  Route Table ID '$ROUTE_TABLE_ID' CREATED."

# Create route to Internet Gateway
RESULT=$(aws ec2 create-route \
  --route-table-id $ROUTE_TABLE_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID \
  --region $AWS_REGION)
echo "  Route to '0.0.0.0/0' via Internet Gateway ID '$IGW_ID' ADDED to" \
  "Route Table ID '$ROUTE_TABLE_ID'."

# Associate Public Subnet with Route Table
RESULT=$(aws ec2 associate-route-table  \
  --subnet-id $SUBNET_PUBLIC_ID \
  --route-table-id $ROUTE_TABLE_ID \
  --region $AWS_REGION)
echo "  Public Subnet ID '$SUBNET_PUBLIC_ID' ASSOCIATED with Route Table ID" \
  "'$ROUTE_TABLE_ID'."


```

## Configure an authentication mechanism

### Option 1: Add an IAM role to the Spinnaker EC2 instance in Managing Account
If you plan on running Spinnaker on EC2 instances, the recommended approach is to assign an IAM role to the instance.


```bash

MANAGING_ACCOUNT_ID="FILL_YOUR_MANAGING_SPINNAKER_AWS_ACCOUNT"
MANAGED_ACCOUNT_ID="FILL_YOUR_MANAGED_AWS_ACCOUNT"

aws iam create-role --role-name SpinnakerAuthRole --assume-role-policy-document \
"{ \"Version\": \"2012-10-17\", \"Statement\": [ { \"Effect\": \"Allow\", \"Principal\": { \"AWS\": \"ec2.amazonaws.com\"}, \"Action\": \"sts:AssumeRole\" } ] }"

aws iam put-role-policy --role-name SpinnakerAuthRole --policy-name SpinnakerAssumeRolePolicy --policy-document \
"{ \"Version\": \"2012-10-17\", \"Statement\": [{ \"Action\": \"sts:AssumeRole\", \"Resource\": [ \"arn:aws:iam::${MANAGING_ACCOUNT_ID}:role/spinnakerManaged\", \"arn:aws:iam::${MANAGED_ACCOUNT_ID}:role/spinnakerManaged\" ], \"Effect\": \"Allow\" }] }

aws iam attach-role-policy --role-name SpinnakerAuthRole --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```


Correspondingly, create a role and grant the access to the role created above in __**each of the Managed Account including Managing Account**__

```bash

MANAGING_ACCOUNT_ID="FILL_YOUR_MANAGING_SPINNAKER_AWS_ACCOUNT"

aws iam create-role --role-name spinnakerManaged --assume-role-policy-document \
"{ \"Version\": \"2012-10-17\", \"Statement\": [ { \"Effect\": \"Allow\", \"Principal\": { \"Service\": \"arn:aws:iam::${MANAGING_ACCOUNT_ID}:role/BaseIAMRole\"}, \"Action\": \"sts:AssumeRole\" } ] }"

aws iam put-role-policy --role-name spinnakerManaged --policy-name SpinnakerPassRole --policy-document \
"{ \"Version\": \"2012-10-17\", \"Statement\": [{ \"Effect\": \"Allow\", \"Action\": [ \"ec2:*\" ], \"Resource\": \"*\" }, { \"Effect\": \"Allow\", \"Action\": \"iam:PassRole\", \"Resource\": \"arn:aws:iam::${MANAGING_ACCOUNT_ID}:role/BaseIAMRole\" }] }"

aws iam attach-role-policy --role-name spinnakerManaged --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
aws iam create-instance-profile --instance-profile-name s3access-profile
```


##### Option 2: Add a user and access key / secret pair

If Spinnaker is running outside of EC2, you may add a User and use access key / secret key to authenticate.

```bash

MANAGING_ACCOUNT_ID="FILL_YOUR_MANAGING_SPINNAKER_AWS_ACCOUNT"
MANAGED_ACCOUNT_ID="FILL_YOUR_MANAGED_AWS_ACCOUNT"

aws iam create-role --role-name SpinnakerAuthRole --assume-role-policy-document \
"{ \"Version\": \"2012-10-17\", \"Statement\": [ { \"Effect\": \"Allow\", \"Principal\": { \"AWS\": \"ec2.amazonaws.com\"}, \"Action\": \"sts:AssumeRole\" } ] }"

aws iam put-role-policy --role-name SpinnakerAuthRole --policy-name SpinnakerAssumeRolePolicy --policy-document \
"{ \"Version\": \"2012-10-17\", \"Statement\": [{ \"Action\": \"sts:AssumeRole\", \"Resource\": [ \"arn:aws:iam::${MANAGING_ACCOUNT_ID}:role/spinnakerManaged\", \"arn:aws:iam::${MANAGED_ACCOUNT_ID}:role/spinnakerManaged\" ], \"Effect\": \"Allow\" }] }

aws iam attach-role-policy --role-name SpinnakerAuthRole --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```


Correspondingly, create a role and grant the access to the role created above in __**each of the Managed Account including Managing Account**__

```bash

MANAGING_ACCOUNT_ID="FILL_YOUR_MANAGING_SPINNAKER_AWS_ACCOUNT"

aws iam create-role --role-name spinnakerManaged --assume-role-policy-document \
"{ \"Version\": \"2012-10-17\", \"Statement\": [ { \"Effect\": \"Allow\", \"Principal\": { \"Service\": \"arn:aws:iam::${MANAGING_ACCOUNT_ID}:role/BaseIAMRole\"}, \"Action\": \"sts:AssumeRole\" } ] }"

aws iam put-role-policy --role-name spinnakerManaged --policy-name SpinnakerPassRole --policy-document \
"{ \"Version\": \"2012-10-17\", \"Statement\": [{ \"Effect\": \"Allow\", \"Action\": [ \"ec2:*\" ], \"Resource\": \"*\" }, { \"Effect\": \"Allow\", \"Action\": \"iam:PassRole\", \"Resource\": \"arn:aws:iam::${MANAGING_ACCOUNT_ID}:role/BaseIAMRole\" }] }"

aws iam attach-role-policy --role-name spinnakerManaged --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

### Create an EC2 role



### Create an EC2 key pair


## Adding an account


### Configuring the managing account



#### Create the SpinnakerAssumeRolePolicy









### Configuring the managed account



#### Create the spinnakerManaged role


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
Service](/setup/install/providers/ecs/) or [set up another cloud
provider](/setup/install/providers/), but otherwise you're ready to
[choose an environment](/setup/install/environment/)
in which to install Spinnaker.
