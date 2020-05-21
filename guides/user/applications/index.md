---
layout: single
title:  "About Applications"
sidebar:
  nav: guides
---

{% include toc %}

An application in Spinnaker is a construct that represents some service that you
are going to deploy (typically a microservice). It includes...

* the pipelines that process the service through to deployment in production

* the infrastructure on which the service is run:
  - clusters
  - server groups
  - firewalls
  - load balancers

* canary configs

## Important note about applications

When you first access a new instance of Spinnaker you might notice that there
are already several applications visible when you click the **Applications** tab.
This happens if you install Spinnaker on an existing Kubernetes cluster, using
the [Kubernetes provider](/reference/providers/kubernetes-v2/). These applications
are derived from existing infrastructure.

**Don't delete any of them**.

Also, don't use any of them as applications in which to create pipelines or add
further infrastructure. Instead, create new applications for your deployment
pipelines.

## What distinguishes one application from another?

By common practice, one application contains all of the above components for one
microservice.

There is nothing in Spinnaker that enforces the level at which you divide up
your services into applications, but it would be messy to put too much into one
application, dealing not only with all the containers to bake, canary configs to
manage, and so on, but also all the infrastructure.

For different reasons, you also don't want to segregate different environments
(dev, staging, prod) into different applications. In many cases you will have
pipelines, which deploy into one environment, eventually trigger other pipelines
that promote the same service into the next environment.

## Next

[Create An Application](/guides/user/applications/create/)
