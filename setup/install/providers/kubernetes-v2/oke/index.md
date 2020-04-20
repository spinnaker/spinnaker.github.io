---
Layout: single
title:  "Oracle Cloud Infrastructure Container Engine for Kubernetes (OKE) Setup"
sidebar:
  nav: setup
---

{% include toc %}

This page describes how to set up a Kubernetes cluster on
[OKE](https://cloud.oracle.com/containers/kubernetes-engine/) to be used as a Spinnaker
Kubernetes v2 provider. 

# Create a cluster

If you don't already have a cluster for this purpose, you can create a
Kubernetes cluster on OKE by following [this tutorial](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/index.html).

# Download kubectl configuration file

Follow [the instructions](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/index.html#DownloadthekubeconfigFilefortheCluster)
to download kubectl configuration file.

# Enable Kubernetes Cloud provider using Halyard

Run the following `hal` command to add an account named `my-k8s-v2-acct` to your list of Kubernetes accounts:

```bash
hal config provider kubernetes account add my-k8s-v2-acct \
    --provider-version v2 \
    --context $(kubectl config current-context)
```
Enable the Kubernetes provider:

```bash
hal config provider kubernetes enable
```

Finally, enable [artifact support](/reference/artifacts-with-artifactsrewrite//#enabling-artifact-support).
