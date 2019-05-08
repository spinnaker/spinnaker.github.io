---
Layout: single
title:  "Kubernetes Provider V2 (Manifest Based)"
sidebar:
  nav: reference
---

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

  When set to `'true'`, tells Spinnaker to ignore this resource.
  The resource is not cached and does not show up in the Spinnaker UI.

## Strategy

* `strategy.spinnaker.io/versioned`

  When set to `'true'` or `'false'`, this overrides the resource's default
  "version" behavior described in the [resource management
  policies](#resource-management-policies). This can be used to force a
  ConfigMap or Secret to be deployed without appending a new version when the
  contents change, for example.

* `strategy.spinnaker.io/use-source-capacity`

  When set to `'true'` or `'false'`, this overrides the resource's replica count 
  with the currently deployed resource's replica count. This is supported for 
  Deployment, ReplicaSet or StatefulSet. This can be used to allow resizing a resource 
  in the Spinnaker UI or with kubectl without overriding the new size during subsequent 
  manifest deployments.

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

* `strategy.spinnaker.io/recreate`

  As of Spinnaker 1.13, you can force Spinnaker to delete a resource (if it
  already exists) before creating it again. This is useful for kinds such
  as [`Job`](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/),
  which cannot be edited once created, or must be re-created to run again.
  
  When set to `'true'` for a versioned resource, this will only re-create your
  resource if no edits have been made since the last deployment (i.e. the 
  same version of the resource is redeployed).
  
  The default behavior is `'false'`.

* `strategy.spinnaker.io/replace`

  As of Spinnaker 1.14, you can force Spinnaker to use `replace` instead of
  of `apply` while deploying a Kubernetes resource. This may be useful for resources
  such as `ConfigMap` which may exceed the annotation size limit of 262144 characters.

  When set to `'true'` for a versioned resource, this will update your resources using
  `replace`. Refer to [Kubernetes Object Management](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/overview/#imperative-object-configuration) for more details on object
  configuration and trade-offs.

  The default behavior is `'false'`.

## Traffic

* `traffic.spinnaker.io/load-balancers`

  As of Spinnaker 1.10, you can specify which load balancers
  ([Services](https://kubernetes.io/docs/concepts/services-networking/service/))
  a workload is attached to at deployment time. This will automatically set the
  required labels on the workload's Pods to match that of the Services' [label
  selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors).

  This annotation must be supplied as a list of `<kind> <name>` pairs where
  `kind` and `name` refer to the load balancer in the same namespace as the 
  resource. For example:

  * `traffic.spinnaker.io/load-balancers: '["service my-service"]'` attaches to
    the Service named `my-service`.

  * `traffic.spinnaker.io/load-balancers: '["service my-service", "service my-canary-service"]'` 
    attaches to the Services named `my-service` and `my-canary-service`.
    
  As of Spinnaker 1.14, instead of manually adding the `traffic.spinnaker.io/load-balancers`
  annotation, you can select which load balancers to associate with a workload from the Deploy
  (Manifest) stage. Spinnaker will then add the appropriate annotation for you. 

# Reserved labels

In accordance with [Kubernetes' recommendations on common
labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels),
Spinnaker applies the following labels as of release 1.9:

* `app.kubernetes.io/name`

  This is the name of the Spinnaker application this resource is deployed to,
  and matches the value of the `moniker.spinnaker.io/application` annotation
  desribed [here](#moniker).

* `app.kubernetes.io/managed-by`

  Always set to `"spinnaker"`.

> This labeling behavior can be disabled by setting the property
> `kubernetes.v2.applyAppLabels: false` in `clouddriver-local.yml`.

# How Kubernetes resources are managed by Spinnaker

Resource mapping between Spinnaker and Kubernetes constructs, as well as the
introduction of new types of resources, is a lot more flexible in the
Kubernetes provider V2 than for other providers, because of how many types of
resources Kubernetes supports. Also the Kubernetes extension
mechanisms&mdash;called [Custom Resource Definitions
(CRDs)](https://kubernetes.io/docs/concepts/api-extension/custom-resources/)&mdash;make
it easy to build new types of resources, and Spinnaker accommodates that by
making it simple to [extend Spinnaker to support a user's 
CRDs](https://www.spinnaker.io/guides/developer/crd-extensions/).

## Terminology mapping

It is worth noting that the resource mapping exists primarily to render
resources in the UI according to Spinnaker conventions. It does not affect how
resources are deployed or managed.

There are three major groupings of resources in Spinnaker:

* server groups
* load balancers
* firewalls

These correspond to Kubernetes resource kinds as follows:

* Server Groups ≈ Workloads
* Load Balancers ≈ Services, Ingresses
* Firewalls ≈ NetworkPolicies

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

Anything classified as a Spinnaker server group is rendered on the
__Clusters__ tab in Spinnaker. If possible, any pods owned by the workload are rendered as well.

| __Resource__ | _Deploy_ | _Delete_ | _Scale_ | _Undo Rollout_ | _Pause Rollout_ | _Resume Rollout_ | Versioned | Stability |
|-|:-:|:-:|:-:|:-:|:-:|:-:|:-:|-|
| __`DaemonSet`__ | Yes | Yes | No | Yes | Yes | Yes | No | The `status.currentNumberScheduled`, `status.updatedNumberScheduled`, `status.numberAvailable`, and `status.numberReady` must all be at least the `status.desiredNumberScheduled`. |
| __`Deployment`__ | Yes | Yes | Yes | Yes | Yes | Yes | No | The `status.updatedReplicas`, `status.availableReplicas`, and `status.readyReplicas` must all match the desired replica count for the Deployment. |
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
