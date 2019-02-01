---
layout: single
title:  "Using Pipeline Templates"
sidebar:
  nav: guides
---

{% include toc %}

Pipeline Templates are a way to standardize and distribute reusable Pipelines.

You can share these templates within a single application, across different
applications, or even across different Spinnaker deployments.

The underlying structure of a pipeline template is very close to the pipeline
JSON configuration format viewable in the Deck UI.

## The high-level process

Here's what it's going to be like, creating and managing pipeline templates:

1. Create a pipeline, or find an existing one, that is similar to the template
you want to create.

1. 