---
layout: single
title:  "Overview"
sidebar:
  nav: setup
---

Spinnaker can listen to events, and collect artifacts produced by builds in
external Continuous Integration (CI) systems. These events can trigger
Pipelines, and the artifacts can be used by Spinnaker's image bakery to produce
machine images. 

For example, the [Source to
Prod](/guides/tutorials/codelabs/gce-source-to-prod/) codelab configures a
Jenkins Job to produce a Debian package as an artifact that is handed to
Spinnaker to build a VM image which Spinnaker deploys.

Currently, Spinnaker supports several CI systems which can be enabled and run
independently of one-another, enumerated below.

## Supported CI systems

These are the CI systems currently supported by Spinnaker:

* [Google Cloud Build](/setup/ci/gcb/)
* [Jenkins](/setup/ci/jenkins/)
* [Travis CI](/setup/ci/travis/)
* [Wercker](/setup/ci/wercker/)

See also [`hal config ci`](/reference/halyard/commands/#hal-config-ci).
