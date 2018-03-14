---
layout: single
title:  "Add a Canary stage to a pipeline"
sidebar:
  nav: guides
---

{% include toc %}


If you have [enabled canary for your application]() and have one or more [canary
configs prepared](), you can now add a canary stage to your pipeline and
configure it to perform canary analysis for your deployment, against the target
environment.

## About the canary stage

The canary analysis can be performed over data points collected beginning from
the moment of execution and into the future, or it can be performed over a
specified time interval.

A Real Time analysis means that the canary analysis will be performed over a time interval beginning at the moment of execution.

The Retrospective analysis type means that the canary analysis will be performed over an explicitly-specified time interval (likely in the past).

### Real Time Versus Retrospective Analysis


## What's in the canary stages

Besides the name, and other common stage options, a canary stage includes the following information:

* __Analysis type__

  [Retrospective or Real Time]()

* The configuration which this stage uses

  From the [configurations you've created]() for the current application.

* __Metric Scope__

  including...

  - server groups and regions for baseline and canary

  - __Step__ interval

  - start and end times (for  retrospective)

  - the __Resource type__

    AWS EC2 instance, GCE instance, and so on

  - metric source-specific parameters to further refine the scope

    For example, ;alkdjf;lkajd

* Overrrides for scoring thresholds

  The thresholds are [defined in the canary configuration](), but can be overidden here.

* The account on your metrics provider, the source of the telemetry

* The account for [your storage service](/setup/install/storage/)
