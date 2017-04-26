---
layout: single
title:  "Getting Started with Halyard"
sidebar:
  nav: guides
---

{% include toc %}

In this codelab, you will learn the basics of [halyard](/setup/install/halyard/), Spinnaker's tool for managing your Spinnaker instance. 

## Overview

In our scenario, we want to create a Spinnaker instance and set it up as follows:

* The Spinnaker instance is itself running in a Kubernetes cluster
* The Kubernetes provider is set up so that we can deploy our custom apps to Kubernetes
* We can pull Docker images from our Google Container Registry
* We use GCS as our persistence store

For this exercise we will be operating entirely within one GCP project, and use Google Container Engine (GKE) as our Kubernetes cluster. 


## Part 0: Prerequisites

We assume the reader has some prior experience with Kubernetes and GCP, but will also provide some guidance along the way. First, you'll need to [install gcloud](https://cloud.google.com/sdk/downloads#interactive) and have a [GKE](https://console.cloud.google.com/kubernetes/list)) cluster.


## Part 1: Install halyard

### Create halyard host VM

```
HALHOST=$USER-halyard-`date +%m%d`

gcloud compute instances create $HALHOST \
    --scopes storage-full,compute-rw \
    --project={YOUR_GCP_PROJECT} \
    --zone=us-central1-f \
    --image-project=ubuntu-os-cloud \
    --image-family=ubuntu-1404-lts \
    --machine-type=n1-standard-4
```

SSH into the VM. We specify port forwarding because at the end of this exercise you'll be port forwarding from this VM to Spinnaker running in the Kubernetes cluster. That is, you'll be port forwarding twice: from your workstation browser to this GCE VM, and from this GCE VM to the Kubernetes cluster.

```
gcloud compute ssh $HALHOST \
    --project={YOUR_GCP_PROJECT} \
    --zone=us-central1-f \
    --ssh-flag=”-L 9000:localhost:9000” \
    --ssh-flag=”-L 8084:localhost:8084”
```

> **From this point on, you will be entering the commands below in the halyard ssh session.**

### Install kubectl

```
curl -O https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/linux/amd64/kubectl

chmod +x kubectl

sudo mv kubectl /usr/local/bin/kubectl
```


### Install halyard

```
wget https://raw.githubusercontent.com/spinnaker/halyard/master/InstallHalyard.sh

sudo bash InstallHalyard.sh

. ~/.bashrc
```

## Part 2: Gather needed credentials

### ~/.kube/config

If you don't already have this, an easy way to set this up is to use gcloud:

    gcloud container clusters get-credentials {YOUR_GKE_CLUSTER_NAME}

### GCP service account

You will need to specify the location of a json file containing credentials to your GCP project with the role "Storage / Storage Admin". Download the key from the Cloud Console and copy it to `~/.google/account.json`.


## Part 3: Set Spinnaker configuration

We will install Spinnaker v0.1.0

    hal config version edit --version 0.1.0

Set up to persist to GCS

    hal config storage gcs edit --project {YOUR_GCP_PROJECT} --json-path ~/.google/account.json

    hal config storage edit --type gcs

Set up pulling from GCR

    hal config provider docker-registry enable

    hal config provider docker-registry account add my-gcr-account \
        --address gcr.io \
        --password-file ~/.google/account.json \
        --username _json_key

Set up Kubernetes provider

    hal config provider kubernetes enable

    hal config provider kubernetes account add my-k8s-account \
        --docker-registries my-gcr-account


## Part 4: Deploy Spinnaker

    hal config deploy edit --account-name my-k8s-account --type distributed

    hal deploy apply

Run the post-install script to port forward Spinnaker requests

    ~/.halyard/default/install.sh

Finally, from your local workstation browser, navigate to your [brand new Spinnaker instance](http://localhost:9000/)!


## Next steps

For more information on halyard and managing Spinnaker, go to the [Setup](/setup/install/halyard) section for an overview of how halyard works, and the [Reference](reference/halyard/) section for an exhaustive listing of halyard commands.
