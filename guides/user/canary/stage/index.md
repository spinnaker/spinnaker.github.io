against the target environment.
---
layout: single
title:  "Add a canary stage to a pipeline"
sidebar:
  nav: guides
---

{% include toc %}


If you have [enabled canary for your application](/setup/canary/) and have one
or more [canary configs prepared](/guides/user/canary/config/), you can now add
a canary stage to your pipeline and configure it to perform canary analysis for
your deployment,

This stage type is for the canary _analysis_ only. The canary stage doesn't
perform any provisioning or cleanup operations for you. Those must be configured
elsewhere in your pipeline

## About the canary stage

The canary analysis can be performed over data points collected beginning from
the moment of execution and into the future, or it can be performed over a
specified time interval.

### Real-time versus retrospective analysis

A real-time analysis means that the canary analysis is performed over a time
interval beginning at the moment of execution. In a retrospective analysis the
canary analysis is performed over an explicitly specified time interval (likely
in the past).

### Metric scope

Metric scope is the where and when for your canary analysis. It describes the
specific baseline and canary server groups, the start and end times and interval,
and the cloud resource on which the baseline and canary are running.

You can also refine the scope using [extended params](#extended-params).

## Define the canary stage

<!-- something here about where in the pipeline you'd put the canary stage, and
other permutations, like multiple stages? -->

1. In the pipeline in which you will run the canary, click __Add stage__.

   This pipeline needs to be in an application that has access to the [canary
   configuration](/guides/user/canary/config/) you want to use.

1. For __Type__ select __Canary__.

1. Give the stage a name, and use the __Depends On__ field to position the stage
downstream of its dependencies.

   ![Canary stage declaration](/guides/user/canary/stage/canary_stage_top.png)

1. Select the __Analysis Type__&mdash;either __Real Time__ or __Retrospective__.

   * __Real Time__

     The analysis happens for a specified time period, beginning when the stage
     executes (or after a specified __Delay__).

     For __Real Time__, also specify the number of hours to run (__Lifetime__).

   * __Retrospective__

     Analysis occurs over some specified period. Typically, this is done
     for a time period in the past, against a baseline deployment and a canary
     deployment which have already been running before this canary analysis
     stage starts.

     Note that this analysis might analyze data for resources which no longer
     exist, for which there are still published time series.

1. Specify the analysis configuration:

   * Choose the __Config Name__.

     This is the canary config you created [here](/guides/user/canary/config).
     That configuration must be visible to this application. By default, all
     configs are visible to all applications, but your canary might be [set up
     so that each config is limited]() to the application in which it is created.

   * Set a __Delay__.

     For real-time analyses, how many minutes to wait before starting the
     analysis. The gives both the baseline and canary a chance to get "warmed
     up" before they're expected to provide meaningful metrics. Leave blank for
     a delay of zero minutes.

   * Set the __Interval__.

     This is how frequently (in minutes) to capture and score the metrics.

   * For __Analysis Type__, select __Growing__ or __Sliding Lookback__.

     - In a growing analysis, a judgment is taken every [interval] minutes, but
     each judgment goes all the way back to the beginning of the __Lifetime__.

     - A sliding Lookback also makes a judgment every [interval], but each
     judgment only looks at the data from the most recent lookback duration.
     It would not be unusual for the __Interval__ and the __look-back__
     duration to be the same, but they don't have to be.

   ![Canary stage declaration](/guides/user/canary/stage/stage_config_analysis.png)

1. Describe the metric scope.

   > You can enter server groups and regions by name, but you can also click the
   > magic wand here to automatically populate the fields with expressions that
   > resolve to available resources. Those resources are a starting point, which
   > you can edit to match the specific resources you need.

   * __Baseline__

     The server group to treat as the "control" in the canary
     analysis&mdash;that is, the deployment against which to compare the canary
     deployment.

   * __Baseline Region__

     The region in which the baseline server group is deployed.

   * __Canary__

     The server group to treat as the experiment in the analysis.

   * __Canary Region__

     The region in which that canary server group is deployed.

   * __Step__

     The interval, in seconds, for the metric time series.


   * __Start Time__ and __End Time__ (for retrospective)

     For a retrospective analysis, the specific time span over which to conduct
     the analysis.

   * <a name="extended-params" />__Extended Params__

     Add any additional parameters, which are specific to the metric sources and
     which can be used to refine the scope of the analysis. These parameters can
     provide variable bindings for use in the expansion of custom filter
     templates [specified in the canary
     config](/guides/user/canary/config/filter_templates/).

   ![Canary stage declaration](/guides/user/canary/stage/metric_scope.png)

1. Adjust the __Scoring Thresholds__, if needed.

   The thresholds are pre-populated based on those configured in the main
   [canary config](/guides/user/canary/config/), but you can override them here.

1. Specify the accounts you're using for metrics and storage.

   * The __Metrics Account__ points to the telemetry service provider account
   you configured [here]().

   * The __Storage Account__ points to the GCS or S3 account you configured
   [here]().

   ![Canary stage declaration](/guides/user/canary/stage/advanced_settings.png)

   ## Time scope in the canary stage

   When you define your canary stage, you have a lot of choices about how to
   manage the analysis over time, beginning with the analysis type:

   * real time

   * retrospective

   So let's think about it in those two categories...

   ### Real-time analysis


   ### Retrospective analysis
