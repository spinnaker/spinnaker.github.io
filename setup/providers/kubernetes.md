---
layout: single
title:  "Kubernetes"
sidebar:
  nav: setup
---

{% include toc %}

In Kubernetes, an [Account](/setup/providers/#accounts) maps to a
credential able to authenticate against your desired Kubernetes Cluster, as 
well as a set of [Docker Registry](/setup/providers/docker-registry) accounts 
to be used as a source of images.

## Prerequisites

Both the Kubernetes credentials and Docker Registry accounts must exist before 
Halyard will allow you to add a Kubernetes account. The sections below will 
help you create these resources if you do not already have them.

### Kubernetes Cluster

You need to have a running Kubernetes cluster with corresponding credentials in 
a [kubeconfig file](https://kubernetes.io/docs/concepts/cluster-administration/authenticate-across-clusters-kubeconfig/). 
If you do have a running cluster and credentials, you can verify that your 
credentials work using 
[`kubectl`](https://kubernetes.io/docs/user-guide/kubectl-overview/) to run the
following command:

```bash
kubectl get namespaces
```

If you do not have a Kubernetes cluster, you could try one of the following
hosted solutions:

* [Google Container Engine](https://cloud.google.com/container-engine/)
* [Azure Container
  Service](https://docs.microsoft.com/en-us/azure/container-service/container-service-kubernetes-walkthrough)

Or, you can read more on the Kubernetes setup page to pick a [solution that
works for you](https://kubernetes.io/docs/setup/pick-right-solution/).

### Docker Registries

Follow the steps under the [Docker Registry](/setup/providers/docker-registry) 
provider to add any registries containing images you want to deploy. If
you have already done so, you can verify that these accounts exist by running:

```bash
hal config provider docker-registry account list
```

## Adding an Account

First, make sure that the provider is enabled:

```bash
hal config provider kubernetes enable
```

Now, assuming you have a Docker Registry account named `my-docker-registry`,
run the following `hal` command to add an account named `my-k8s-account` to 
your list of Kubernetes accounts:

```bash
hal config provider kubernetes account add my-k8s-account \
    --docker-registries my-docker-registry
```

## Advanced Account Settings

If you are looking for more configurability, please see the other options
listed in the [Halyard
Reference](/reference/halyard/commands#hal-config-provider-kubernetes-account-add).
