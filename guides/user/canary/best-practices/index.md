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
