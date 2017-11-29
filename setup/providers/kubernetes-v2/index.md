---
layout: single
title:  "Kubernetes V2 (Manifest-based)"
sidebar:
  nav: setup
---

{% include toc %}

> This is the second version of the Kubernetes provider in Spinnaker, not
> necessarily support for version 2.0 of Kubernetes.

In Kubernetes, an [Account](/setup/providers/#accounts) maps to a
credential able to authenticate against your desired Kubernetes Cluster.

## Prerequisites

The Kubernetes provider has two requirements, a
[`kubeconfig`](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/)
that you will
likely have to fetch from your Kubernetes cluster's administrator, and
[`kubectl`](https://kubernetes.io/docs/user-guide/kubectl/),
which will be automatically be installed alongside Spinnaker for you in any
Spinnaker packages we publish.

### kubeconfig

You must have a `kubeconfig` file that allows `kubectl` to authenticate against
your cluster, as well as have read and write access against any resources you
expect Spinnaker to manage. In the future, we will outline how to configure
Kubernetes RBAC for Spinnaker to manage a restricted set of resources.

### kubectl

Spinnaker relies on `kubectl` to manage all API access. It should already be
installed if you've installed Spinnaker.

Due to complexities in API discovery, 3-way merges on `kubectl apply`, and
other details in the Kubernetes API that no client other than `kubectl`'s go
library fully support, Spinnaker needs to depend on `kubectl` to access
your Kubernetes cluster. While this introduces a dependency on a binary, the
good news is that any authentication method or API resource that `kubectl`
supports, Spinnaker supports as well. This is a large improvement over the
initial Kubernetes provider implementation in Spinnaker.

## Migrating from the V1 Provider

> :warning: The V2 provider does _not_ use the Docker Registry Provider, and
> we encourage you to stop using the Docker Registry accounts in Spinnaker.
> As a result, The V2 provider requires that you manage your private registry
> [configuration and
> authentication](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)
> yourself.

There is no automatic migration strategy for pipelines between the two provider
versions for a few reasons:

* Unlike the V1 provider, the V2 provider encourages storing your Kubernetes
  Manifests outside of Spinnaker in some versioned, backing storage, such as
  Git or GCS.

* The V2 provider encourages leveraging Kubernetes' native deployment
  orchestration
  (e.g. [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/))
  in place of Spinnaker's red/black where possible.

* The initial operations made available on Kubernetes manifests (e.g. scale,
  pause rollout, delete) in the V2 provider don't map nicely to the operations
  in the V1 provider without contorting Spinnaker's abstractions to match those
  of Kubernetes. To avoid building dense and brittle mappings between
  Spinnaker's logical resources and Kubernetes' infrastructure resources we
  chose to adopt Kubernetes' resources an operations more natively.

However, you can migrate your infrastructure into the V2 provider very easily.
For any V1 account you have running, you can add a V2 account following the
steps below. This will surface your infrastructure twice (once per account)
helping your pipeline & operation migration.

{% include figure
   image_path="./v1v2.png"
   caption="A V1 and V2 provider surfacing the same infrastructure."
%}

## Adding an Account

First, make sure that the provider is enabled:

```bash
hal config provider kubernetes enable
```

With the provider enabled, you can add an account like so:

```bash
hal config provider kubernetes account add my-k8s-v2-account \
    --provider-version v2 \
    --context $(kubectl config current-context)
```

## Advanced Account Settings

If you are looking for more configurability, please see the other options
listed in the [Halyard
Reference](/reference/halyard/commands#hal-config-provider-kubernetes-account-add).
