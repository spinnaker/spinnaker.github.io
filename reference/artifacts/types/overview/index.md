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

For information about how to use artifacts in pipelines, see [About Spinnaker Artifacts](https://www.spinnaker.io/reference/artifacts/).
