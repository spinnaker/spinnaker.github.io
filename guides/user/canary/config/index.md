---
layout: single
title:  "Configuring Canary for an application"
sidebar:
  nav: guides
---

{% include toc %}


This article shows how to create a configuration, which contains...

* A name by which a canary stage can choose this config
* The specific metrics to evaluate, and a logical grouping of those metrics
* Optionally, one or more filter templates
* Default scoring thresholds, per metric group, which can be overridden in the
canary stage

Canary configuration is done for an application, with one or more config sets
available to that application. Your Spinnaker might also be set up so that all
configurations are available to all applications.

## Metric groups versus grouping metrics
When you create a canary configuration, you create metric groups, and scoring
thresholds and weights are applied to groups (rather than to specific metrics).

<!---
TODO: figure out why this is done and how it's used
--->
Separately, you can [group individual metrics by StackDriver resource types](#group_the_metrics).

## Prerequisites

By default, canary is not enabled for new applications. Several things need to
happen before you see the __Canary__ tab in Deck:

* The person setting up Spinnaker for you must configure Canary.

  This includes specifying whether all canary configs are available to all
  applications or each application can have one or more configurations that are
  visible to that application only.

* In the Application config, you need to activate the __Canary__ option.

  {% include figure
     image_path="./enable_canary.png"
     caption="Enabling __Canary__ lets you configure canary analysis for all
     pipelines in this application, including multiple config sets."
  %}


## Create a new canary configuration

You can create as many of these as you like, and when you create a canary stage,
you can select which configuration to use.

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

The metrics are the basis for passing or failing a canary. Later on, you'll
specify default thresholds to use against these metrics.

Metrics must be [added to metric groups](#group_metrics) before you can apply
the weighting that determines the relative importance of metrics.

The metrics available depend on the telemetry provider you use. Spinnaker
currently supports StackDriver only.

1. In the __Metrics__ section, select __Add Metric__.

1. Give the metric a name.

   You're going to want to be able to select this from a drop down when you add
   a canary stage to your pipeline.

1. Specify whether this metric fails when the value gets too high or too low.

1. Optionally, choose a [filter template]().

1.



## Group the metrics

If you're using StackDriver, you can
[group metrics by resource groups](https://cloud.google.com/monitoring/groups/).

For example, when you create a metric you can choose to group it by Region.
StackDriver then returns timeseries for each region, separately.
