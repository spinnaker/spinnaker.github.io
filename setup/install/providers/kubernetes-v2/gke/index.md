---
Layout: single
title:  "Google Kubernetes Engine (GKE) Setup"
sidebar:
  nav: setup
---

{% include toc %}

This page describes how to set up a Kubernetes cluster on
[GKE](https://cloud.google.com/kubernetes-engine/) to be used as a Spinnaker
Kubernetes v2 provider. The process is very simple, but you need to do some
specific things to allow Spinnaker to authenticate against your cluster.

> Note: To manage and create clusters in a given project, you need the
> `roles/container.admin` role as described
> [here](https://cloud.google.com/kubernetes-engine/docs/how-to/iam#predefined).

# Create a cluster

If you don't already have a cluster for this purpose, you can create a
Kubernetes cluster on GKE using either
[`gcloud`](https://cloud.google.com/sdk/gcloud/) or the [the Cloud
Console](https://console.cloud.google.com/) as shown in the [official
documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-cluster#creating_a_cluster).
Third party tools like
[Terraform](https://www.terraform.io/docs/providers/google/r/container_cluster.html)
work too, and can be used to automate provisioning your clusters.

# Download credentials

Follow the instructions shown in [the official
documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#generate_kubeconfig_entry)
to download credentials.

__Warning!__ The credentials you've downloaded probably rely on calling
`gcloud` to generate a token and authenticate against your cluster. This means
that the user (e.g. `a.employee@example.org`) you've configured `gcloud` to
authenticate as is making requests against the cluster, instead of a fixed
[Kubernetes service
account](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/)
making these requests.

This is a good thing because it prevents authenticating from a different
machine that hasn't already authenticated with `gcloud`. But it also
complicates configuring Spinnaker because each machine running Spinnaker needs
its own service account. `gcloud` checks the permissions of that service
account in order to generate an authentication token.

Given that all pods on GKE share the same service account, granting Spinnaker
on GKE permission also grants permission to all pods running alongside
Spinnaker. For this reason, we recommend configuring a [Kubernetes service
account](/setup/install/providers/kubernetes-v2/#optional-create-a-kubernetes-service-account)
for Spinnaker to authenticate as.

__TL;DR__ Use the credentials you've downloaded to create a [Kubernetes service
account](/setup/install/providers/kubernetes-v2/#optional-create-a-kubernetes-service-account)
for Spinnaker to authenticate as.

# Next Steps

[Follow the setup instructions for adding a Kubernetes account in
Spinnaker](/setup/install/providers/kubernetes-v2/#adding-an-account).
