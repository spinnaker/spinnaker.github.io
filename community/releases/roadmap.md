---
layout: single
title:  "Roadmap"
sidebar:
  nav: community
---

The features listed here are delineated by their [Spinnaker release
version](https://www.spinnaker.io/community/releases/release-cadence/). We plan
our releases by dates rather than features to democratize the release process,
so it's possible that not all features planned make it into each release;
please treat this roadmap as aspirational.

<span class="begin-collapsible-section"></span>

## 1.8.0 (Feature-freeze 2018-06-11)

### Kubernetes

The goal is to release the v2 provider as "beta", meaning we will not introduce
breaking changes. We will continue to add features after this, however.

Along with the release, we hope to support:

* Baking helm templates into manifests to deploy them. This is the first
  templating engine we will support, in service of making multi-environment
  deployments in Spinnaker simpler.
* Better performance when deploying to multiple clusters and managing many
  resource kinds.

### Artifacts

Our goal is to simplify & make artifacts easier to understand/use as well as
further integrate artifacts within Spinnaker. To do so, we plan to:

* Provide better CI support for passing artifacts. This will allow for
  consistent referencing of artifacts in pipelines, no matter the CI provider.
* Support baking artifacts into images. This will allow for more flexible and
  expressive baking of VM images, and sets some of the groundwork for
  Dockerfile-based Docker bakes in Spinnaker.
* Improve UI support, surfacing more context in pipeline executions and
  configuration. This is intended to make Artifacts both more tactile, and
  understandable in pipeline executions by surfacing artifact relationships and
  details wherever possible.
* Add a stage for importing an artifact's contents into the stage’s context.
  This will allow users to pull data dynamically from any text-based artifact and
  build pipeline expressions in downstream stages to reference the contents.

### GCE

Continue stabilizing the GCE provider in Spinnaker and converging on feature
parity with the platform.

* Add support for dynamically populating available platform instance types by
  querying GCE.
* Scope out support for protocol forwarding in ILBs.
* Scope integrations for GCE alpha features.

### Canary

* Add additional documentation and guidance on getting started.
* Make it possible to configure shorter-lived canaries from the canary stage UI
  (the duration is presently specified in hours).
* Add type-ahead for configuring Datadog metric queries.

### CLI (spin)

Reduce friction of automating workflows that programmatically interact with
Spinnaker’s API

* Communicate a clear design plan with the community in the form of a design
  document.
* Leverage swagger spec generation to automate API client generation.
* Add 'alpha' support for managing pipelines and applications through the CLI,
  which means we may introduce breaking changes in the final version.

### General

* Improve setup process & instructions
* Produce canary/kubernetes codelabs that automate all setup

<span class="end-collapsible-section"></span>

<span class="begin-collapsible-section"></span>

## 1.9.0 (Feature-freeze 2018-08-06)

Our goal for this release is to double down on testing & documentation,
improving stability & usability of existing features in place of writing new
ones.

### Kubernetes

* Integrate with third-party docker builders in the "bake" stage
* Simplify process for registering & deregistering new accounts by allowing GKE
  credentials to manage the list of clusters configured in Spinnaker. This can be
  extended to AKS & EKS as well.

### GCE

Continue stabilizing the GCE provider in Spinnaker and converging on feature
parity with the platform.

* Implement integrations for GCE alpha features.
* Round out Citest nightly test coverage for GCE.

### Canary

Support deploying the baseline & canary clusters automatically as a part of the
canary analysis stage.

### CLI (spin)

Reduce friction of automating workflows that programmatically interact with
Spinnaker's API

* Support authentication.
* Harden the error handling in the API flows the CLI exercises.
* Harden the API surface the CLI interacts with.

### Orca

Support for an alternative SQL storage backend.

<span class="end-collapsible-section"></span>
