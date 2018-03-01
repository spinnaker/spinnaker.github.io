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

# How Canary works in Spinnaker&mdash;the high-level process

Here's a high-level overview of how to set up and run automated canary analysis
in Spinnaker.

You might also be interested in learning [more about the canary judge and how it
makes its decisions](/guides/user/canary/judge/).

1. In Spinnaker, create one or more canary configurations.

   This configuration provides a default set of metrics for use in all pipeline
   canary stages that reference it, plus default scoring thresholds and weights.
   The configuration also identifies the judge used to evaluate the success or
   failure of the canary.

   [Here's how to create these configurations.]()

1. In any deployment pipeline that will use canary, add a canary stage.

   In that stage, you can

   [Here's how to add a canary stage to your pipeline]()


## Prerequisites

### Instrument your code for metrics

If you're going to generate the kinds of metrics that Spinnaker canary
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
