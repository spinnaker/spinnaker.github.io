---
layout: single
title:  "Spin and Roer + Managed Pipeline Templates"
sidebar:
  nav: guides
---

{% include toc %}

## Foreward

Users are often interested in learning how to codify Spinnaker configuration
'as-code', whether in conjunction with automating their team onboarding process
or just managing and versioning Spinnaker configuration.

A related question that also arises is:
"What is the recommended way to programmatically interact with Spinnaker?"

This document is meant to describe two Spinnaker features meant to
address the two preceding questions: Managed Pipeline Templates/`roer`
and the new `spin` CLI.

## Managed Pipeline Templates and `roer`

### What it is

Managed pipeline templates (MPT) is a capability in Spinnaker to
formulate pipelines as an extended form of Jinja templates
to allow for templating via variable bindings as well as
inheritance. The spec for MPT is [here](https://github.com/spinnaker/dcd-spec/blob/master/PIPELINE_TEMPLATES.md).
The template rendering is done server side in Orca.

Pipeline templates themselves can be managed through Deck or through
[`roer`](https://github.com/spinnaker/roer), a small CLI for manipulating
pipeline templates.

### What it isn't

MPT and `roer` are scoped strictly to make managing Spinnaker pipelines
easier. It is not a generic solution to make API calls to Spinnaker.

### Where it's going

MPT and `roer` are not going away anytime soon. Plenty of folks
happily use `roer` and MPT.

That being said, it's not actively being developed -- we are
not adding new features.

MPT has provided valuable lessons on what works well and what doesn't,
both from a feature and maintenance perspective.

For instance -- while a powerful feature, supporting server-side rendering
in MPT has proven to be fairly challenging for a two reasons:

1. Extended Jinja templating requires complex processing wrapping
the call to Jinja. This complicates the pipeline execution
code path pretty dramatically.

1. Interactions between Jinja and Spinnaker's Spring Expression Language (SPEL)
support in pipelines have caused a lot of edge cases that are
challenging to reproduce and debug, and has often resulted in strange behavior
for users.

Challenges like this give us excellent insight into not only what users
find powerful, but also what is maintainable and robust from a design/implementation
perspective.

## `spin`

### What it is

`spin` is a CLI to interact with Spinnaker via the Gate API. It is
currently in alpha, so the breadth of the interface is limited to managing
pipeline and application config. Since `spin` is meant to be an API wrapper,
it accepts JSON payloads and submits authenticated calls to Gate.

It is meant to generically address the problem of automating flows that call the Spinnaker API.

### What it isn't

`spin` is not scoped strictly to solve the problem of managing Spinnaker
pipelines. Submitting pipelines is only one of `spin`'s supported workflows.

### Where it's going

The surface area of `spin` is meant to grow with user demand of new automation flows.
As an example, one prospective extension is to submit generic tasks to Gate
for Orca to orchestrate.

## Future Work

We have gained valuable experience and insight from writing `roer`, MPT, and `spin`.

We'll continue to grow `spin`'s adoption by expanding API coverage, hardening, and
improving usability.

We'll continue maintenance and bug fix support for MPT and `roer`, while using the lessons we learned to
inform design work on the next generation solution for managing Spinnaker pipelines at scale.

Pipeline management is a topic we are actively gathering information about and looking into.
The next-generation "solution" will certainly leverage `spin` for support, but untimately
will required features and above and beyond just `spin` to create the best user experience

We encourage users and developers alike to share any ideas and contributions they have in
this space. [Reach out to us on slack](https://join.spinnaker.io/)!
