---
layout: single
title:  "Amazon Web Services"
sidebar:
  nav: setup
---

{% include toc %}

### Concepts

There are two types of Accounts in the Spinnaker AWS provider: __AWS Managing__ account and __AWS Managed__ account(s)

From the Spinnaker perspective, [Halyard](https://www.spinnaker.io/reference/halyard/) configures Spinnaker to use the __AWS Managing__ account and take control of the __AWS Managed__ account(s).

**_Note_** The AWS IAM structure must be set up prior to adding the Spinnaker AWS Provider with Halyard.


From the AWS perspective, __AWS Managing__ account will assume control of the __AWS Managed__ account(s) through the use of AWS IAM Roles. By assuming a role across AWS Accounts is how Spinnaker can control AWS resources from multiple __AWS Managed__ accounts.

Refer to [AWS IAM Providing Access to multiple AWS Accounts](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_common-scenarios_aws-accounts.html) for AWS technical details.


1. __AWS Managing__ account. There is always exactly one managing account, this
   account is what Spinnaker authenticates as, and if necessary, assumes roles
   in the managed account(s).
2. __AWS Managed__. Every AWS account that you want to modify resources in is a
   managed account. Managed accounts require AWS IAM policies and a trust relationship to grant AssumeRole access to the
   managed account(s). 
   
   The __AWS Managing__ account assumes the __AWS Managed__ account(s)
   
   __Use Case Example:__ AWS __Managing__ account __*spinnakermanaging*__ can assume the __Managed__ role in the accounts __*accountdev*__, __*accountstaging*__, __*accountprod*__ and deploy a baked AMI in the pipeline.

![](concepts.png)


That being said, below are some ways to configure Amazon Web Services (AWS) Cloud Provider. You may choose one or more based on your preferences

* [Amazon Elastic Compute Cloud (EC2)](/setup/install/providers/aws/aws-ec2/) - - Use this option, if you want to manage [EC2 Instances](https://aws.amazon.com/ec2/) via Spinnaker
* [Amazon Elastic Container Service (ECS)](/setup/install/providers/aws/aws-ecs/) - Use this option, if you want to manage containers in [Amazon ECS](https://aws.amazon.com/ecs/)
* [Amazon Elastic Kubernetes Service (EKS)](/setup/install/providers/kubernetes-v2/aws-eks/) - Use this option, if you want to manage containers in [Amazon EKS](https://aws.amazon.com/eks/). This option uses [Kubernetes V2 (manifest based) Clouddriver](/setup/install/providers/kubernetes-v2)
