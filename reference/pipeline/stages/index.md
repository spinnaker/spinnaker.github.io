---
layout: single
title:  "Pipeline Stages"
sidebar:
  nav: reference
---

{% include toc %}

This article describes the currently-supported stages that you can add to your
Spinnaker pipelines.

## General

### Bake
Bakes an image in the specified region.

### Canary Analysis
Runs a canary task.

### Check Preconditions
Checks for preconditions before continuing.

### Clone Server Group
Deploys a new Server Group which is a copy of the specified Server Group.

### Deploy
Deploys the previously baked or found image.

### Destroy Server Group
Destroys a Server Group in the specified Cluster.

### Disable Cluster
Disables a Cluster.

### Disable Server Group
Disables a Server Group.

### Enable Server Group
Enables a Server Group.

### Find Artifact From Execution
Find and bind an artifact from another execution.

### Find Image From Cluster
Finds an image to deploy from an existing Cluster.

### Find Image From Tags
Finds an image to deploy from tags.

### Jenkins
Runs a Jenkins job.

### Manual Judgment
Waits for user approval before continuing.

### Pipeline
Runs an existing pipeline.

### Resize Server Group
Resizes a Server Group.

### Rollback Cluster
Roll back one or more regions in a Cluster.

### Run Job
Runs a container.

### Scale Down Cluster
Scales down a Cluster.

### Script
Runs a script.

### Shrink Cluster
Shrinks a Cluster.

### Tag Image
Tags an image.

### Wait
Waits a specified period of time.

### Webhook
Runs a Webhook job.

## AppEngine

### Start AppEngine Server Group
Starts a Server Group.

### Stop AppEngine Server Group
Stops a Server Group.

### Upsert AppEngine Load Balancers
Edits a Load Balancer.

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
Finds artifacts from a Kubernetes resource.

### Scale (Manifest)
Scale a Kubernetes object created from a manifest.

### Undo Rollout (Manifest)
Rollback a manifest a target number of revisions.
