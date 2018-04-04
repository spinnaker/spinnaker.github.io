---
layout: single
title:  "Create and use filter templates"
sidebar:
  nav: guides
---

{% include toc %}

You can create sets of filters to apply against time series returned by your
telemetry provider. These filters can also be parameterized, then hydrated by
values provided in the [canary
stage](/guides/user/canary/stage/#extended-params).

## Things to keep in mind

* Each filter template you create for a given canary configuration is available
to each individual metric you add.

* The query against your metrics is the metric type _plus_ selectors that refine
what is returned in the time series.

   For Spinnaker canary purposes, the filter template contains only those
   refining selectors. The metric type is provided by the list of metrics above.

* The purpose of the metric filter is to allow you to parameterize what
is in these refining selectors, but it is perfectly legal to user literal
values in filter templates.

## Create a filter template

1. In the [canary configuration](/guides/user/canary/config/), find the __Filter
Templates__ section, and click __Add Template__.

1. Provide a name.

   This name is then populated in the __Configure Metric__ dialog for each
   individual metric in this config.

   ![Simple query template](/guides/user/canary/config/filter_templates/configure_metric_dialog.png)

1. In the __Template__ field, enter the filter.

   ![Simple query template](/guides/user/canary/config/filter_templates/a_filter_template.png)

## Apply filter templates to metrics

1. For any metric in this configuration, click the edit icon.

1. Click the __Filter Template__ field, and select the template you want to
apply to time series using this metric.

## Provide runtime values for parameterized filters

1. In the [canary stage config](/guides/user/canary/stage/), under __Extended
Params__, click __Add Field__.

   This will create a value for one parameter.

2. Under __Key__, type a variable you used in a filter template in the config
this stage is using.

3. Add the value you want for that variable.

![](/guides/user/canary/config/filter_templates/extended_params.png)
