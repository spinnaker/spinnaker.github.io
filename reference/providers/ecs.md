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