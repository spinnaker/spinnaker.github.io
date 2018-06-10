---
layout: single
title:  "Productionize Spinnaker"
sidebar:
  nav: setup
---

Spinnaker is a large system, made of many microservices, each intended to be
scaled, restarted, and configured independently. This provides operators a
great degree of flexibility, and allows Spinnaker to handle massive scale (1K+
deployments/day, 10K+ managed machines). However, there is no one-size-fits-all
approach for configuring Spinnaker; your organization's usage patterns will
need to inform how to prepare your Spinnaker deployment to be used in
production.

These pages are intended to provide both an intuition for how Spinnaker works,
as well as concrete tips and advice to make Spinnaker more reliable at scale.

## Getting started

Before we can confidently productionize an installation of Spinnaker, we need
insight into what's going on. This insight is provided by Spinnaker's logs and
metrics.

* __Logs__

  In the __Distributed__ deployments to Kubernetes, logs are forwarded to
  whatever [logging
  solution](https://kubernetes.io/docs/concepts/cluster-administration/logging/)
  you have configured.

  In the __LocalDebian__ deployments, logs are written to `/var/log/spinnaker`.

* __Metrics__

  Follow the [monitoring setup instructions](/setup/monitoring) to export
  Spinnaker's metrics into a metric store of your choice.
