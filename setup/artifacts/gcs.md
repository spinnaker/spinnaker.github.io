---
layout: single
title:  "Configuring GCS Artifact Credentials"
sidebar:
  nav: setup
---

{% include toc %}

Spinnaker stages that read data from artifacts can consume
[GCS](https://cloud.google.com/storage/) objects as artifacts.

## Prerequisites

You need a [Google Cloud Platform](https://cloud.google.com/) (GCP) project to
host a bucket in. The next steps assume you've already [created a
project](https://cloud.google.com/resource-manager/docs/creating-managing-projects),
and installed [`gcloud`](https://cloud.google.com/sdk/downloads). You can check
that `gcloud` is installed and authenticated by running:

```bash
gcloud info
```

### Downloading credentials

Spinnaker needs a [service
account](https://cloud.google.com/compute/docs/access/service-accounts) to
authenticate as against GCP, with the `roles/storage.admin` role enabled. If
you don't already have such a service account with the corresponding JSON key
downloaded, you can run the following commands to do so:

```bash
SERVICE_ACCOUNT_NAME=spin-gcs-artifacts-account
SERVICE_ACCOUNT_DEST=~/.gcp/gcs-artifacts-account.json

gcloud iam service-accounts create \
    $SERVICE_ACCOUNT_NAME \
    --display-name $SERVICE_ACCOUNT_NAME

SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SERVICE_ACCOUNT_NAME" \
    --format='value(email)')

PROJECT=$(gcloud info --format='value(config.project)')

gcloud projects add-iam-policy-binding $PROJECT \
    --role roles/storage.admin --member serviceAccount:$SA_EMAIL

mkdir -p $(dirname $SERVICE_ACCOUNT_DEST)

gcloud iam service-accounts keys create $SERVICE_ACCOUNT_DEST \
    --iam-account $SA_EMAIL
```

Once you have run these commands, your GCS JSON key is sitting in a file
called `$SERVICE_ACCOUNT_DEST`.

## Editing Your Artifact Settings

All that's required are the following values:

```bash
# Same as in Prerequisites section above
SERVICE_ACCOUNT_DEST=~/.gcp/gcs-artifacts-account.json

ARTIFACT_ACCOUNT_NAME=my-gcs-artifact-account
```

First, make sure that artifact support is enabled:

```bash
hal config features edit --artifacts true
```

Next, add an artifact account:

```bash
hal config artifact gcs account add $ARTIFACT_ACCOUNT_NAME \
    --json-path $SERVICE_ACCOUNT_DEST
```

And enable GCS artifact support:

```bash
hal config artifact gcs enable
```

There are more options described
[here](/reference/halyard/commands#hal-config-artifact-gcs-account-edit)
if you need more control over your configuration.
