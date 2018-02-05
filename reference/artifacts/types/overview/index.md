---
layout: single
title:  "Types of Artifacts"
sidebar:
  nav: reference
---

While an artifact can reference any remote, deployable resource, we have
first-class support for in the form of:

* Parsing events from other services. For example, reading pub/sub messages
  from GCR images.

* Credentials for downloading artifacts. For example, a GitHub access token to
  read repository contents.

* Integrations with stages that require certain types of artifacts. For
  example, App Engine can only deploy a Docker image as a custom runtime, never
  an AMI.

The pages in this section serve to document the format Spinnaker expects these
artifacts in, to make custom integrations with them easier. We recommend
reading the [artifact format](/reference/artifacts/#format) first.

These pages _do not_ give concrete guides or practices for automatically
sending or injesting artifacts in pipelines. Those can be found in the
[guides](/guides) pages.
