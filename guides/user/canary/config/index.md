---
layout: single
title:  "Configure a canary"
sidebar:
  nav: guides
---

{% include toc %}

Before you can add a canary stage to a pipeline, you need to configure what the
canary consists of, including...

* A name by which a canary stage can choose this config
* The specific metrics to evaluate, and a logical grouping of those metrics
* Default scoring thresholds (which can be overridden in the
canary stage)
* Optionally, one or more filter templates

Canary configuration is done per Spinnaker
[application](/concepts/#applications). For each
application set up to support canary, you create one or more configs.

> Note: By default, all the canary configs you create are visible to all
applications. But you can [change
that](/setup/canary/#specify-the-scope-of-canary-configs).

The configuration you create here is available to canary stages in pipelines,
but those [stages are defined separately](/guides/user/canary/stage/).


## Prerequisites

By default, canary is not enabled for new applications. Several things need to
happen before you see the __Canary__ tab in Deck:

* The person or people setting up Spinnaker for you must [set up
Canary](/setup/canary/).

  This includes [specifying](/setup/canary/#specify-the-scope-of-canary-configs)
  whether all canary configs are available to all applications (the default) or
  each application can have one or more configurations that are visible to that
  application only.

* In the Application config, activate the __Canary__ option.

  Do this separately for all applications that will use automated canary
  analysis.

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
applications.

1. Hover over the __Delivery__ tab, and select __Canary configs__.

   ![Select __Canary__ from the __Delivery__ menu.](/guides/user/canary/config/delivery_menu_canary.png)
1. Select __Add configuration__.

1. Provide a __Name__ and __Description__.

   This is the name shown in the stage config when you create a canary stage for
   your pipeline.

1. (Optional) select your telemetry provider from the __Metric Store__ dropdown.

   If you have only one provider set up, this is not a drop-down.

   ![Canary config declaration](/guides/user/canary/config/canary_config_create.png)

The sections below describe how to specify the metrics and the scoring thresholds
and weights.

### Create metric groups and add metrics

The metrics available depend on the telemetry provider you use. Spinnaker
currently supports [Stackdriver](https://cloud.google.com/Stackdriver/),
[Prometheus](https://Prometheus.io), and [Datadog](https://www.datadoghq.com).

Metrics are evaluated even if they're not added to groups, but if you want to
apply the weighting that determines the relative importance of different metrics,
you need to [add them to groups](#create-metric-groups-and-add-metrics).

1. Create any groups you want to organize the metrics into.

   Data is evaluated for all metrics, but metrics scores only affect the canary
   evaluation for metrics that are grouped here.

   Click __Add Group__ to create each group you'll use. Then select the group
   and click the edit icon to name it.

   For example, you might create a group called "cpu" and add a set of
   CPU-related metrics. Then when you configure a new metric here, you would
   select "cpu" for the CPU-related metrics you add.

1. In the __Metrics__ section, select __Add Metric__.

1. Select the group to add this metric to.

1. Give the metric a name.

1. Specify whether this metric fails when the value deviates too high or too low
compared to the baseline.

   Or select __either__, in which case it fails on deviation in either direction.

1. Optionally, choose a [filter
template](/guides/user/canary/config/filter_templates/).

   This is only available  if your Spinnaker is
   [configured for it](https://www.spinnaker.io/reference/halyard/commands/#hal-config-canary-edit).

   Here's an example:

   ```
   resource.type = "gce_instance" AND
   resource.labels.zone = starts_with("${zone}")
   ```

1. Identify the specific metric you're including in the analysis configuration:

   * In the __Metric Type__ field type at least 3 characters to populate the
   field with available metrics.

     For example, if you type `cpu` you get a list of metrics available from
     your telemetry provider.

     ![List of available metrics](/guides/user/canary/config/metric_type_list_cpu.png)

1. Optionally, if your telemetry provider supports aggregation of results, click
__Group by__ and enter the metric metadata attribute by which to group and
aggregate the data.

   For example, when you create a metric you can group its time series by
   resource or metric label. You can group a time series by zone, for example
   (`resource.zone`).  This is supported in
   [Stackdriver](https://cloud.google.com/monitoring/charts/metrics-selector#groupby-option)
   and [Prometheus]() only.

   > __Metric groups versus grouping metrics__
   >
   > When you create a canary configuration, you [create metric
   > groups](/guides/user/canary/config/#create-metric-groups-and-add-metrics),
   > and scoring thresholds and weights are applied to groups (rather than to
   > specific metrics). But the grouping described in this step is for
   aggregating metrics before they're returned to Kayenta.

1. Click __OK__ to save this metric.

   Your metric is now listed under the specific group you selected for it, and
   under __All__.

### Add filter templates

If your telemetry provider is Stackdriver or Prometheus, you can add [filter
templates](/guides/user/canary/config/filter_templates/) and then assign each
metric a filter template, if you want.

1. Click __Add Template__.

1. Provide a __Name__.

   This is the name by which you can select it when configuring the specific
   metric.

1. In the __Template__ field, enter an expression identifying the filter
template resource.

   This expression is resolved to the filter template resource using __Extended
   Params__ in any [canary
   stage](/guides/user/canary/stage/#define-the-canary-stage) that uses this
   configuration.

## Edit a configuration

1. On the __Delivery__ tab, select __Canary Configs__.

   All available existing configs are listed along the left margin. Note that
   the application that owns a config is shown under the name, in cases where
   configs are scoped to individual applications.

2. Select the config you want to edit.
