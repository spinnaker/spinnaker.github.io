---
layout: single
title:  "Using Spinnaker for Automated Canary Analysis"
sidebar:
  nav: guides
---

{% include toc %}


Words words Words

# How Canary works in Spinnaker&mdash;the high-level process

1. In Spinnaker, create one or more canary configurations.
  This configuration provides a default set of metrics for use in all pipline
  canary stages that reference it, plus default scoring thresholds and weights.
  The configuration also identifies the judge used to evaluate the success or
  failure of the canary.

2. In any deployment pipeline that will use canary, add a canary stage.


## Prerequisites
If you're going to generate the kinds of metrics that Spinnaker automated canary
analysis can use to make judgements, you must instrument your code to have those
metrics tracked by your telemetry service.
(((link to Stackdrive docs as an example?)))



Notes on what all else to include:
* Something descriptive about the judge itself. Not going to get into the
interface, in the sense that I'm not documenting for devs how to plug in their
own judge, but a little bit about how it works, from a data science pov, would
be good.

*
