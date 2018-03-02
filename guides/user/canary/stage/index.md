---
layout: single
title:  "Add a Canary stage to a pipeline"
sidebar:
  nav: guides
---

{% include toc %}


If you have [enabled canary for your application]() and have one or more canary
configs prepared, you can now add a canary stage to your pipeline and configure
it to perform canary analysis for your deployment, against the target
environment.

## About the canary stage

The canary analysis can be performed over data points collected beginning from
the moment of execution and into the future, or it can be performed over a
specified time interval.

A Real Time analysis means that the canary analysis will be performed over a time interval beginning at the moment of execution.

The Retrospective analysis type means that the canary analysis will be performed over an explicitly-specified time interval (likely in the past).
### Real Time Versus Retrospective Analysis


###
