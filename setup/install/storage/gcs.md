---
layout: single
title:  "Google Cloud Storage"
sidebar:
  nav: setup
redirect_from: /setup/storage/gcs/
---

{% include toc %}

Using [Google Cloud Storage](https://cloud.google.com/storage/){:target="\_blank"}
(GCS) as a storage source means that Spinnaker will store all of its persistent
data in a [Bucket](https://cloud.google.com/storage/docs/json_api/v1/buckets){:target="\_blank"}.

## Prerequisites

You need a [Google Cloud Platform](https://cloud.google.com/){:target="\_blank"}
(GCP) project to host your bucket in. The next steps assume you've already
[created a project](https://cloud.google.com/resource-manager/docs/creating-managing-projects){:target="\_blank"},
and installed [`gcloud`](https://cloud.google.com/sdk/downloads){:target="\_blank"}.
You can check that `gcloud` is installed and authenticated by running:

```bash
gcloud info
```

### Downloading credentials

Spinnaker needs a [service
account](https://cloud.google.com/compute/docs/access/service-accounts){:target="\_blank"}
to authenticate as against GCP, with the `roles/storage.admin` role enabled. If
you don't already have such a service account with the corresponding JSON key
downloaded, you can run the following commands to do so:

```bash
SERVICE_ACCOUNT_NAME=spinnaker-gcs-account
SERVICE_ACCOUNT_DEST=~/.gcp/gcs-account.json

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

## Editing Your Storage Settings

Halyard will create a bucket for you if the bucket you specify doesn't exist
yet, or if you don't specify one at all. All that's required are the following
values (we've provided defaults for you):

```bash
PROJECT=$(gcloud info --format='value(config.project)')
# see https://cloud.google.com/storage/docs/bucket-locations
BUCKET_LOCATION=us
SERVICE_ACCOUNT_DEST=# see Prerequisites section above
```

First, edit the storage settings:

```bash
hal config storage gcs edit --project $PROJECT \
    --bucket-location $BUCKET_LOCATION \
    --json-path $SERVICE_ACCOUNT_DEST
```

There are more options described
[here](/reference/halyard/commands#hal-config-storage-gcs-edit)
if you need more control over your configuration.

Finally, set the storage source to GCS:

```bash
hal config storage edit --type gcs
```

## Next steps

After you've set up GCS as your external storage service, you're ready to
[deploy Spinnaker](/setup/install/deploy/).
