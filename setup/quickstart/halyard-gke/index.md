---
layout: single
title:  "Halyard on GKE Quickstart"
sidebar:
  nav: setup
---

{% include toc %}

In this quickstart, you will learn the basics of [Halyard](/setup/install/halyard/), Spinnaker's tool for managing your Spinnaker instance.

## Overview

In our scenario, we want to create a Spinnaker instance and set it up as follows:

* The Spinnaker instance is itself running in a Kubernetes cluster
* The Kubernetes provider is set up so that we can deploy our custom apps to Kubernetes
* We can pull Docker images from our Google Container Registry
* We use GCS as our persistence store

For this exercise we will be operating entirely within one GCP project, and use Google Kubernetes Engine (GKE) as our Kubernetes cluster.

{% include figure
    image_path="./deployment.png"
    alt="image of deployed environment including halyard vm"
    caption="How your Kubernetes cluster can look at the end of this guide, with an app
    deployed (not covered)." %}

## Part 0: Preparation

### Install gcloud

If you don't already have gcloud installed, navigate to [Installing Cloud SDK](https://cloud.google.com/sdk/downloads#interactive) to install gcloud

#### Authenticate gcloud and set your default project.

Authenticate gcloud with your account. Follow the instructions after the following command.

```bash
gcloud auth login
```

Set your default gcloud project:

```bash
gcloud config set project <PROJECT_NAME>
```

### Create a Kubernetes cluster

Navigate to the [Google Cloud Console's GKE section](https://console.cloud.google.com/kubernetes/list) to create a new Kubernetes cluster (please note the cluster name and zone).

### Enable APIs

Navigate to the Google Cloud Console and enable the following APIs:
* [Google Identity and Access Management (IAM) API](https://console.developers.google.com/apis/api/iam.googleapis.com/overview)
* [Google Cloud Resource Manager API](https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview)

### Set up credentials

Create a service account for our halyard host VM:

```bash
GCP_PROJECT=$(gcloud info --format='value(config.project)')
HALYARD_SA=halyard-service-account

gcloud iam service-accounts create $HALYARD_SA \
    --project=$GCP_PROJECT \
    --display-name $HALYARD_SA

HALYARD_SA_EMAIL=$(gcloud iam service-accounts list \
    --project=$GCP_PROJECT \
    --filter="displayName:$HALYARD_SA" \
    --format='value(email)')

gcloud projects add-iam-policy-binding $GCP_PROJECT \
    --role roles/iam.serviceAccountKeyAdmin \
    --member serviceAccount:$HALYARD_SA_EMAIL

gcloud projects add-iam-policy-binding $GCP_PROJECT \
    --role roles/container.admin \
    --member serviceAccount:$HALYARD_SA_EMAIL
```

Create a service account for GCS and GCR that you'll later be handing to Spinnaker

```bash
GCS_SA=gcs-service-account

gcloud iam service-accounts create $GCS_SA \
    --project=$GCP_PROJECT \
    --display-name $GCS_SA

GCS_SA_EMAIL=$(gcloud iam service-accounts list \
    --project=$GCP_PROJECT \
    --filter="displayName:$GCS_SA" \
    --format='value(email)')

gcloud projects add-iam-policy-binding $GCP_PROJECT \
    --role roles/storage.admin \
    --member serviceAccount:$GCS_SA_EMAIL
```

### Create halyard host VM

Create a VM with the service account:

```bash
HALYARD_HOST=$(echo $USER-halyard-`date +%m%d` | tr '_.' '-')

gcloud compute instances create $HALYARD_HOST \
    --project=$GCP_PROJECT \
    --zone=us-central1-f \
    --scopes=cloud-platform \
    --service-account=$HALYARD_SA_EMAIL \
    --image-project=ubuntu-os-cloud \
    --image-family=ubuntu-1404-lts \
    --machine-type=n1-standard-4
```

SSH into the VM. We specify port forwarding because at the end of this exercise you'll be port forwarding from this VM to Spinnaker running in the Kubernetes cluster. That is, you'll be port forwarding twice: from your workstation browser to this GCE VM, and from this GCE VM to the Kubernetes cluster.

> :warning: You need to SSH into the Halyard host VM from your local
> workstation; SSHing from [Cloud Shell](https://cloud.google.com/shell/), a
> Chromebook or
> another VM won't open the necessary SSH tunnels that will allow your local
> web browser to access Spinnaker.

```bash
gcloud compute ssh $HALYARD_HOST \
    --project=$GCP_PROJECT \
    --zone=us-central1-f \
    --ssh-flag="-L 9000:localhost:9000" \
    --ssh-flag="-L 8084:localhost:8084"
```

> **From this point on, you will be entering the commands below in the halyard ssh session.**

## Part 1: Install halyard

### Install kubectl

```bash
curl -O https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/linux/amd64/kubectl

chmod +x kubectl

sudo mv kubectl /usr/local/bin/kubectl
```

### Install halyard

```bash
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/stable/InstallHalyard.sh

sudo bash InstallHalyard.sh

. ~/.bashrc
```

## Part 2: Gather needed credentials

### ~/.kube/config

Generate your ~/.kube/config file:

```bash
GKE_CLUSTER_NAME={YOUR_GKE_CLUSTER_NAME}
GKE_CLUSTER_ZONE={YOUR_GKE_CLUSTER_ZONE}

gcloud config set container/use_client_certificate true

gcloud container clusters get-credentials $GKE_CLUSTER_NAME \
    --zone=$GKE_CLUSTER_ZONE
```

### GCS service account

Download the service account json file for your GCP project with the following commands:

```bash
GCS_SA=gcs-service-account
GCS_SA_DEST=~/.gcp/gcp.json

mkdir -p $(dirname $GCS_SA_DEST)

GCS_SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$GCS_SA" \
    --format='value(email)')

gcloud iam service-accounts keys create $GCS_SA_DEST \
    --iam-account $GCS_SA_EMAIL
```


## Part 3: Set Spinnaker configuration

We configure Halyard to use the latest version of Spinnaker.

```bash
hal config version edit --version $(hal version latest -q)
```

Set up to persist to GCS

```bash
hal config storage gcs edit \
    --project $(gcloud info --format='value(config.project)') \
    --json-path ~/.gcp/gcp.json

hal config storage edit --type gcs
```

Set up pulling from GCR

```bash
hal config provider docker-registry enable

hal config provider docker-registry account add my-gcr-account \
    --address gcr.io \
    --password-file ~/.gcp/gcp.json \
    --username _json_key
```

Set up the Kubernetes provider

```bash
hal config provider kubernetes enable

hal config provider kubernetes account add my-k8s-account \
    --docker-registries my-gcr-account \
    --context $(kubectl config current-context)
```

## Part 4: Deploy Spinnaker

```bash
hal config deploy edit \
    --account-name my-k8s-account \
    --type distributed

hal deploy apply
```

> :point_right: Halyard will warn you that you have deployed Spinnaker remotely
> without configuring an authentication mechanism. This is OK, but cumbersome,
> since we can connect via SSH tunnels. If you want to configure
> authentication, read more in the [security documentation](/setup/security).

Now, to connect to Spinnaker, run:

```bash
hal deploy connect
```

Finally, from your local workstation browser, navigate to your [brand new Spinnaker instance](http://localhost:9000/)!


## Next steps

For more information on halyard and managing Spinnaker, go to the [Setup](/setup/install/halyard) section for an overview of how halyard works, and the [Reference](/reference/halyard/) section for an exhaustive listing of halyard commands.
