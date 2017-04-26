---
layout: single
title:  "Codelabs"
sidebar:
  nav: guides
---

Run through these codelabs to get hands-on experience with Spinnaker in a guided manner. In general, each of these codelabs is expected to take 1 hour.

## Table of Contents

* [Bake and Deploy Pipeline](./bake-and-deploy-pipeline) - set up a Spinnaker pipeline that bakes a virtual machine (VM) image containing redis, then deploys that image to a test cluster
* [Hello Deployment](./hello-deployment) - run through the workflow of setting up an example application deployment 
* [GCE Source To Prod](./gce-source-to-prod) - create a cohesive workflow which takes source code and builds, tests and promotes it to production with VMs in GCE
* [Kubernetes Source To Prod](./kubernetes-source-to-prod) - create a set of basic pipelines for deploying code from a Github repo to a Kubernetes cluster in the form of a Docker container
* [OpenStack Source To Prod](./openstack-source-to-prod) - create a cohesive workflow which takes source code and builds, tests, and promotes it to production on OpenStack
* [Continuous Delivery with Containers on GCP](./gcp-kubernetes-source-to-prod) - set up a source-to-prod continuous delivery flow for a hello world app deployed via containers, on the Google Cloud Platform
* [Halyard Getting Started](./halyard-getting-started) - using [halyard](/setup/install/halyard/), Spinnaker's config tool, install Spinnaker from scratch onto a Kubernetes cluster, and configure it with the Kubernetes provider
