---
layout: single
title:  "ECS"
sidebar:
  nav: reference
---

{% include toc %}

## Resource Mapping

### Server Group
A Spinnaker **server group** maps to an [ECS service](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html#service_concepts).

### Instance
A Spinnaker **instance** maps to an ECS [task](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_run_task.html).  ECS Services manage tasks to ensure desired capacity is reached.

### Cluster
An [ECS cluster](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_clusters.html) does not map to any core Spinnaker concept.  You can choose what cluster you deploy to in your deploy stage parameters
