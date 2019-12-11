---

layout: single
title:  "Try out Halyard on GCE"
sidebar:
  nav: setup
---

{% include toc %}

 > Note: we recommend that you install Spinnaker following the [standard setup directions](/setup/)
 rather than using this guide, which is just a set of commands to get Spinnaker up and running on
 GCS and GCE.

In this guide we'll be going through the basics of deploying Spinnaker to a
single VM instances on GCE; however, many of the operations here apply to any
VM running Ubuntu 14.04.

## Overview

Once we are finished we will have the following setup:

* Spinnaker running on a GCE VM, installed using each subservices Debian
  package.
* Persistent storage configured to use GCS.
* Spinnaker configured to deploy resources to GCE, and bake GCE VM images.

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

### Enable the GCP IAM API

Navigate to the [Google Cloud Console](https://console.developers.google.com/apis/api/iam.googleapis.com/overview) and enable the Google Identity and Access Management (IAM) API

### Set up credentials

Create a service account for our Halyard host VM:

```bash
GCP_PROJECT=$(gcloud config get-value project)
HALYARD_SERVICE_ACCOUNT_NAME=halyard-vm-account

gcloud iam service-accounts create $HALYARD_SERVICE_ACCOUNT_NAME \
    --project=$GCP_PROJECT \
    --display-name $HALYARD_SERVICE_ACCOUNT_NAME

HALYARD_SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list \
    --project=$GCP_PROJECT \
    --filter="displayName:$HALYARD_SERVICE_ACCOUNT_NAME" \
    --format='value(email)')

# permission to download service account keys
gcloud projects add-iam-policy-binding $GCP_PROJECT \
    --role roles/iam.serviceAccountKeyAdmin \
    --member serviceAccount:$HALYARD_SERVICE_ACCOUNT_EMAIL
```

Create a service account for GCS that you'll later be handing to Spinnaker

```bash
GCP_PROJECT=$(gcloud config get-value project)
GCS_SERVICE_ACCOUNT_NAME=spinnaker-gcs-account

gcloud iam service-accounts create $GCS_SERVICE_ACCOUNT_NAME \
    --project=$GCP_PROJECT \
    --display-name $GCS_SERVICE_ACCOUNT_NAME

GCS_SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list \
    --project=$GCP_PROJECT \
    --filter="displayName:$GCS_SERVICE_ACCOUNT_NAME" \
    --format='value(email)')

# permission to create/modify buckets in your project
gcloud projects add-iam-policy-binding $GCP_PROJECT \
    --role roles/storage.admin \
    --member serviceAccount:$GCS_SERVICE_ACCOUNT_EMAIL
```

Create a service account for GCE that you'll also be handing to Spinnaker

```bash
GCP_PROJECT=$(gcloud config get-value project)
GCE_SERVICE_ACCOUNT_NAME=spinnaker-gce-account

gcloud iam service-accounts create \
    $GCE_SERVICE_ACCOUNT_NAME \
    --project=$GCP_PROJECT \
    --display-name $GCE_SERVICE_ACCOUNT_NAME

GCE_SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list \
    --project=$GCP_PROJECT \
    --filter="displayName:$GCE_SERVICE_ACCOUNT_NAME" \
    --format='value(email)')

# permission to create/modify instances in your project
gcloud projects add-iam-policy-binding $GCP_PROJECT \
    --member serviceAccount:$GCE_SERVICE_ACCOUNT_EMAIL \
    --role roles/compute.instanceAdmin

# permission to create/modify network settings in your project
gcloud projects add-iam-policy-binding $GCP_PROJECT \
    --member serviceAccount:$GCE_SERVICE_ACCOUNT_EMAIL \
    --role roles/compute.networkAdmin

# permission to create/modify firewall rules in your project
gcloud projects add-iam-policy-binding $GCP_PROJECT \
    --member serviceAccount:$GCE_SERVICE_ACCOUNT_EMAIL \
    --role roles/compute.securityAdmin

# permission to create/modify images & disks in your project
gcloud projects add-iam-policy-binding $GCP_PROJECT \
    --member serviceAccount:$GCE_SERVICE_ACCOUNT_EMAIL \
    --role roles/compute.storageAdmin

# permission to download service account keys in your project
# this is needed by packer to bake GCE images remotely
gcloud projects add-iam-policy-binding $GCP_PROJECT \
    --member serviceAccount:$GCE_SERVICE_ACCOUNT_EMAIL \
    --role roles/iam.serviceAccountActor
```

### Create Halyard host VM

Create a VM with the service account:

```bash
HALYARD_HOST=$(echo $USER-halyard-`date +%m%d` | tr '_.' '-')

gcloud compute instances create $HALYARD_HOST \
    --project=$GCP_PROJECT \
    --zone=us-central1-f \
    --scopes=cloud-platform \
    --service-account=$HALYARD_SERVICE_ACCOUNT_EMAIL \
    --image-project=ubuntu-os-cloud \
    --image-family=ubuntu-1804-lts \
    --machine-type=n1-standard-4
```

SSH into the VM with the following ports forwarded as shown to allow access to
the Spinnaker UI & API servers.

> :warning: You need to SSH into the Halyard host VM from your local
> workstation; SSHing from [Cloud Shell](https://cloud.google.com/shell/), a
> Chromebook, or another VM won't open the necessary SSH tunnels that will allow your local
> web browser to access Spinnaker.

```bash
gcloud compute ssh $HALYARD_HOST \
    --project=$GCP_PROJECT \
    --zone=us-central1-f \
    -- -L 9000:localhost:9000 -L 8084:localhost:8084
```

> **From this point on, you will be entering the commands below in the halyard ssh session.**

## Part 1: Install halyard

### Install halyard

```bash
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/stable/InstallHalyard.sh

sudo bash InstallHalyard.sh

. ~/.bashrc
```

## Part 2: Gather needed credentials

### GCS service account

Download the service account json file for your GCE access with the following
commands

```bash
GCE_SERVICE_ACCOUNT_NAME=spinnaker-gce-account
GCE_SERVICE_ACCOUNT_DEST=~/.gcp/gce.json

mkdir -p $(dirname $GCE_SERVICE_ACCOUNT_DEST)

GCE_SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$GCE_SERVICE_ACCOUNT_NAME" \
    --format='value(email)')

gcloud iam service-accounts keys create $GCE_SERVICE_ACCOUNT_DEST \
    --iam-account $GCE_SERVICE_ACCOUNT_EMAIL
```

Download the service account json file for your GCS access with the following
commands

```bash
GCS_SERVICE_ACCOUNT_NAME=spinnaker-gcs-account
GCS_SERVICE_ACCOUNT_DEST=~/.gcp/gcs.json

mkdir -p $(dirname $GCS_SERVICE_ACCOUNT_DEST)

GCS_SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$GCS_SERVICE_ACCOUNT_NAME" \
    --format='value(email)')

gcloud iam service-accounts keys create $GCS_SERVICE_ACCOUNT_DEST \
    --iam-account $GCS_SERVICE_ACCOUNT_EMAIL
```

## Part 3: Set Spinnaker configuration

We will install the latest version of Spinnaker

```bash
hal config version edit --version $(hal version latest -q)
```

Set up to persist to GCS

```bash
hal config storage gcs edit \
    --project $(gcloud config get-value project) \
    --json-path $GCS_SERVICE_ACCOUNT_DEST

hal config storage edit --type gcs
```

Set up the GCE provider

```bash
hal config provider google account add my-gce-account \
    --project $(gcloud config get-value project) \
    --json-path $GCE_SERVICE_ACCOUNT_DEST

hal config provider google enable
```

## Part 4: Deploy Spinnaker

```bash
sudo hal deploy apply
```

Finally, from your local workstation browser, navigate to your [brand new Spinnaker instance](http://localhost:9000/)!


## Next steps

For more information on Halyard and managing Spinnaker, go to the [Setup](/setup/install/halyard) section for an overview of how Halyard works, and the [Reference](/reference/halyard/) section for an exhaustive listing of Halyard commands.
