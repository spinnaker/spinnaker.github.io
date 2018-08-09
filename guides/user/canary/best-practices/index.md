---
layout: single
title:  "Best practices for configuring canary"
sidebar:
  nav: guides
---

{% include toc %}


## Don't put too many metrics in one group

Especially for critical metrics, if you have many metrics in the group and one
critical metric fails, but the rest pass, the group gets a passing score overall.

You can put a critical metric in a group of only one to ensure that if it fails,
the whole group fails every time.

## Compare canary against baseline, not against production

You might be tempted to compare the canary deployment against your current
production deployment. Instead always compare the canary against an equivalent
baseline, deployed at the same time.

The baseline uses the same version and configuration that is currently running
in production, but is otherwise identical to the canary:

* Same time of deployment
* Same size of deployment
* Both receive the same amount of traffic

In this way, you control for version and configuration only, and you reduce
factors that could affect the analysis, like the cache warmup time, the heap
size, and so on.

## Run the canary for enough time

You need at least 50 pieces of time series data per metric for the statistical
analysis to produce accurate results. That is 50 data points per canary run,
with potentially several runs per canary analysis. In the end, you should plan
for canary analyses several hours long.

You will need to tune the time parameters to your particular application. A good
starting point is to have a canary lifetime of 3 hours, an interval of 1 hour
and no warm-up period (unless you already know your application needs one).
This gives you 3 canary runs, each 1 hour long.

## Carefully choose your thresholds

You need to configure two thresholds for a canary analysis:

* marginal

  If a canary run has a score below than this threshold, then the whole canary
  fails.

* pass

  The last canary run of the analysis must score higher than this threshold for
  the whole analysis to be considered successful. Otherwise it fails.

These thresholds are very important for the analysis to give an accurate result.
You need to experiment with them, in the context of your own application, its
traffic and its metrics.

Good starting points:

* marginal threshold of 75
* pass threshold of 95

## Carefully choose the metrics to analyze

You can get started with a single metric, but in the long run, your canaries
will use several.

Use a variety of metrics that reflect different aspects of the health of your
application. Use these three out of the four "golden signals," as defined in
the [SRE Book](https://landing.google.com/sre/book/chapters/monitoring-distributed-systems.html):

* latency
* errors
* saturation

If you consider some other specific metrics critical, place them in their own
group in the canary configuration. That allows you to fail the whole canary
analysis if there is a problem with one of those specific metrics.

## Create a standard, resusable canary config

Configuring a canary is difficult, and not every developer in your organization
will be able to do so. Also, if you let all the teams in the org manage their
own configs, you will likely end up with too many configs, too many metrics,
nobody will know what is happening, and people will be afraid to change
anything.

For these reasons, it's a good idea to curate a config that all the teams can
reuse.

## Use retrospective analysis to make debugging faster

It takes a long time to configure a canary analysis. It can take a long time to
debug it too, partly because with [a long-running canary
analysis](#run-the-canary-for-a-long-enough-time) you have to wait a long time
for the analysis to finish before you can refine it.

Fortunately, a Canary Analysis stage can be configured to use a [retrospective
analysis](/guides/user/canary/stage/#real-time-versus-retrospective-analysis)
instead of a real-time analysis. This analysis is based on past monitoring data,
without having to wait for the data points to be generated. With this mode, you
can iterate more quickly on the development of the canary configuration.

## Compare equivalent deployments

To compare the metrics between baseline and canary, Kayenta needs the exact same
metrics for both. This means that metrics should have the same labels. Problems
can arise if the metrics are labeled with their respective instance names.

If you see that Kayenta is not actually comparing the metrics, confirm that the
queries that it does to your monitoring system return metrics with the same
labels.

If you're using Stackdriver, you can use the Google [APIs Explorer](https://developers.google.com/apis-explorer/#search/timeseries/m/monitoring/v3/monitoring.projects.timeSeries.list) to debug such problems.

## Some configuration values to start with

Although these values are not necessarily "best practices," they are reasonable
starting points for your canary configs:

| Setting | Value |
|-|-----------|
| canary lifetime | 3 hours |
| successful score | 95 |
| unhealthy score | 75 |
| warmup period | 0 minutes|
| frequency | 60 minutes |
| use lookback | no |
