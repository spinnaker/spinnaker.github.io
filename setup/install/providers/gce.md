---
layout: single
title:  "Google Compute Engine"
sidebar:
  nav: setup
redirect_from: /setup/providers/gce/
---

{% include toc %}

In [Google Compute Engine](https://cloud.google.com/compute) (GCE), an
[__Account__](/concepts/providers/#accounts) maps to a credential able to
authenticate against a given [Google Cloud Platform](https://cloud.google.com/)
(GCP) project.

## Prerequisites

You need a [Google Cloud Platform](https://cloud.google.com/) (GCP) project
to run Spinnaker against. The next steps assume you've already [created a
project](https://cloud.google.com/resource-manager/docs/creating-managing-projects),
and installed [`gcloud`](https://cloud.google.com/sdk/downloads). You can check
that `gcloud` is installed and authenticated by running:

```bash
gcloud info
```

### Downloading Credentials

Spinnaker needs a [service
account](https://cloud.google.com/compute/docs/access/service-accounts) to
authenticate as against GCE, with the role enumerated below enabled. If
you don't already have such a service account with the corresponding JSON key
downloaded, you can run the following commands to do so:

```bash
SERVICE_ACCOUNT_NAME=spinnaker-gce-account
SERVICE_ACCOUNT_DEST=~/.gcp/gce-account.json

gcloud iam service-accounts create \
    $SERVICE_ACCOUNT_NAME \
    --display-name $SERVICE_ACCOUNT_NAME

SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SERVICE_ACCOUNT_NAME" \
    --format='value(email)')

PROJECT=$(gcloud info --format='value(config.project)')

# permission to create/modify instances in your project
gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$SA_EMAIL \
    --role roles/compute.instanceAdmin

# permission to create/modify network settings in your project
gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$SA_EMAIL \
    --role roles/compute.networkAdmin

# permission to create/modify firewall rules in your project
gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$SA_EMAIL \
    --role roles/compute.securityAdmin

# permission to create/modify images & disks in your project
gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$SA_EMAIL \
    --role roles/compute.storageAdmin

# permission to download service account keys in your project
# this is needed by packer to bake GCE images remotely
gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$SA_EMAIL \
    --role roles/iam.serviceAccountActor

mkdir -p $(dirname $SERVICE_ACCOUNT_DEST)

gcloud iam service-accounts keys create $SERVICE_ACCOUNT_DEST \
    --iam-account $SA_EMAIL
```

Once you have run these commands, your GCP JSON key is sitting in a file
called `$SERVICE_ACCOUNT_DEST`.

## Adding an Account

First, make sure that the provider is enabled:

```bash
hal config provider google enable
```

All that's required are the following values (we've provided defaults for you):

```bash
PROJECT=$(gcloud info --format='value(config.project)')
SERVICE_ACCOUNT_DEST=# see Prerequisites section above
```

Finally, add your new google account:

```bash
hal config provider google account add my-gce-account --project $PROJECT \
    --json-path $SERVICE_ACCOUNT_DEST
```

TODO(lwander or duftler): Add a note about application default credentials.

## Advanced Account Settings

If you are looking for more configurability, please see the other options
listed in the [Halyard
Reference](/reference/halyard/commands#hal-config-provider-google-account-add).

## Next Steps

Optionally, you can [set up another cloud provider](/setup/install/providers/), but otherwise you're ready to [Deploy Spinnaker](/setup/install/deploy/).
