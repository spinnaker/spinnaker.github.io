---
layout: single
title:  "Using Spinnaker for Automated Canary Analysis"
sidebar:
  nav: guides
---

{% include toc %}


Canary is a deployment process in which a change is rolled out gradually, with
checkpoints along the way to evaluate the new system (the canary) versus the old
system (baseline) to ensure that the new system is operating at least as well as
the old.

This evaluation is done using key metrics chosen when the canary is configured.

Canaries are usually used for deployments with changes to code, but can also be
used for operational changes, including changes to configuration.

The canary process is not a substitute for other forms of testing.

## How to make Canary work in Spinnaker&mdash;the high-level process

This process assumes Spinnaker is already set up to support Canary.

(See also: [The Canary Judge&mdash;how does it work?](/guides/user/canary/judge/).

### In Spinnaker, create one or more canary configurations.

This configuration provides the set of metrics for use in all pipeline
canary stages that reference it, plus default scoring thresholds and weights.

You can group metrics logically. Any that you leave ungrouped are evaluated, but
they don't contribute to the success or failure of the canary run.

You can configure each metric flexibly, to define its scope and whether it fails
when it deviates upward  or down.

### In any deployment pipeline that will use canary, add a canary stage.

   In that stage, you can

   [Here's how to add a canary stage to your pipeline]()


## Prerequisites
If you're going to generate the kinds of metrics that Spinnaker automated canary
analysis can use to make judgments, you must instrument your code to have those
metrics tracked by your telemetry service.
(((link to StackDriver docs as an example?)))

### Set up your canary environment

Before you have


Notes on what all else to include:
* Something descriptive about the judge itself. Not going to get into the
interface, in the sense that I'm not documenting for devs how to plug in their
own judge, but a little bit about how it works, from a data science pov, would
be good.

*
