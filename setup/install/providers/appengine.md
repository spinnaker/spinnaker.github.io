---
layout: single
title:  "Google App Engine"
sidebar:
  nav: setup
redirect_from: /setup/providers/appengine/
---

{% include toc %}

In [Google App Engine](https://cloud.google.com/appengine){:target="\_blank"}, an
[__Account__](/concepts/providers/#accounts) maps to a credential able to
authenticate against a given [Google Cloud
Platform](https://cloud.google.com){:target="\_blank"} project.

## Prerequisites

You need a [Google Cloud Platform](https://cloud.google.com/){:target="\_blank"}
project to run Spinnaker against. The next steps assume you've already [created
a project](https://cloud.google.com/resource-manager/docs/creating-managing-projects){:target="\_blank"},
and installed [`gcloud`](https://cloud.google.com/sdk/downloads){:target="\_blank"}.
You can check that `gcloud` is installed and authenticated by running:

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
gcloud services enable appengine.googleapis.com
```

## Downloading credentials

Spinnaker does not need to be given [service account](https://cloud.google.com/compute/docs/access/service-accounts){:target="\_blank"}
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

## Adding an account

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

## Deploying to App Engine

### Deploying from Git

Spinnaker supports deploying your source code to App Engine by cloning your application's git
repository and submitting it to App Engine. Unless your code is public, Spinnaker needs a mechanism to
authenticate with your repositories - many of the configuration flags for App Engine manage this
authentication.

You can view the available configuration flags for App Engine within the
[Halyard reference](/reference/halyard/commands#hal-config-provider-appengine-account-add).

### Deploying from storage

Much like deploying from Git, Spinnaker also supports deploying your source code to App Engine
from a Google Cloud Storage bucket.  This method of deploying requires you to bundle your code
into a .tar archive and then store that on GCS.  When the deploy stage executes, Spinnaker will
fetch your tar archive, untar it, and then deploy the code to App Engine.

### Deploying from Google Container Registry URL

Spinnaker supports deploying Docker containers on the App Engine Flex runtime from images built and stored
in Google Container Registry from just a gcr.io URL.  This feature is currently flagged because it is still quite new.

In order to enable this feature, set the flag with Halyard like so:

```bash
hal config features edit --appengine-container-image-url-deployments true
```

After doing this you'll find an option in the Create Server Group modal in Deck to use a Container Image as a
deployment's Source Type.

Selecting the Container Image option reveals a textbox that can then be used to specify the gcr.io URL.  Alternatively
you can use an Artifact as the source of the container image URL.

## Next steps

Optionally, you can [set up another cloud provider](/setup/install/providers/),
but otherwise you're ready to [choose an environment](/setup/install/environment/)
in which to install Spinnaker.
