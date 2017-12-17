---
layout: single
title:  "Kubernetes Provider V2 (Manifest Based)"
sidebar:
  nav: setup
---

{% include toc %}

The Spinnaker Kubernetes V2 provider fully supports manifest-based deployments.
[Kubernetes provider V1](https://www.spinnaker.io/setup/providers/kubernetes/)
is still supported.

## Accounts

For Kubernetes V2, a Spinnaker [Account](/setup/providers/#accounts) maps to a
credential that can authenticate against your Kubernetes Cluster. Unlike with
the V1 provider, in V2 the Account does not require any Docker Registry
Accounts.

## Prerequisites

The Kubernetes provider has two requirements:

* A [`kubeconfig`](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/)

    The `kubeconfig` allows Spinnaker to authenticate against your cluster and
    to have read/write access to any resources you expect it to manage. You can
    request this from your Kubernetes cluster administrator.

* [`kubectl`](https://kubernetes.io/docs/user-guide/kubectl/)

    Spinnaker relies on `kubectl` to manage all API access. It's installed
    along with Spinnaker.

    Spinnaker also relies on `kubectl` to access your Kubernetes cluster; only
    `kubectl` fully supports many aspects of the Kubernetes API, such as 3-way
    merges on `kubectl apply`, and API discovery. Though this creates a
    dependency on a binary, the good news is that any authentication method or
    API resource that `kubectl` supports is also supported by Spinnaker. This
    is much better support than what was in the original Kubernetes provider in
    Spinnaker

## Migrating from the V1 Provider

> :warning: The V2 provider does __not__ use the [Docker Registry
> Provider](https://www.spinnaker.io/setup/providers/docker-registry/), and we
> encourage you to stop using the Docker Registry accounts in Spinnaker.  The
> V2 provider requires that you manage your private registry [configuration and
> authentication](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)
> yourself.

There is no automatic pipeline migration from the V1 provider to V2, for a few
reasons:

* Unlike the V1 provider, the V2 provider encourages you to store your
  Kubernetes Manifests outside of Spinnaker in some versioned, backing storage,
  such as Git or GCS.

* The V2 provider encourages you to leverage the Kubernetes native deployment
  orchestration (e.g.
  [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/))
  instead of the Spinnaker blue/green, where possible.

* The initial operations available on Kubernetes manifests (e.g. scale, pause
  rollout, delete) in the V2 provider don't map nicely to the operations in the
  V1 provider unless you contort Spinnaker abstractions to match those of
  Kubernetes. To avoid building dense and brittle mappings between Spinnaker's
  logical resources and Kubernetes's infrastructure resources, we chose to
  adopt the Kubernetes resources and operations more natively.

However, you can easily migrate your _infrastructure_ into the V2 provider.
For any V1 account you have running, you can add a V2 account following the
steps [below](#adding-an-account). This will surface your infrastructure twice
(once per account) helping your pipeline & operation migration.

{% include figure image_path="./v1v2.png" caption="A V1 and V2 provider
surfacing the same infrastructure" %}

## Adding an Account

First, make sure that the provider is enabled:

```bash
hal config provider kubernetes enable
```

Then add the account:

```bash
hal config provider kubernetes account add my-k8s-v2-account \
    --provider-version v2 \
    --context $(kubectl config current-context)
```

## Advanced Account Settings

If you're looking for more configurability, please see the other options listed
in the [Halyard
Reference](/reference/halyard/commands#hal-config-provider-kubernetes-account-add).
