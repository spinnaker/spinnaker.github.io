---
layout: single
title:  "Using Pipeline Templates"
sidebar:
  nav: guides
---

{% include toc %}

Pipeline Templates help you standardize and distribute reusable Pipelines
across your team or among multiple teams.

You can share these templates with your teams within a single application,
across different applications, or even across different deployments of
Spinnaker itself.

> **Note**: You can use `spin` CLI to manage pipelines and pipeline templates,
> but first you need to [install it](/guides/spin/cli/).

## Structure of a pipeline template

The underlying structure of a pipeline template is very close to the pipeline
JSON configuration format viewable in the Deck UI. But it includes information
about the variables the template uses.

## The things you can do with pipeline templates

* [Create a template](/guides/user/pipeline/pipeline-templates/create/) based
on an existing pipeline.

* [Share the template](/guides/user/pipeline/pipeline-templates/distribute/)
with one or more teams of Spinnaker users.

* [Create pipelines based on a
template](/guides/user/pipeline/pipeline-templates/instantiate/). 

* [Use the `spin` CLI to plan how to parameterize the
template](/guides/user/pipeline/pipeline-templates/parameterize/#visualize-the-hydrated-pipeline),
by visualizing a hydrated pipeline. 

* [List and get pipeline templates](/guides/user/spin/pipeline-templates/).