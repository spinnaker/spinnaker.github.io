---
Layout: single
title:  "Kubernetes Provider V2 (Manifest Based)"
sidebar:
  nav: guides
---

{% include toc %}

This reference material describes how the Kubernetes V2 provider works, and how it differs from other providers in Spinnaker. If you're unfamiliar with Kubernetes terminology, see the [Kubernetes
documentation](https://kubernetes.io/docs/home/).

# The Manifest-Based Approach

The Kubernetes provider V2 combines the strengths of Kubernetes's [declarative
infrastructure
management](https://kubernetes.io/docs/tutorials/object-management-kubectl/declarative-object-management-configuration/)
with Spinnaker's workflow engine for imperative steps when you need them. You can fully specify all your infrastructure in the native Kubernetes manifest format but still express, for example, a multi-region canary-driven rollout. 

This is a significant departure from how deployments are managed in Spinnaker today using other providers (including the [Kubernetes
provider v1](https://www.spinnaker.io/reference/providers/kubernetes/)). The rest of this doc explains the difference.

## No Restrictive Naming Policies

You can deploy existing manifests without rewriting them to adhere to [Frigga](https://github.com/Netflix/frigga).

Resource relationships (for example between applications and clusters) are managed using [Kubernetes annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/), and Spinnaker manages these using its [Moniker](https://github.com/spinnaker/moniker) library. The policies and strategies are configurable per account. See [reserved
annotations](#reserved-annotations) for more detail.

## Accomodating Level-based Deployments

See the [Kubernetes API
conventions](https://github.com/kubernetes/community/blob/master/contributors/devel/api-conventions.md#spec-and-status)
for a description of edge-based vs. level-based APIs.

Prior providers in Spinnaker focused on tracking an operation that modified a
cloud resource. For example, if a resize operation was run, Spinnaker
would monitor that operation until the specific resize target was met. This
runs counter to the Kubernetes level-based API, which only cares about the
desired state of a resource being satisfied. In order to address this, we
introduced the concept of __Manifest Stability__:

A deployed manifest is consided __stable__ when the Kubernetes
Controller-Manager no longer needs to modify it, and it is "ready". This
definition is clearly very dependent on the manifest's kind (e.g. `Service` vs.
`StatefulSet`), but for example, a `Deployment` is stable when its managed pods
are updated, available, and ready (meaning they are running your desired
container, and are serving traffic). Each kind's stability requirements are
detailed in the [Resource Mapping](#resource-mapping) section.

This concept of Manifest Stability is how Spinnaker ensures that operations
have succeeded. Since there are a number of reasons why a manifest never
becomes stable (lack of CPU quota, failing readiness checks, no IP for a
service to bind...) every stage that modifies or deploys a manifest will wait
until your affected manifests are stable, or timeout after a configurable
period.

## Deploying Manifests Stored Externally to Spinnaker

To allow users to store & version their manifest definitions in Git (or
elsewhere) outside of Spinnaker's pipeline store, we needed another way to
supply manifest definitions to Pipeline executions.

Using Spinnaker's new Artifact mechanism, we allow file modifications/creations
to be surfaced as artifacts in pipeline executions. For example, you can now
configure a pipeline that triggers either whenever 1. a new Docker image is
uploaded, or 2. your manifest file is changed in git.

# Reserved Annotations

* `moniker.spinnaker.io/application`

  The application this resource belongs to. Affects where the resource will be
  accessible in the UI, and depending on your Spinnaker Authorization setup,
  which users can read/write to this resource.

* `moniker.spinnaker.io/cluster`

  The cluster this resource belongs to. This is purely a logical grouping for
  rendering resources in the UI, and to help with dynamic target selection in
  Pipeline stages. For example, some stages allow you to select "the newest
  workload in cluster __X__". How you set up these groupings depends on your
  delivery needs.

* `moniker.spinnaker.io/stack`, and `moniker.spinnaker.io/detail`

  Stack and detail simply provide ways to group resources using Spinnaker's
  cluster filters as well as apply policies such as [Traffic
  Guards](https://blog.spinnaker.io/can-i-push-that-building-safer-low-risk-deployments-with-spinnaker-a27290847ac4).

# Resource Mapping

The resource mapping between Spinnaker and Kubernetes constructs is a lot more
flexible than for other providers, due to how many types of resources
Kubernetes supports. On top of that, Kubernetes' extension mechanisms, called
[Custom Resource Definitions
(CRDs)](https://kubernetes.io/docs/concepts/api-extension/custom-resources/),
make it easy to build new types of resources, and Spinnaker needs to accomodate
that by making it simple to extend Spinnaker to support a user's CRDs.

## Workloads ≈ Server Groups

## Services, Ingresses ≈ Load Balancers

## NetworkPolicies ≈ Security Groups

