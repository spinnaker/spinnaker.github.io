---
layout: single
title:  "Configure Canary for an application"
sidebar:
  nav: guides
---

{% include toc %}

Before you can add a canary stage to a pipeline, you need to configure what the
canary will consist of:

* The specific metrics to evaluate, and a logical grouping of those metrics
* Optionally, one or more filter templates
* Default scoring thresholds, per metric group, which can be overridden in the
canary stage
* A name by which a canary stage can choose this config

Canary configuration is done within an application. for each application that will
use canary, you'll create one or more configs.

Your Spinnaker might also be set up so that all
configurations are available to all applications. This configuration is available
to canary stages in pipelines, but those [stages are defined
separately](guides/user/canary/stage/).

<!---
TODO: figure out why this is done and how it's used
--->
Separately, you can [group individual metrics by StackDriver resource types](#group_the_metrics).

## Prerequisites

By default, canary is not enabled for new applications. Several things need to
happen before you see the __Canary__ tab in Deck:

* The person setting up Spinnaker for you must [set up Canary](/setup/canary/).

  This includes specifying whether all canary configs are available to all
  applications or each application can have one or more configurations that are
  visible to that application only.

* In the Application config, you need to activate the __Canary__ option.

  You need to do this for all applications that will use canary.

{%
 include
 figure
 image_path="./enable_canary.png"
%}

## Create a canary configuration

You can create as many of these as you like, and when you create a canary stage,
you can select which configuration to use. Configurations you create within an
application are available to all pipelines in that application, but your
Spinnaker might be set up so that all configurations are available to all
pipelines.

1. Select the __Canary__ tab at the top-right.

1. Select __Add configuration__.

1. Provide a __Name__ and __Description__.

   This is the name shown in the stage config when you create a canary stage for your
   pipeline.

1. Add metrics (and group them), and specify scoring thresholds and weights, as
described below.

1. Define the scoring thresholds and weights to be used across all metric groups
in this configuration.

## Create metric groups and add metrics

The metrics available depend on the telemetry provider you use. Spinnaker
currently supports StackDriver only.

Metrics are evaluated even if they're not added to groups, but if you want to
apply the weighting that determines the relative importance of different metrics,
you need to [add them to groups](#group_metrics).

1. In the __Metrics__ section, select __Add Metric__.

1. Give the metric a name.

   You're going to want to be able to select this from a drop down when you add
   a canary stage to your pipeline.

1. Specify whether this metric fails when the value deviates too high or too low.

  Or select __either__, in which case it fails on deviation in either direction.

1. Optionally, choose a [filter
template](/guides/user/canary/config/filter_templates/).

   This is only available  if your Spinnaker is [configured for it](). Filter
   templates are collections of [StackDriver monitoring
   filters](https://cloud.google.com/monitoring/api/v3/filters).

   Here's an example:

   ```
   resource.type = "gce_instance" AND
   resource.labels.zone = starts_with("${zone}")
   ```
1. Optionally, click __Group by__ and enter the metric metadata attribute by
which to group and aggregate the data.

    StackDriver lets you [group time series by resource and metric labels](), and
    then aggregate the data under those groups.

    > __Metric groups versus grouping metrics__
    >
    > When you create a canary configuration, you create metric groups, and scoring
    > thresholds and weights are applied to groups (rather than to specific metrics).
    > But you can also group metrics by resource type, as described [below](##group_the_metrics).

## Group the metrics

If you're using StackDriver, you can
[group metrics by resource groups](https://cloud.google.com/monitoring/groups/).

For example, when you create a metric you can choose to group it by Region.
StackDriver then returns timeseries for each region, separately.
