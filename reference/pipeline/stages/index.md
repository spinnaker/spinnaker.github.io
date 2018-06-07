---
layout: single
title:  "Pipeline Stages"
sidebar:
  nav: reference
---

{% include toc %}

> Note: this is a first pass at this documentation; more details will be added
> soon.

This article describes the currently-supported stages that you can add to your
Spinnaker pipelines.

## General

### Bake
Bake an image in the specified region.

### Canary Analysis
Run [automated canary analysis](/guides/user/canary/) against the deployment
before fully deploying.

### Check Preconditions
Check for preconditions before continuing. For example, you can check that
your cluster is a particular size, or add a pipeline expression. See the
[pipeline expressions guide](/guides/user/pipeline-expressions/) for more
information about creating and using pipeline expressions.

### Clone Server Group
Deploy a new Server Group that is a copy of the specified Server Group.

### Deploy
Deploy the previously baked or found image using the specified deployment
strategy. Spinnaker provides built-in support for both red/black (also known as
blue/green) and Highlander deployment strategies. You can also choose to deploy
with no impact on existing Server Groups, or build your own custom deployment
strategy.

### Destroy Server Group
Delete a Server Group and its resources from the specified Cluster. You must
specify whether you want to delete the newest, oldest, or previous
(second-most-recently deployed) Server Group when this stage starts.

### Disable Cluster
Disable the specified Cluster, which means that the cluster remains up but
stops handling traffic. If desired, you can leave a specific number of Server
Groups running while the rest of the cluster is disabled.

### Disable Server Group
Disable a Server Group, which means that the Server Group remains up but stops
handling any traffic. This makes it easy to both route traffic to a new
Server Group and roll back those changes if necessary. You must choose whether
to disable the Server Group which is newest, oldest, or previous
(second-most-recently deployed) when this stage starts.

### Enable Server Group
Enable a Server Group, which means that the Server Group will will resume
handling traffic.

### Find Artifact From Execution
Find and bind an artifact from another pipeline execution.

### Find Image From Cluster
Find an image to deploy from an existing Cluster. You must specify the Cluster,
Server Group, and image name such that there is exactly one match.

### Find Image From Tags
Find an image to deploy from tags.

### Jenkins
Run a Jenkins job. You must [set up Jenkins](/setup/ci/jenkins/) in order to
use this stage.

### Manual Judgment
Wait for the user to click **Continue** before continuing.

### Pipeline
Run an existing pipeline: you can select any pipeline from this application and
run it as a sub-pipeline.


### Resize Server Group
Resize the oldest, newest, or second newest Server Group. You can resize the
Server Group by either a percentage of its current size or a specific amount.
The available resizing strategies are:
* **Scale Up**, which increases the size of the target Server Group.
* **Scale Down**, which decreases the size of the target Server Group.
* **Scale to Cluster Size**, which increases the size of the target Server Group
to match the largest Server Group in the Cluster. Optionally, you can specify
additional capacity to add as well.
* **Scale to Exact Size**, which adjusts the size of the target Server Group to
match the specified capacity.

### Rollback Cluster
Roll back one or more regions in a Cluster.

### Run Job
Run a container.

### Scale Down Cluster
Scale down a cluster. You can prevent this stage from scaling down active Server
Groups, or choose to keep a certain number of Server Groups at their current
size while the rest are scaled down.

### Script
Run a script.

### Shrink Cluster
Shrink a given cluster to contain nothing except a specified number of either
the newest or the largest Server Groups. You can choose whether to delete active
Server Groups if they don’t fit the specified criteria.

### Tag Image
Tag an image.

### Wait
Wait a specified period of time.

### Webhook
Run a Webhook job.

## AppEngine

### Start AppEngine Server Group
Start a Server Group.

### Stop AppEngine Server Group
Stop a Server Group.

### Upsert AppEngine Load Balancers
Edit a Load Balancer.

## AWS

### Modify AWS Scaling Process
Suspend/resume scaling processes.

## Kubernetes

### Bake (Manifest)
Bake a manifest (or multi-doc manifest set) using a template renderer such as
Helm.

### Delete (Manifest)
Destroy a Kubernetes object created from a manifest.

### Deploy (Manifest)
Deploy a Kubernetes manifest YAML/JSON file.

### Find Artifacts From Resource
Find artifacts from a Kubernetes resource.

### Scale (Manifest)
Scale a Kubernetes object created from a manifest.

### Undo Rollout (Manifest)
Rollback a manifest a target number of revisions.
