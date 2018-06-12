---
layout: single
title:  "Using AWS CLI"
sidebar:
  nav: setup
---

{% include toc %}

In [AWS](https://aws.amazon.com/){:target="\_blank"}, an [__Account__](/concepts/providers/#accounts)
maps to a credential able to authenticate against a given [AWS
account](https://aws.amazon.com/account/){:target="\_blank"}.

## Prerequisites

Whatever account you want to manage with AWS needs a few things configured
before Spinnaker can manage it.

These steps assume that you will be naming this account `${MY_AWS_ACCOUNT}`
and is assigned region `us-west-1`.

### Create a VPC



### Create an EC2 role

### Create an EC2 key pair


## Adding an account


### Configuring the managing account



#### Create the SpinnakerAssumeRolePolicy



#### Configure an authentication mechanism



##### Option 1: Add an IAM role to the Spinnaker EC2 instance



##### Option 2: Add a user and access key / secret pair



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
