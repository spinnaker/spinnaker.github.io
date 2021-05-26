---
layout: single
title:  "Overview"
sidebar:
  nav: setup
---

## Overview
An AWS EC2 Server Group offers a number of launch setting configurations that can enhance your experience.

### Launch Settings
An AWS Server Group can be set up with two types of launch settings. However, <b>you must enable Launch Templates support for all of your applications if you want to use the latest AWS features.
AWS strongly recommends using Launch Templates over Launch Configurations because Launch Configurations do NOT provide full functionality for Amazon EC2 Auto Scaling or Amazon EC2.</b>

1. (Older) [launch configuration](https://docs.aws.amazon.com/autoscaling/ec2/userguide/LaunchConfiguration.html) is an instance configuration template that an AWS Auto Scaling group uses to launch EC2 instances.
2. (Newer) [launch template](https://docs.aws.amazon.com/autoscaling/ec2/userguide/LaunchTemplates.html) is similar to a launch configuration, in that it specifies instance configuration information.
   However, defining a launch template instead of a launch configuration allows you to:
   - have multiple versions of a template
   - access to the launch-template-only AWS features like diversification of instances of a server group across instance type, purchase options (On-Demand / Spot), allocation strategies.

Follow instructions [here](/features/server-group-launch-settings/aws-ec2/launch-templates.md) to learn more about using launch templates.

### Enhance your EC2 Spot experience
[Amazon EC2 Spot Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html#spot-features) 
let you take advantage of unused EC2 capacity in the AWS cloud. Spot Instances are available at up to a 90% discount compared to On-Demand prices. 

Spot Instances are tightly integrated with AWS services like Auto Scaling. Auto Scaling Groups let you tweak a number of configuration parameters that decide how to launch and maintain your applications running on Spot Instances.
Here are some configuration parameters to consider:
* use MixedInstancesPolicy features detailed [here](/features/server-group-launch-settings/aws-ec2/launch-templates.md) 
  e.g. `spotAllocationStrategy` with a flexible set of instance types i.e. `launch template overrides`
* enable `capacityRebalance` to allow EC2 Auto Scaling to monitor and automatically respond to changes that affect availability of your Spot Instances. This feature works best with `capacity-optimized` spotAllocationStrategy.
Learn more [here](https://docs.aws.amazon.com/autoscaling/ec2/userguide/capacity-rebalance.html)

Learn more about AWS recommended best practices [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-best-practices.html).
