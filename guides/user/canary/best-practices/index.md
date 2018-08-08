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
baseline, with both deployed together.

The baseline uses the same version and configuration that is currently running
in production, but is otherwise identical to the canary:

* Same time of deployment
* Same size of deployment
* Both receive the same amount of traffic

Doing this, you control for version and configuration only, and you reduce
factors that could affect the analysis, like the cache warmup time, the heap
size, and so on.

## Run the canary for a long-enough time

You need at least 50 data points for the statistical analysis to produce
accurate results for each metric. That is 50 data points per canary run, with
potentially several runs per canary analysis. In the end, you should plan for
canary analyses several hours long.

You will need to tune those parameters to your particular application. A good
starting point is to use a lifetime of 3 hours, an interval of 1 hour and no
warm-up period (unless you already know your application needs one). This gives
you 3 canary runs, each 1 hour long.


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
