---
layout: single
title:  "Add a Canary stage to a pipeline"
sidebar:
  nav: guides
---

{% include toc %}


If you have [enabled canary for your application](/setup/canary/) and have one
or more [canary configs prepared](), you can now add a canary stage to your
pipeline and configure it to perform canary analysis for your deployment,
against the target environment.

This stage type is for the canary _analysis_. The canary _deployment_ is specified
upstream from this stage.

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

You can also




## Configure the canary stage

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
     executes.

     For __Real Time__, also specify the number of hours to run (__Lifetime__).

   * __Retrospective__

     Analysis occurs over some specified period. Typically, this is done
     for a time period in the past, against a baseline deployment and a canary
     deployment which have already been running before this canary analysis
     stage starts.

1. Specify the analysis configuration:

   * Choose the __Config Name__.

     This is the canary config you created [here](). That configuration must be
     created within this same application, unless your Spinnaker is set up so
     that all canary configurations are available to all pipelines.

   * If you're running a __Real Time__ analysis, set a __Delay__.

     This is the number of minutes to wait before starting the analysis. This
     gives both the baseline and canary a chance to get warmed up before they're
     expected to provide meaningful  metrics. Leave blank for a delay of zero
     minutes.

   * Set a __Delay__.

     For real-time analyses, how many minutes to wait before starting the
     analysis. The gives both the baseline and canary a chance to get "warmed
     up" before they're expected to provide meaningful metrics.

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

   You can enter server groups and regions by name, but you can also click the
   magic wand here to automatically populate them with pipeline expressions that
   resolve to those names, from an upstream Clone Server Group stage.

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

   * __Extended Params__

     Add any additional parameters, which are specific to the metric sources and
     which can be used to refine the scope of the analysis. These parameters can
     provide variable bindings for use in the expansion of custom filter
     templates [specified in the canary config](/guides/user/canary/config/).

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
