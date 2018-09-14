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

# 1.10.0 (Feature-freeze 10-01-18)

## Artifacts

We are continuing to improve artifact support in Spinnaker, along two major
threads of work:
* Improve the ability to pass build artifacts from CI systems to Spinnaker
* Add information on artifact provenance to Spinnaker workflows

## Canary

We are working on stages that provision the infrastructure necessary to perform
a canary (both the baseline and canary clusters) to make configuration easier
and reduce duplication in pipelines. This is currently targeted only at
VM-based providers, but Kubernetes support will come in a later release.

## Kubernetes

In order to better surface relevant information in the Spinnaker UI, we are
spending much of this release improving and reworking the Infrastructure tab
for Kubernetes resources. The goal is to make the [new Kubernetes
  provider](/setup/install/providers/kubernetes-v2) a first-class citizen of
  the frontend. This includes:

* Better representation of the `deployment` object, as it is core to much
  release automation and has so far been confusing to interact with in the
  current UI.
* Surfacing of container-level metrics to give insight into the state of an
  application.
* Adding a proper YAML-editor to make changes to existing resources and
  pipelines easier to perform.

## Cloud Foundry

Pivotal has reworked the Cloud Foundry provider implementation. The provider
uses Frigga to name assets and provides a multi-foundation view of applications
and clusters based on this naming convention. The provider implementation
supports declarative and manifest-based configuration in the deployment stage.
It supports red/black, highlander, and none deployment strategies along with
rollback, resize, enable/disable server group actions and a terminate instance
action. The provider also supports promotioning clusters via droplet-based
deployments.

The 1.10.0 release will contain a preview of this Cloud Foundry support.
Expect a backward-incompatible change to Deploy stage configuration in a future
release, once Spinnaker's expected-artifact model improves to the point that
Cloud Foundry artifacts and manifests can be fully satisfied by expected
artifacts. The Cloud Foundry provider should be viewed as incubating until
then.

## GCE

We're continuing to stabilize the GCE provider as well as add features to
keep parity with the platform offerings. We’re also improving the provider’s
performance at scale.

* Consider GCE deployment successful when X% of instances are healthy
* Surface MIG activity (e.g. instance launch failures) in the UI
* Support for autoscaling in GCE deploy stage
* Reduce Clouddriver caching load on redis

## Orchestration

Support for an alternative SQL storage backend.

<span class="end-collapsible-section"></span>


