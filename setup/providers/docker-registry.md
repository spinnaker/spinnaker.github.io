---
layout: single
title:  "Docker Registry"
sidebar:
  nav: setup
---

{% include toc %}

> :warning: This only acts as a source of images, and does not include support
> for deploying Docker images.

When configuring Docker Registries, an
[__Account__](/setup/providers/overview#accounts) maps to a credential able to
authenticate against a certain set of [Docker
repositories](https://docs.docker.com/glossary/?term=repository).

## Prerequisites

The Docker Registry you are configuring must already exist, support the [v2
registry API](https://docs.docker.com/registry/spec/api/), and have at least 1
[tag](https://docs.docker.com/glossary/?term=tag) among the repositories you
define in your Account. While each different supported registry supports the
same API, there are still some subtleties in getting them to work with
Spinnaker. Please make sure you read the section below corresponding to your
registry of choice:

* [DockerHub](#dockerhub)
* [Google Container Registry](#google-container-registry)

### DockerHub

The DockerHub registry address is `index.docker.io`, keep track of this for
later:

```
ADDRESS=index.docker.io
```

Dockerhub hosts a mix of public and private repositories, but does not expose a
[catalog](https://docs.docker.com/registry/spec/api/#listing-repositories)
endpoint to programatically list them. Therefore you need to explicitly list
which Docker repositories you want to index and deploy. For example, if you
wanted to deploy the public NGINX image, alongside your private `app` image,
your list of repositories would look like:

```
REPOSITORIES=library/nginx yourusername/app
```

If any of your images aren't publicly available, make sure you know your
DockerHub username & password to supply to `hal` later:

```
USERNAME=yourusername
PASSWORD=hunter2
```

### Google Container Registry

There are a few different registry addresses for GCR, depending on where you
want to store your images. A good starting point is `gcr.io`, but there [more
options
available](https://cloud.google.com/container-registry/docs/pushing#pushing_to_the_registry).

```
ADDRESS=gcr.io
```

Google Container Registry (GCR) supports the
[catalog](https://docs.docker.com/registry/spec/api/#listing-repositories)
endpoint to programatically list all images available to your credentials, so 
you don't need to worry about supplying them by hand. However, supplying 
credentials is not straight-forward.

There are [two
ways](https://cloud.google.com/container-registry/docs/advanced-authentication)
to authenticate against GCR. The first, using an access token, is problematic
for Spinnaker since the access token is short-lived. The second, using a
[service
account](https://cloud.google.com/compute/docs/access/service-accounts) is
preferred. The following steps will guide you through creating & downloading a
service account for your registry, assuming it exists as your currently
configured `gcloud` project.

```
SERVICE_ACCOUNT_NAME=spinnaker-gcr-account
SERVICE_ACCOUNT_DEST=~/.gcp/gcr-account.json

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

Once you have run these commands, your GCR password is sitting in a file
called `$SERVICE_ACCOUNT_DEST`. For Spinnaker to authenticate against GCR, keep
track of these environment vars to be passed to `hal` later:

```
# this is always the username for this authentication format
USERNAME=_json_key 
PASSWORD_FILE=$SERVICE_ACCOUNT_DEST
```

> :warning: You will want to supply `--password-file $PASSWORD_FILE` rather than 
> `--password $PASSWORD` below.

## Adding an Account

First, make sure that the provider is enabled:

```
hal config provider docker-registry enable
```

Assuming that your registry has address `$ADDRESS`, with repositories
`$REPOSITORIES`, username `$USERNAME`, and password `$PASSWORD`, run the
following `hal` command to add an account named `my-docker-registry` to
your list of Docker Registry accounts:

```
hal config provider docker-registry account add my-docker-registry \
    --address $ADDRESS \
    --repositories $REPOSITORIES \
    --username $USERNAME \
    --password $PASSWORD
```

## Advanced Account Settings

If you are looking for more configurability, please see the other options
listed in the [Halyard
Reference](https://github.com/spinnaker/halyard/blob/master/docs/commands.md#hal-config-provider-docker-registry-account-add).
