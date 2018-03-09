---
layout: single
title:  "Google App Engine"
sidebar:
  nav: setup
redirect_from: /setup/providers/appengine/
---

{% include toc %}

In [Google App Engine](https://cloud.google.com/appengine), an [__Account__](/concepts/providers/#accounts) maps to a
credential able to authenticate against a given [Google Cloud Platform](https://cloud.google.com) project.

## Prerequisites

You need a [Google Cloud Platform](https://cloud.google.com/) project
to run Spinnaker against. The next steps assume you've already [created a
project](https://cloud.google.com/resource-manager/docs/creating-managing-projects),
and installed [`gcloud`](https://cloud.google.com/sdk/downloads). You can check
that `gcloud` is installed and authenticated by running:

```bash
gcloud info
```

If this is your first time deploying to App Engine in your project, create an App Engine application.
You cannot change your application's region, so pick wisely:

```bash
gcloud app create --region <e.g., us-central>
```

You will also need to enable the App Engine Admin API for your project:

```bash
gcloud service-management enable appengine.googleapis.com
```

## Downloading Credentials

Spinnaker does not need to be given [service account](https://cloud.google.com/compute/docs/access/service-accounts)
credentials if it is running on a Google Compute Engine VM whose
application default credentials have sufficient scopes to deploy to App Engine _and_
Spinnaker is deploying to an App Engine application inside the same Google Cloud Platform project in which it is running. If
Spinnaker will not need to be given service account credentials, or if you already have such a service account
with the corresponding JSON key downloaded, skip ahead to [Adding an Account](#adding-an-account).

Run the following commands to create a service account
with the `roles/appengine.appAdmin` and `roles/storage.admin` roles enabled:

```bash
SERVICE_ACCOUNT_NAME=spinnaker-appengine-account
SERVICE_ACCOUNT_DEST=~/.gcp/appengine-account.json

gcloud iam service-accounts create \
    $SERVICE_ACCOUNT_NAME \
    --display-name $SERVICE_ACCOUNT_NAME

SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SERVICE_ACCOUNT_NAME" \
    --format='value(email)')

PROJECT=$(gcloud info --format='value(config.project)')

gcloud projects add-iam-policy-binding $PROJECT \
    --role roles/storage.admin \
    --member serviceAccount:$SA_EMAIL

gcloud projects add-iam-policy-binding $PROJECT \
    --role roles/appengine.appAdmin \
    --member serviceAccount:$SA_EMAIL

mkdir -p $(dirname $SERVICE_ACCOUNT_DEST)

gcloud iam service-accounts keys create $SERVICE_ACCOUNT_DEST \
    --iam-account $SA_EMAIL
```

Your service account JSON key now sits inside `$SERVICE_ACCOUNT_DEST`.

## Adding an Account

First, make sure that the provider is enabled:

```bash
hal config provider appengine enable
```

Next, run the following `hal` command to add an account named `my-appengine-account` to your list of App Engine accounts:

```bash
hal config provider appengine account add my-appengine-account \
  --project $PROJECT \
  --json-path $SERVICE_ACCOUNT_DEST
```

You can omit the `--json-path` flag if Spinnaker does not need service account credentials.

## Advanced Account Settings

Spinnaker deploys to App Engine by cloning your application source code from a git repository. Unless your code
is public, Spinnaker needs a mechanism to authenticate with your repositories - many of the configuration flags for
App Engine manage this authentication.

You can view the available configuration flags for App Engine within the
[Halyard reference](/reference/halyard/commands#hal-config-provider-appengine-account-add).

## Next Steps

Optionally, you can [set up another cloud provider](/setup/install/providers/), but otherwise you're ready to [Deploy Spinnaker](/setup/install/deploy/).
