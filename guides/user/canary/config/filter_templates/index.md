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

Each filter template you create for a given canary configuration is available
to each individual metric you add. The template includes...

* The template itself, which is the filtering metadata portion of the
query/filter.  

![Simple query template](/guides/user/canary/config/filter_templates/a_filter_template.png)

* A name, by which it's identified in the __Configure  Metric__ dialog

![Simple query template](/guides/user/canary/config/filter_templates/configure_metric_dialog.png)
