---
layout: single
title:  "Google Compute Engine"
sidebar:
  nav: setup
---

{% include toc %}



## Download Deployment Credentials

In order to deploy a GCE VM, you must create a new service account and download its key. This service account should have permissions _for the project the VM will run in_.

Repeat these steps for each project to which you'd like to deploy GCE VMs.

Create the service account with the necessary permissions:

```bash
PROJECT=$(gcloud info --format='value(config.project)') # project that Spinnaker will deploy to.
SA_NAME=spinnaker-storage

gcloud iam service-accounts create $SA_NAME \
    --display-name $SA_NAME

SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SA_NAME" \
    --format='value(email)')

gcloud projects add-iam-policy-binding $PROJECT \
    --role roles/compute.storageAdmin \
    --role roles/compute.securityAdmin \
    --role roles/compute.networkAdmin \
    --role roles/compute.instanceAdmin \
    --role roles/iam.serviceAccountActor \
    --role roles/storage.admin \
    --member serviceAccount:$SA_EMAIL
```

## Download Storage Credentials

{% include_relative gcs.md %}

## Install with Halyard

{% include_relative install_with_halyard.md %}