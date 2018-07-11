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

## 1.9.0 (Feature-freeze 2018-08-06)

Our goal for this release is to double down on testing & documentation,
improving stability & usability of existing features in place of writing new
ones.

### Kubernetes

* Simplify process for registering & deregistering new accounts by allowing GKE
  credentials to manage the list of clusters configured in Spinnaker. This can be
  extended to AKS & EKS as well.
* Round out integration test coverage.

### Artifacts

* Determine and implement contracts for CI systems supplying artifacts to
  Spinnaker. This will improve artifact traceability in Spinnaker, and surface
  relevant CI context on Pipelines and infrastructure.
* Round out integration test coverage.

### Entity tags

* Address gaps in OSS [entity tag](/guides/user/tagging/) support, including
  installation, configuration, and provider support.

### Halyard

* Begin planning a Spinnaker-integrated "Halyard UI" to allow users (not
  necesssarily operators) of Spinnaker to edit select parts of the
  configuration. This is intended to reduce the operator burden of Spinnaker,
  and provide an admin control panel to Spinnaker to users based on permission.
  
  If you are interested in either being an early user, or contributing to the
  design or implementation, talk to us in the `#dev` channel in
  [Slack](http://join.spinnaker.io).

### GCE

Continue stabilizing the GCE provider in Spinnaker and converging on feature
parity with the platform.

* Implement integrations for GCE alpha features.
* Round out integration test coverage.

### Canary

Support deploying the baseline & canary clusters automatically as a part of the
canary analysis stage.

### CLI (spin)

Reduce friction of automating workflows that programmatically interact with
Spinnaker's API

* Support authentication.
* Harden the error handling in the API flows the CLI exercises.
* Harden the API surface the CLI interacts with.
* Round out integration test coverage.

### Orca

Support for an alternative SQL storage backend.

<span class="end-collapsible-section"></span>


