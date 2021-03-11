---
layout: single
title:  "Amazon ECS"
sidebar:
  nav: reference
---

{% include toc %}

## Resource mapping

### Server group

A Spinnaker **server group** maps to an [Amazon ECS service](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html#service_concepts).

There are two ways to specify server group settings for Amazon ECS:

* __Inputs (default)__: 
  Specify the container image, resource limits, and other settings needed to create an [Amazon ECS task definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html) and [service](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html#service_concepts) directly in the server group. This option supports deploying one container per Amazon ECS task (equivalent to a Spinnaker "instance").

* __Artifact (supported as of 1.15.0)__:
  Specify a pipeline artifact to use as an Amazon ECS task definition for the service. The artifact should be a JSON file in the format of an Amazon ECS [Register Task Definiton request](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_RegisterTaskDefinition.html). This option also requires that you specify `containerName`:`imageDescription` mappings for each image in your pipeline that you want to be deployed within the service. You can deploy multiple containers (up to 10) per Amazon ECS task using this option.

### Instance

A Spinnaker **instance** maps to an Amazon ECS [task](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_run_task.html).  Amazon ECS services manage tasks to ensure desired capacity is reached.

### Cluster

An [Amazon ECS cluster](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_clusters.html) does not map to any core Spinnaker concept.  You can choose what cluster you deploy to in your deploy stage parameters.


## Operation mapping

### Deploy
Deploys a new Amazon ECS service to the specified server group(s). For load balanced services, the previous service will be drained after the new service is considered healthy.

Deployments to Amazon ECS take two actions in regards to Amazon ECS resources:

1. Register a new Amazon ECS task definition that contains the specified container(s), their image(s), and other information needed for your application to run.
2. Create a new Amazon ECS service that runs the registered task definition with the desired instance (task) count, load balancer, and scaling policies. 

### Destroy
Scales the desired count for the Amazon ECS service down to 0 instances (tasks), then deletes the service.

### Disable
Scales the desired count for the Amazon ECS service down to 0 instances (tasks), so no instances are running.

### Resize

Scales the Amazon ECS service up or down to the desired number of instances (tasks).

# Resource Naming

From Spinnaker 1.24 the ECS provider can be configured to use either [Frigga](https://github.com/Netflix/frigga) or a tag based naming strategy which Spinnaker manages using its
[Moniker](https://github.com/spinnaker/moniker) library. The naming strategy is configurable per-account or applied as a default across all accounts.

```yaml
ecs:
  enabled: true
  defaultNamingStrategy: "default"   <--- 'default' naming used by default (field absent) or if specified
  accounts:
    - name: "ecs-moniker-acct"
      awsAccount: "ec2-aws-acct"
      namingStrategy: "tags"         <--- 'tags' specified for specific account
```

## `default` Naming Strategy

The `default` naming strategy uses the [Frigga](https://github.com/Netflix/frigga) naming convention to parse information about resources. This derives all values for application, stack, detail, etc from the name of the resource.

## `tags` Naming Strategy

The `tags` naming strategy uses information from tags on the resource to derive information like application, stack, detail, etc.

To use ECS service tags, your Amazon ECS account must be [opted into using the long Amazon Resource Name (ARN) format](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-account-settings.html#ecs-resource-ids). In addition, your AWS `SpinnakerManaged` role will need to call [`ecs:ListAccountSettings`](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ListAccountSettings.html) in order to validate whether your account is compatible with tags.

Currently these tags are only applied at the ECS service level which is then configured to propagate the tags to any tasks created by the service scheduler.

### Reserved Tags

Several tags are used as metadata by Spinnaker to describe a resource.
Tags listed below followed by a 📝 symbol may also be written by
Spinnaker.

* `moniker.spinnaker.io/application` 📝

  The application this resource belongs to.

  This affects where the resource is accessible in the UI, and depending on your
  Spinnaker Authorization setup, can affect which users can read/write to this
  resource.

* `moniker.spinnaker.io/cluster` 📝

  The cluster this resource belongs to.

  This is purely a logical grouping for rendering resources in the UI and to
  help with dynamic target selection in Pipeline stages. For example, some
  stages allow you to select "the newest workload in cluster __X__". How you set
  up these groupings depends on your delivery needs.

* `moniker.spinnaker.io/stack` 📝, and `moniker.spinnaker.io/detail` 📝

  These provide ways to group resources using Spinnaker's cluster filters
  as well as apply policies such as [Traffic
  Guards](https://blog.spinnaker.io/can-i-push-that-building-safer-low-risk-deployments-with-spinnaker-a27290847ac4).

* `moniker.spinnaker.io/sequence` 📝

  The sequence number of the release this resource belongs to.

  Each modification of a resource is deployed with a new sequence number in the format `vNNN`. This allows for multiple versions to be running and provides 
  for rollback.