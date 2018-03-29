---
layout: single
title:  "Receiving artifacts from GCS"
sidebar:
  nav: guides
---

{% include alpha version="1.6" %}

{% include toc %}

This guide explains how to configure Spinnaker to trigger pipelines based on
changes in a [Google Cloud Storage](https://cloud.google.com/storage/) (GCS)
bucket, and inject changed GCS objects as [artifacts](/reference/artifacts)
into a pipeline.

This functionality uses Google's
[Pub/Sub](https://cloud.google.com/pubsub/docs/overview) system for delivering
messages to Spinnaker, and must be configured to send messages to
Spinnaker's event bus as shown below.

# Prerequisite configuration/setup

If you (or your Spinnaker admin) has already configured Spinnaker to listen to
a Pub/Sub messages from the GCS bucket you plan to publish objects to, you can
skip this section. _One Pub/Sub subscription can be used to trigger as many
independent Spinnaker pipelines as needed_.

You need the following:

* A billing enabled [Google Cloud Platform (GCP)
  project](https://cloud.google.com/storage/docs/projects).

  This will be referred to as `$PROJECT` from now on.

* [`gcloud`](https://cloud.google.com/sdk/gcloud/). Make sure to run `gcloud
  auth login` if you have installed `gcloud` for the first time.

* [A running Spinnaker instance](/setup/install). This guide shows you how
  to configure an existing one to accept GCS messages, and download the files
  referenced by the messages in your pipelines.

At this point, we will configure Pub/Sub, and a GCS artifact account. The
intent is that the Pub/Sub messages will be received by Spinnaker whenever a
file is uploaded or changed, and the artifact account will allow you to
download these where necessary.

## 1. Configure Google Pub/Sub for GCS

Follow the [Pub/Sub configuration](/setup/triggers/google/), in particular, pay
attention to the [GCS
section](/setup/triggers/google/#receiving-messages-from-google-cloud-storage-gcs)
since this is where we'll be publishing our files to.

## 2. Configure a GCS artifact account

Follow the [GCS artifact configuration](/setup/artifacts/gcs/).

## 3. Apply your configuration changes

Once the Pub/Sub and artifact changes have been made using Halyard, run

```bash
hal deploy apply
```

to apply them in Spinnaker.

# Using GCS artifacts in pipelines

We will need either an existing or a new pipeline that we want to be triggered
on changes to GCS artifacts. If you do not have a pipeline, create one as shown
below.

{%
  include
  figure
  image_path="./create-pipeline.png"
  caption="You can create and edit pipelines in the __Pipelines__ tab of
  Spinnaker"
%}

## Configure the GCS artifact

Once you have your pipeline ready, we need to declare that this pipeline
expects to have a specific artifact matching some criteria is available before
the pipeline starts executing. In doing so, you guarantee that an artifact
matching your description is present in the pipeline's execution context; if no
artifact for this description is present, the pipeline won't start.

{%
  include
  figure
  image_path="./add-artifact.png"
%}

Now to configure the artifact, change the "Custom" dropdown to "GCS", and enter
the fully qualifed GCS path in the __Object path__ field. Note: this path can be
a regex. You can, for example, set the object path to be
`gs://${BUCKET}/folder/.*` to trigger on any change to an object inside
`folder` in your `${BUCKET}`.

{%
  include
  figure
  image_path="./set-expected-artifact.png"
  caption="`${BUCKET}` is a placeholder for the GCS bucket name that you have
  configured to receive Pub/Sub messages from above."
%}

## Configure the GCS trigger

Now that the expected artifact has been added, let's add a Pub/Sub trigger to
run our pipeline.

{%
  include
  figure
  image_path="./add-trigger.png"
%}

Next, we must configure the trigger: 

* __Type__ is "Pub/Sub".
* __Pub/Sub System Type__ is "Google".
* __Subscription Name__ depends on what you've configured in your Pub/Sub
  configuration using Halyard.
* __Attribute Constraints__ must be configured to include the pair `eventType`:
  `OBJECT_FINALIZE` (see the
  [docs](https://cloud.google.com/storage/docs/pubsub-notifications#events) for
  an explanation). 
* __Expected Artifacts__ must reference the artifact defined previously.

{%
  include
  figure
  image_path="./pubsub-config.png"
  caption="By setting the __Expected Artifacts__ field in the trigger config,
  you guarantee that this pubsub subscription will only trigger this pipeline
  when an artifact matching your requirements is present in the pubsub
  message."
%}

## Test the pipeline

If you upload a file to a path matching your configured __Object path__,
the pipeline should execute. If it doesn't, you can start by checking the logs
in the __Echo__ service.



