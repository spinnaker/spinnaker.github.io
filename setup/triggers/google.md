---
layout: single
title:  "Google Cloud Pub/Sub"
sidebar:
  nav: setup
---

{% include toc %}

Spinnaker pipelines can be triggered using a [Google Pub/Sub
subscription](https://cloud.google.com/pubsub/docs/overview){:target="\_blank"}.

# Prerequisites

You need a [Google Cloud Platform](https://cloud.google.com/){:target="\_blank"}
(GCP) project to with the [Pub/Sub API
enabled](https://pantheon.corp.google.com/apis/api/pubsub.googleapis.com){:target="\_blank"},
and [`gcloud`](https://cloud.google.com/sdk/downloads){:target="\_blank"}
installed locally.  You can check that `gcloud` is installed and authenticated
by running:

```bash
gcloud info
```

## A Pub/Sub subscription

The Pub/Sub integration can be used to either:

* Start pipelines by sending Pub/Sub messages from a system you own.

* Start pipelines using Pub/Sub messages originating from a Google Cloud
  system, such as [Google Cloud Storage](https://cloud.google.com/storage/){:target="\_blank"},
  or [Google Container Registry](https://cloud.google.com/container-registry/){:target="\_blank"}.

Configuration and setup for all cases are described below.

### Sending your own Pub/Sub messages

First, record the fact that your `$MESSAGE_FORMAT` is `CUSTOM`, this will be
needed later.

```bash
MESSAGE_FORMAT=CUSTOM
```

You need a topic with name `$TOPIC` to publish messages to:

```bash
gcloud beta pubsub topics create $TOPIC
```

This topic needs a a pull subscription named `$SUBSCRIPTION` to let Spinnaker
read messages from. _It is important that Spinnaker is the only system reading
from this single subscription. You can always create more subscriptions for
this topic if you want multiple systems to recieve the same messages._

```bash
gcloud beta pubsub subscriptions create $SUBSCRIPTION --topic $TOPIC
```

At this point, you can use the [publisher
guide](https://cloud.google.com/pubsub/docs/publisher){:target="\_blank"} to
learn how to publish messages programmatically to the topic you have created.

Note that your topic messages need to be valid JSON, otherwise an exception
will be raised.

### Receiving messages from Google Cloud Storage (GCS)

First, record the fact that your `$MESSAGE_FORMAT` is `GCS`, this will be
needed later.

```bash
MESSAGE_FORMAT=GCS
```

Given that you'll be listening to changes in a GCS bucket (`$BUCKET`), the
following command will create (or use an existing) topic with name `$TOPIC` to
publish messages to:

```bash
gsutil notification create -t $TOPIC -f json gs://${BUCKET}
```

Finally, create a pull subscription named `$SUBSCRIPTION` to listen to changes
to this topic:

```bash
gcloud beta pubsub subscriptions create $SUBSCRIPTION --topic $TOPIC
```

To understand the format that GCS will publish messages in, please read the
[reference
material](https://cloud.google.com/storage/docs/pubsub-notifications){:target="\_blank"}.

### Receiving messages from Google Container Registry (GCR)

{% include
   warning
   content="The GCR message type extracts the image digest by default, but
   Google App Engine doesn't support deploying from a digest. So if you're
   using artifacts from GCR messages to trigger a GAE deployment, you need
   to use a custom message template. The template must copy the image's tag
   into the artifact's reference and version fields."
%}

First, record the fact that your `$MESSAGE_FORMAT` is `GCR`, this will be
needed later.

```bash
MESSAGE_FORMAT=GCR
```

Given a project name `$PROJECT`, GCR will always try to publish messages to a
topic named `projects/${PROJECT}/topics/gcr` for any repositories in
`$PROJECT`. To ensure that GCR has a valid topic to publish to, try to create
the following topic:

```bash
gcloud beta pubsub topics create projects/${PROJECT}/topics/gcr
```

If the command fails with "Resource already exists in the project", then the
topic already exists (which is OK).

Finally, create a pull subscription named `$SUBSCRIPTION` to listen to changes
to this topic:

```bash
gcloud beta pubsub subscriptions create $SUBSCRIPTION \
  --topic projects/${PROJECT}/topics/gcr
```

To understand the format that GCR will publish messages in, please read the
[reference
material](https://cloud.google.com/container-registry/docs/configuring-notifications){:target="\_blank"}.

## Credentials

Spinnaker needs a [service
account](https://cloud.google.com/compute/docs/access/service-accounts){:target="\_blank"} to
authenticate as against GCP, with the `roles/pubsub.subscriber` role enabled. If
you don't already have such a service account with the corresponding JSON key
downloaded, you can run the following commands to do so:

```bash
SERVICE_ACCOUNT_NAME=spinnaker-pubsub-account
SERVICE_ACCOUNT_DEST=~/.gcp/pubsub-account.json

gcloud iam service-accounts create \
    $SERVICE_ACCOUNT_NAME \
    --display-name $SERVICE_ACCOUNT_NAME

SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SERVICE_ACCOUNT_NAME" \
    --format='value(email)')

PROJECT=$(gcloud info --format='value(config.project)')

gcloud projects add-iam-policy-binding $PROJECT \
    --role roles/pubsub.subscriber --member serviceAccount:$SA_EMAIL

mkdir -p $(dirname $SERVICE_ACCOUNT_DEST)

gcloud iam service-accounts keys create $SERVICE_ACCOUNT_DEST \
    --iam-account $SA_EMAIL
```

{% include
   warning
   content="It's possible to restrict access to a subscription by service
   account in GCP. If this is how your subscription is configured, you may need
   to grant `$SA_EMAIL` additional permissions following the instructions on the
   [Pub/Sub IAM page](https://cloud.google.com/pubsub/docs/access_control){:target='\_blank'}."
%}

Once you have run these commands, your GCS JSON key is sitting in a file
called `$SERVICE_ACCOUNT_DEST`.

# Editing your Pub/Sub settings

All that's required are the following values:

```bash
# See 'Credentials' section above
SERVICE_ACCOUNT_DEST=

# See 'A Pub/Sub Subscription' section above
MESSAGE_FORMAT=
PROJECT=
SUBSCRIPTION=

# You can pick this name, it's meant to be human-readable
PUBSUB_NAME=my-google-pubsub
```

First, make sure that Google Pub/Sub support is enabled:

```bash
hal config pubsub google enable
```

Next, add your subscription

```bash
hal config pubsub google subscription add $PUBSUB_NAME \
    --subscription-name $SUBSCRIPTION \
    --json-path $SERVICE_ACCOUNT_DEST \
    --project $PROJECT \
    --message-format $MESSAGE_FORMAT
```

There are more options described
[here](/reference/halyard/commands/#hal-config-pubsub-google-subscription-edit)
if you need more control over your configuration.
