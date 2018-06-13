---
layout: single
title:  "Amazon ECS"
sidebar:
  nav: setup
---

{% include toc %}

In the ECS cloud provider, an [__Account__](/concepts/providers/#accounts)
maps to a Spinnaker AWS account, which itself is able to authenticate against a given [AWS
account](https://aws.amazon.com/account/){:target="\_blank"}.

## Prerequisites

### ECS cluster
You need to [create an ECS cluster](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create_cluster.html){:target="\_blank"}
and have enough capacity in it to deploy your containers.  

### Networking
As Elastic Network Interfaces (ENIs) are not yet supported in Spinnaker, you do not need to setup any further networking.  The cluster's networking configuration will be passed from your cluster instances to your containers.   

### Spinnaker Clouddriver role

The role that Clouddriver assumes for your ECS account needs to have the trust relationship below for your Spinnaker IAM assumed role.  For information on how to set up the role Clouddriver assumes, see the [AWS documentation](/setup/install/providers/aws/#adding-an-account)  For information on how to modify IAM roles in the AWS console, see the [AWS documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_manage_modify.html){:target="\_blank"}

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
                "Service": [
                  "ecs.amazonaws.com",
                  "application-autoscaling.amazonaws.com"
                ],
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```  

### Optional setups

You may create IAM roles that have the `ecs-tasks.amazonaws.com` trust relationship so that your containers have an IAM role associated to them.  For information on how to modify IAM roles in the AWS console, see the [AWS documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_manage_modify.html){:target="\_blank"}

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

You may create [Application Auto Scaling](https://docs.aws.amazon.com/autoscaling/application/userguide/what-is-application-auto-scaling.html){:target="\_blank"}
using Cloudwatch Alarms (tracking e.g. CPU utilization of an ECS service, or a custom metric) that have an autoscaling action.  These alarms will be available for you to clone from when deploying new server groups, and can be selected in the deploy server group modal in the UI.       

### Halyard


Example command:
```bash
hal config provider ecs account add ecs-account-name --aws-account aws-account-name
```

In the above example, `ecs-account-name` is the name of the ECS account, and `aws-account-name` is the name of a previously added, valid AWS account.  Do note that the ECS account will use credentials from the corresponding AWS account.


### Clouddriver yaml properties

If you are not using Halyard, then you must declare ECS accounts and map them to a given AWS account by its name. Below is an example snippet you can put in `clouddriver.yml` or `clouddriver-local.yml`:

```yaml
aws:
  enabled: true

  accounts:
    - name: aws-account-name
      accountId: "123456789012"
      regions:
        - name: us-east-1
  defaultAssumeRole: role/SpinnakerManaged

ecs:
  enabled: true
  accounts:
    - name: ecs-account-name
      awsAccount: aws-account-name
```


## Next steps

Optionally, you can [set up another cloud provider](/setup/install/providers/),
but otherwise you're ready to [choose an environment](/setup/install/environment/)
in which to install Spinnaker.
