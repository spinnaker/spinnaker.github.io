---
layout: single
title:  "Using Spinnaker for Automated Canary Analysis"
sidebar:
  nav: guides
---

{% include toc %}


Canary is a deployment process in which a change is partially rolled out, then
evaluated against the current deployment (baseline) to ensure that the new
deployment is operating at least as well as the old. This evaluation is done
using key metrics chosen when the canary is configured.

Canaries are usually run against deployments containing changes to code, but they
can also be used for operational changes, including changes to configuration.

The canary process is not a substitute for other forms of testing.

## Prerequisites

### Instrument your code for metrics

If you're going to generate the kinds of metrics that Spinnaker canary
analysis can use to make judgments, you must instrument your code to have those
metrics tracked by your telemetry service.
(((link to StackDriver docs as an example?)))

### Set up your canary environment

Before you can configure canary analysis and create canary stages for your
pipelines, your Spinnaker administrator needs to [enable canary for your
installation](/setup/canary/).


*

## How to make Canary work in Spinnaker&mdash;the high-level process

This process assumes Spinnaker is already [set up to support Canary](/setup/canary/).

(See also: [The Canary Judge&mdash;how does it work?](/guides/user/canary/judge/).

1. In Spinnaker, create one or more canary configurations.

   This configuration provides the set of metrics for use in all pipeline
   canary stages that reference it, plus default scoring thresholds and weights.

   [Here's how](/guides/user/canary/config/).

   You can configure each metric flexibly, to define its scope and whether it
   fails when it deviates upward or down. Also, you can group metrics logically;
   any that you leave ungrouped are evaluated, but they don't contribute to the
   success or failure of the canary run.

1. In any deployment pipeline that will use canary, add a canary stage.

   In that stage, you can specify the scope and override scoring thresholds.

   [Here's how](/guides/user/canary/stage/).
