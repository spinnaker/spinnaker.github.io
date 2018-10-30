---
layout: single
title:  "Using Spinnaker for automated canary analysis"
sidebar:
  nav: guides
---

{% include toc %}


Canary is a deployment process in which a change is partially rolled out, then
evaluated against the current deployment (baseline) to ensure that the new
deployment is operating at least as well as the old. This evaluation is done
using key metrics that are chosen when the canary is configured.

Canaries are usually run against deployments containing changes to code, but they
can also be used for operational changes, including changes to configuration.

The canary process is not a substitute for other forms of testing.

## Prerequisites

### Have metrics to evaluate

Your application might send performance metrics which are published and
available by default. You can also install a monitoring agent to collect more
comprehensive metrics, and you can instrument your code to generate further
metrics for that agent. In any case, you need to have access to a set of
metrics, using some telemetry provider, which Kayenta can then use to make the
canary judgment.

Support is built in for [Stackdriver](https://cloud.google.com/stackdriver/docs/),
[Datadog](https://docs.datadoghq.com/),
[Prometheus](https://prometheus.io/docs/introduction/overview/), and
[Signalfx](https://docs.signalfx.com).

### Set up your canary environment

Before you can configure canary analysis and create canary stages for your
pipelines, your Spinnaker administrator needs to [enable canary for your
installation](/setup/canary/).

## How to make Canary work in Spinnaker&mdash;the high-level process

1. In Spinnaker, [create one or more canary
configurations](/guides/user/canary/config/).

   The configuration provides the set of metrics for use in all pipeline
   canary stages that reference it, plus default scoring thresholds and
   weights&mdash;defaults that can be overridden in
   a [canary stage](/guides/user/canary/stage/)

   You can configure each metric flexibly, to define its scope and whether it
   fails when it deviates upward or down. You can also group metrics logically.
   (Any that you leave ungrouped are evaluated, but they don't contribute to the
   success or failure of the canary run.)

   You can think of this configuration as a templated set of queries against
   your metric store.

1. In any deployment pipeline that will use canary, [add one or more canary
stages](/guides/user/canary/stage/).

   The canary stage includes information that scopes the templated query (canary
     config) to a specified set of resources and time boundaries.

See also: [The Canary Judge&mdash;how does it work?](/guides/user/canary/judge/)
