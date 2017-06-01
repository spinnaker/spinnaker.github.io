---
layout: single
title:  "Concepts"
sidebar:
  nav: concepts
---

{% include toc %}

Spinnaker is an open source, multi-cloud continuous delivery platform that helps you release software changes with high velocity and confidence.

It provides two core sets of features: *cluster management* and *deployment management*. Here is an overview of these features:

## Cluster Management

You use Spinnaker's cluster management features to view and manage your resources in the cloud.

![](clusters.png)

### Server Group

The base resource, the *Server Group*, identifies the deployable artifact (VM image, Docker image, source location) and basic configuration settings such as number of instances, autoscaling policies, metadata, etc. This resource is associated with a Load Balancer and a Security Group. When deployed, a Server Group is a collection of instances of the running software (VM instances, Kubernetes replicat sets).

Server groups follow the **application-stack-detail-version** naming convention.

### Cluster

You can define *Clusters*, which are logical groupings of Server Groups in Spinnaker. These 
groups are based on the **application-stack-detail** naming convention.

### Applications

*Applications* are logical groupings of Clusters in Spinnaker from the **application-stack-detail**
 naming convention.

### Load Balancer

A *Load Balancer* is associated with an ingress protocol and port range. It balances traffic among instances in its Server Groups. Optionally, you can enable health checks for a load balancer, with flexiblity to define health criteria and specify the health check endpoint.

### Security Group

A *Security Group* defines network traffic access. It is effectively a set of firewall rules defined by an IP range (CIDR) along with a communication protocol (e.g., TCP) and port range.

> Learn more about cluster management on the [Clusters](/concepts/clusters/) page.

## Deployment Management

You use Spinnaker's deployment management features to construct and manage continuous delivery workflows. 

### Pipeline

![](pipelines.png)

*Pipelines* are the key deployment management construct in Spinnaker. They consist of a sequence of actions, known as stages. You can pass parameters from stage to stage along the pipeline. You can start a pipeline manually, or you can configure it to be started by automatic triggering events, such as a Jenkins job completing, a new Docker image appearing in your registry, a CRON schedule, or a stage in another pipeline. You can configure the pipeline to emit notifications to interested parties at various points during pipeline execution (such as on pipeline start/complete/fail), by email, SMS or HipChat.

### Stage

A *Stage* in Spinnaker is an action that forms an atomic building block for a pipeline. You can sequence stages in a Pipeline in any order, though some stage sequences may be more common than others. Spinnaker provides a number of stages such as Deploy, Resize, Disable, Manual Judgment, and many more. You can see the full list of stages and read about implementation details for each provider in the [Reference](/reference/providers) section.

### Deployment Strategies

![](deployment-strategies.png)

Spinnaker treats cloud-native deployment strategies as first class constructs, handling the underlying orchestration such as verifying health checks, disabling old server groups and enabling new server groups. Spinnaker supports the red/black (a.k.a. blue/green) strategy, with rolling red/black and canary strategies in active development.

> Learn more about deployment management on the [Pipelines](/concepts/pipelines/) page.

