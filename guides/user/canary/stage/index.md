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

### Real Time Versus Retrospective Analysis

A real-time analysis means that the canary analysis is performed over a time
interval beginning at the moment of execution. In a retrospective analysis the
canary analysis is performed over an explicitly specified time interval (likely
in the past).



## Configure the canary stage

1. In the pipeline in which you will run the canary, click __Add stage__.

   This pipeline needs to be in an application that has access to the [canary
   configuration](/guides/user/canary/config/) you want to use.

1. For __Type__ select __Canary__.

1. Give the stage a name, and make sure any upstream stages that need to be run
before this stage are listed.

   ![Canary stage declaration](/guides/user/canary/stage/canary_stage_top.png)

1. Select the __Analysis Type__&mdash;either __Real Time__ or __Retrospective__.

   Use __Retrospective__ if this analysis will be done over a specified time
   period, rather than _for_ a specified time interval. Typically, this is done
   for a time period in the past, against a baseline deployment and a canary
   deployment which have already been running before this canary analysis stage
   starts.

1. Set the __Lifetime__ (in hours) for this canary run.

1. Choose the configuration.

   This canary configuration must be created within this same application, unless
   your Spinnaker is set up so that all canary configurations are available to
   all pipelines.

1. Set a __Delay__, an __Interval__, and the __Analysis Type__.

   * The delay is how many minutes to wait before starting the analysis. This gives both
   the baseline and the canary a chance to get "warmed up" before they're expected
   to provide meaningful metrics.

   * The interval is how frequently (in minutes) to capture the metrics and score
   them.

     The __Lifetime__ divided by the  __Interval__ determines how many times the
     canary is run. If the __Interval__ is greater than the __Lifetime__, only
     one canary is run.

   * For __Analyisis Type__, select __Growing__ to consider the entire __Lifetime__
   of the canary. Select __Sliding Lookback__ to consider only

     In a growing analysis, a judgment is taken every (interval) minutes, but each
     judgment goes all the way back to the beginning of the lifetime.

     A sliding Lookback also makes a judgment every interval, but each judgment
     only looks at the data from the most recent lookback duration. It would not
     be unusual for the __Interval__ and the __look-back__ duration to be the same,
     but they don't have to be.











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
