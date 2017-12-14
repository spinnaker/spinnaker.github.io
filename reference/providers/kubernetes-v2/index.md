---
Layout: single
title:  "Kubernetes Provider V2 (Manifest Based)"
sidebar:
  nav: guides
---

{% include toc %}

This article describes how the Kubernetes provider v2 works, and how it differs from other providers in Spinnaker. If you're unfamiliar with Kubernetes terminology, see the [Kubernetes
documentation](https://kubernetes.io/docs/home/).

# The Manifest-Based Approach

The Kubernetes provider v2 combines the strengths of Kubernetes's [declarative
infrastructure
management](https://kubernetes.io/docs/tutorials/object-management-kubectl/declarative-object-management-configuration/)
with Spinnaker's workflow engine for imperative steps when you need them. You can fully specify all your infrastructure in the native Kubernetes manifest format but still express, for example, a multi-region canary-driven rollout. 

This is a significant departure from how deployments are managed in Spinnaker today using other providers (including the [Kubernetes
provider v1](https://www.spinnaker.io/reference/providers/kubernetes/)). The rest of this doc explains the difference.

## No Restrictive Naming Policies

You can deploy existing manifests without rewriting them to adhere to [Frigga](https://github.com/Netflix/frigga). Resource relationships (for example between applications and clusters) are managed using [Kubernetes annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/), and Spinnaker manages these using its [Moniker](https://github.com/spinnaker/moniker) library. 

The policies and strategies are configurable per account. See [Reserved Annotations](#reserved-annotations) for more detail.

## Accomodating Level-Based Deployments

See the [Kubernetes API
conventions](https://github.com/kubernetes/community/blob/master/contributors/devel/api-conventions.md#spec-and-status)
for a description of edge-based vs. level-based APIs.

Other providers in Spinnaker track operations that modify cloud resources. For example, if you run a resize operation, Spinnaker monitors that operation until the specified resize target is met. This is different from how the Kubernetes level-based API does  it: Kubernetes only tries to satisfy the desired state.

To take advantage of this, the Kubernetes provider v2 assesses "manifest stability." A deployed manifest is considered stable when the Kubernetes controller-manager no longer needs to modify it, and it’s deemed “ready.” This assessment is different, obviously, for different `kind`s of manifests: a `deployment` is stable when its managed pods are updated, available, and ready (running your desired container and serving traffic). A `service` is stable once it is created, unless it is of type `LoadBalancer`, in which case it is considered stable once the underlying load balancer has been created and bound to the `Service`.

This manifest stability is how Spinnaker ensures that operations
have succeeded. Because there are a number of reasons why a manifest never
becomes stable (lack of CPU quota, failing readiness checks, no IP for a
service to bind...) every stage that modifies or deploys a manifest waits
until your affected manifests are stable, or it times out after a configurable
period.

## Deploying Manifests Stored Externally to Spinnaker

You can store and version your manifest definitions in Git (or elsewhere outside of the Spinnaker pipeline store).

With Spinnaker's Artifact mechanism, file modifications/creations
are surfaced as artifacts in pipeline executions. For example, you can
configure a pipeline that triggers either when...

* a new Docker image is uploaded, or
* your manifest file is changed in Git.

# Reserved Annotations

Serveral annotations are built into each manfest and cannot be used otherwise.

* `moniker.spinnaker.io/application`

  The application this resource belongs to. 

  This affects where the resource is accessible in the UI, and depending on your Spinnaker Authorization setup, can affect which users can read/write to this resource.

* `moniker.spinnaker.io/cluster`

  The cluster this resource belongs to. 

  This is purely a logical grouping for
  rendering resources in the UI and to help with dynamic target selection in
  Pipeline stages. For example, some stages allow you to select "the newest
  workload in cluster __X__". How you set up these groupings depends on your
  delivery needs.

* `moniker.spinnaker.io/stack`, and `moniker.spinnaker.io/detail`

  These simply provide ways to group resources using Spinnaker's
  cluster filters as well as apply policies such as [Traffic
  Guards](https://blog.spinnaker.io/can-i-push-that-building-safer-low-risk-deployments-with-spinnaker-a27290847ac4).

# Resource Mapping

Resource mapping between Spinnaker and Kubernetes constructs is a lot more
flexible than for other providers, because of how many types of resources Kubernetes supports. Also the Kubernetes extension mechanisms&mdash;called [Custom Resource Definitions (CRDs)](https://kubernetes.io/docs/concepts/api-extension/custom-resources/)&mdash;make it easy to build new types of resources, and Spinnaker accomodates that by making it simple to extend Spinnaker to support a user's CRDs.

## Workloads ≈ Server Groups

## Services, Ingresses ≈ Load Balancers

## NetworkPolicies ≈ Security Groups

