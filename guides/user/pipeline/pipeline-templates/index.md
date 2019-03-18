---
layout: single
title:  "Using Pipeline Templates"
sidebar:
  nav: guides
---

{% include toc %}

Pipeline Templates are a way to standardize and distribute reusable Pipelines
across your team or among multiple teams.

You can share these templates within a single application, across different
applications, or even across different deployments of Spinnaker itself.

> **Note**: You can use `spin` CLI to manage pipelines and pipeline templates,
> but first you need to [install it](/guides/spin/cli/).

## Structure of a pipeline template

The underlying structure of a pipeline template is very close to the pipeline
JSON configuration format viewable in the Deck UI. But it includes information
that describes the parameterization of the template

## The high-level process

Here's what it's going to be like, creating and managing pipeline templates:

1. Create a pipeline, or find an existing one, that is similar to the template
you want to create.

1. Turn that pipeline into a template

   To do this, you use variables. 

1. 