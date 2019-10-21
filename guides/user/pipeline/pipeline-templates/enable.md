---
layout: single
title:  "Enable Pipeline Templates"
sidebar:
  nav: guides
---

{% include toc %}

## Enable the feature

```
hal config features edit --pipeline-templates true
hal deploy apply
```