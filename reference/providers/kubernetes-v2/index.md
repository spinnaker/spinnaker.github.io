---
Layout: single
title:  "Kubernetes Provider V2 (Manifest Based)"
sidebar:
  nav: reference
---

{% include alpha version="1.6" %}

{% include toc %}

This article describes how the Kubernetes provider v2 works and how it differs
from other providers in Spinnaker. If you're unfamiliar with Kubernetes
terminology, see the [Kubernetes
documentation](https://kubernetes.io/docs/home/).

# The manifest-based approach

The Kubernetes provider v2 combines the strengths of Kubernetes's [declarative
infrastructure
management](https://kubernetes.io/docs/tutorials/object-management-kubectl/declarative-object-management-configuration/)
with Spinnaker's workflow engine for imperative steps when you need them. You
can fully specify all your infrastructure in the native Kubernetes manifest
format but still express, for example, a multi-region canary-driven rollout.

This is a significant departure from how deployments are managed in Spinnaker
using other providers (including the [Kubernetes provider
v1](https://www.spinnaker.io/reference/providers/kubernetes/)). The rest of this
doc explains the differences.

## No restrictive naming policies

You can deploy existing manifests without rewriting them to adhere to
[Frigga](https://github.com/Netflix/frigga). Resource relationships (for example
between applications and clusters) are managed using [Kubernetes
annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/),
and Spinnaker manages these using its
[Moniker](https://github.com/spinnaker/moniker) library.

The policies and strategies are configurable per account. See [Reserved
Annotations](#reserved-annotations) for more details.

## Accommodating level-based deployments

See the [Kubernetes API
conventions](https://github.com/kubernetes/community/blob/master/contributors/devel/api-conventions.md#spec-and-status)
for a description of edge-based vs. level-based APIs.

Other providers in Spinnaker track operations that modify cloud resources. For
example, if you run a resize operation, Spinnaker monitors that operation until
the specified resize target is met. But because Kubernetes only tries to satisfy
the desired _state_, and offers a level-based API for this purpose, the
Kubernetes provider v2 uses the concept of "manifest stability."

A deployed manifest is considered stable when the Kubernetes controller-manager
no longer needs to modify it, and it’s deemed “ready.” This assessment is
different, obviously, for different `kind`s of manifests: a `Deployment` is
stable when its managed pods are updated, available, and ready (running your
desired container and serving traffic). A `Service` is stable once it is
created, unless it is of type `LoadBalancer`, in which case it is considered
stable once the underlying load balancer has been created and bound to the
`Service`.

This manifest stability is how Spinnaker ensures that operations have succeeded.
Because there are a number of reasons why a manifest never becomes stable (lack
of CPU quota, failing readiness checks, no IP for a service to bind...) every
stage that modifies or deploys a manifest waits until your affected manifests
are stable, or it times out after a configurable period (30-minute default).

## Using externally stored manifests

You can store and version your manifest definitions in Git (or elsewhere outside
of the Spinnaker pipeline store).

With Spinnaker's Artifact mechanism, file modifications/creations are surfaced
as artifacts in pipeline executions. For example, you can configure a pipeline
that triggers either when...

* a new Docker image is uploaded, or
* your manifest file is changed in Git

# Reserved annotations

Several annotations are used as metadata by Spinnaker to describe a resource.
Annotations listed below followed by a 📝 symbol may also be written by
Spinnaker.

You can always edit or apply annotations using the [`kubectl annotate`
command](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#annotate).

## Moniker

* `moniker.spinnaker.io/application` 📝

  The application this resource belongs to.

  This affects where the resource is accessible in the UI, and depending on your
  Spinnaker Authorization setup, can affect which users can read/write to this
  resource.

* `moniker.spinnaker.io/cluster` 📝

  The cluster this resource belongs to.

  This is purely a logical grouping for rendering resources in the UI and to
  help with dynamic target selection in Pipeline stages. For example, some
  stages allow you to select "the newest workload in cluster __X__". How you set
  up these groupings depends on your delivery needs.

* `moniker.spinnaker.io/stack` 📝, and `moniker.spinnaker.io/detail` 📝

  These simply provide ways to group resources using Spinnaker's cluster filters
  as well as apply policies such as [Traffic
  Guards](https://blog.spinnaker.io/can-i-push-that-building-safer-low-risk-deployments-with-spinnaker-a27290847ac4).

## Caching

* `caching.spinnaker.io/ignore`

  When set to `true`, tells Spinnaker to ignore this resource.
  The resource is not cached and does not show up in the Spinnaker UI.

## Strategy

* `strategy.spinnaker.io/versioned`

  When set to `true` or `false`, this overrides the resource's default
  "version" behavior described in the [resource management
  policies](#resource-management-policies). This can be used to force a
  ConfigMap or Secret to be deployed without appending a new version when the
  contents change, for example.

* `strategy.spinnaker.io/max-version-history`

  When set to a non-negative integer, this configures how many versions of a
  resource to keep around. When more than `max-version-history` versions of a
  Kubernetes artifact exist, Spinnaker deletes all older versions.
  __Resources are sorted by the `metadata.creationTimestamp` kubernetes property
  rather than the version number.__

  Keep in mind, if you are trying to restrict how many copies of a ReplicaSet
  a Deployment is managing, that is configured by
  [`spec.revisionHistoryLimit`](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy).
  If instead Spinnaker is deploying ReplicaSets directly without a Deployment,
  this annotation does the job.

# How Kubernetes resources are managed by Spinnaker

Resource mapping between Spinnaker and Kubernetes constructs, as well as the
introduction of new types of resources, is a lot more flexible in the
Kubernetes provider V2 than for other providers, because of how many types of
resources Kubernetes supports. Also the Kubernetes extension
mechanisms&mdash;called [Custom Resource Definitions
(CRDs)](https://kubernetes.io/docs/concepts/api-extension/custom-resources/)&mdash;make
it easy to build new types of resources, and Spinnaker accommodates that by
making it simple to extend Spinnaker to support a user's CRDs.

## Terminology mapping

It is worth noting that the resource mapping exists primarily to render
resources in the UI according to Spinnaker conventions. It does not affect how
resources are deployed or managed.

There are three major groupings of resources in Spinnaker:

* server groups
* load balancers
* security groups

These correspond to Kubernetes resource kinds as follows:

* Server Groups ≈ Workloads
* Load Balancers ≈ Services, Ingresses
* Security Groups ≈ NetworkPolicies

## Resource management policies

How you manage the deployment and updates of a Kubernetes resource is dictated
by its kind, via the policies that apply to a particular kind. Below are
descriptions of these policies, followed by a mapping of kinds to policies.

* __Operations__

  There are several operations that can be implemented by each kind:

  * _Deploy:_
    Can this resource be deployed and redeployed? It's worth
    mentioning that all deployments are carried out using `kubectl apply` to
    capitalize on `kubectl`'s three-way merge on deploy. This is done to
    accommodate running against your cluster, alongside Spinnaker, other tools
    that rely on the three-way merge semantics.
  * _Delete:_
    Can this resource be deleted?
  * _Scale:_
    For workloads only, can this resource be scaled to a desired replica
    count?
  * _Undo Rollout:_
    For workloads only, can this resource be rolled back/forward
    to an existing revision?
  * _Pause Rollout:_
    For workloads only, when rolling out, can the rollout be
    stopped?
  * _Resume Rollout:_
    For workloads only, when the rollout is paused, can it be
    started again?

* __Versioning__

  If a resource is "versioned", it is always deployed with a new sequence
  number `vNNN`, unless no change has been made to it. This is important for
  resources like `ConfigMaps` and `ReplicaSets`, which don't have their own
  built-in update policy like `Deployments` or `StatefulSets` do. Making an edit to
  the resource in place, rather than redeploying, can have unexpected results and can delete
  history. Regardless, whatever the policy is, it can be overriden
  during a deploy manifest stage.

  This policy can be overriden per-manifest using the
  `strategy.spinnaker.io/versioned` annotation [described here](#strategy).

* __Stability__

  This describes under what conditions this kind is considered stable after a
  new `spec` has been submitted.

## Workloads

Anything classified as a Spinnaker server group besides CronJobs and Jobs is rendered on the
__Clusters__ tab in Spinnaker. If possible, any pods owned by the workload are rendered as well.

| __Resource__ | _Deploy_ | _Delete_ | _Scale_ | _Undo Rollout_ | _Pause Rollout_ | _Resume Rollout_ | Versioned | Stability |
|-|:-:|:-:|:-:|:-:|:-:|:-:|:-:|-|
| __`CronJob`__ | Yes | Yes | No | No | No | No | No | The `status.getActive` must be zero.|
| __`DaemonSet`__ | Yes | Yes | No | Yes | Yes | Yes | No | The `status.currentNumberScheduled`, `status.updatedNumberScheduled`, `status.numberAvailable`, and `status.numberReady` must all be at least the `status.desiredNumberScheduled`. |
| __`Deployment`__ | Yes | Yes | Yes | Yes | Yes | Yes | No | The `status.updatedReplicas`, `status.availableReplicas`, and `status.readyReplicas` must all match the desired replica count for the Deployment. |
| __`Job`__ | Yes | Yes | No | No | No | No | No | The `status.getSucceeded` must match the spec's completions.|
| __`Pod`__ | Yes | Yes | No | No | No | No | Yes | The pod must be scheduled, and pass all probes. |
| __`ReplicaSet`__ | Yes | Yes | Yes | No | No | No | No | The `status.fullyLabledReplicas`, `status.availableReplicas`, and `status.readyReplicas` must all match the desired replica count for the ReplicaSet. |
| __`StatefulSet`__ | Yes | Yes | Yes | Yes | Yes | Yes | No | The `status.currentRevision`, and `status.updatedRevision` must match, and `status.currentReplicas`, and `status.readyReplicas` must match the spec's replica count. |

## Services, ingresses

| __Resource__ | _Deploy_ | _Delete_ | Versioned | Stability |
|-|:-:|:-:|:-:|-|
| __`Service`__ | Yes | Yes | No | The `status.loadBalancer` field reports that a load balancer was found if and only if the service type is `LoadBalancer`. |
| __`Ingress`__ | Yes | Yes | No | The `status.loadBalancer` field reports that a load balancer was bound. |

## NetworkPolicies

| __Resource__ | _Deploy_ | _Delete_ | Versioned | Stability |
|-|:-:|:-:|:-:|-|
| __`NetworkPolicy`__ | Yes | Yes | No | Automatically [stable](#accommodating-level-based-deployments). |

## ConfigMaps, secrets

| __Resource__ | _Deploy_ | _Delete_ | Versioned | Stability |
|-|:-:|:-:|:-:|-|
| __`ConfigMap`__ | Yes | Yes | Yes | Automatically [stable](#accommodating-level-based-deployments). |
| __`Secret`__ | Yes | Yes | Yes | Automatically [stable](#accommodating-level-based-deployments). |
