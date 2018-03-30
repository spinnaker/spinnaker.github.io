---
layout: single
title:  "Best Practices for Configuring canary"
sidebar:
  nav: guides
---

{% include toc %}


## Don't put too many metrics in one group
Especially for critical metrics, if you have many metrics in the group and one
critical metric fails, but the rest pass, the group gets a passing score overall.

You can put a critical metric in a group of only one to ensure that if it fails,
the whole group fails every time.

##  
