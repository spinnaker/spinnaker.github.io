---
layout: single
title:  "Amazon ECS"
sidebar:
  nav: setup
---

{% include toc %}

In the Amazon ECS cloud provider, an [__Account__](/concepts/providers/#accounts)
maps to a Spinnaker AWS account, which itself is able to authenticate against a given [AWS
account](https://aws.amazon.com/account/){:target="\_blank"}.

## Prerequisites

### Amazon ECS cluster

You need to [create an Amazon ECS cluster](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create_cluster.html){:target="\_blank"}. If using the 'EC2' launch type, this cluster must have enough EC2 instance capacity in it to deploy your containers.  If using the 'Fargate' launch type, you don't need to add any capacity to this cluster.

### Networking

If using the 'awsvpc' networking mode (required for the 'Fargate' launch type), you need a VPC with at least one subnet group and security group visible in Spinnaker.

If using other networking modes like 'bridge', you don't need to setup any further networking.  The cluster's networking configuration will be passed from your cluster's EC2 instances to your containers.

### Spinnaker Clouddriver role

The role that Clouddriver assumes for your Amazon ECS account needs to have the trust relationship below for your Spinnaker IAM assumed role.  For information on how to set up the role Clouddriver assumes, see the [AWS documentation](/setup/install/providers/aws/aws-ec2/)  For information on how to modify IAM roles in the AWS console, see the [AWS documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_manage_modify.html){:target="\_blank"}

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
                ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### Optional: IAM Roles for Tasks

You can create IAM roles that have the `ecs-tasks.amazonaws.com` trust relationship so that your containers have an IAM role associated to them.  For information on how to modify IAM roles in the AWS console, see the [AWS documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_manage_modify.html){:target="\_blank"}

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

### Optional: Service Auto Scaling

You can configure your Amazon ECS services to use [Service Auto Scaling](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-auto-scaling.html){:target="\_blank"}.  Service Auto Scaling policies adjust your Amazon ECS service's desired count up or down in response to CloudWatch alarms (e.g. tracking the CPU utilization of an Amazon ECS service, or tracking a custom metric) or on a schedule (e.g. scale up on Monday, scale down on Friday).

Configure scaling policies on your Amazon ECS services using the Application Auto Scaling APIs or in the Amazon ECS console, outside of Spinnaker.  When deploying a new server group in Spinnaker, you can copy these scaling policies from the previous service group by enabling the "copy the previous server group's autoscaling policies" option.

### Halyard

Example command:
```bash
hal config provider ecs account add ecs-account-name --aws-account aws-account-name
```

In the above example, `ecs-account-name` is the name of the Amazon ECS account, and `aws-account-name` is the name of a previously added, valid AWS account.  Do note that the Amazon ECS account will use credentials from the corresponding AWS account.

### Clouddriver yaml properties

If you are not using Halyard, then you must declare Amazon ECS accounts and map them to a given AWS account by its name. Below is an example snippet you can put in `clouddriver.yml` or `clouddriver-local.yml`:

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
