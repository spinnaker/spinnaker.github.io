---
layout: single
title: "Codelab: Deploying GCS Pub/Sub Artifacts to App Engine"
sidebar:
  nav: guides
---

{% include toc %}

The goal of this codelab is to trigger a Spinnaker pipeline with a Pub/Sub message from GCS upon upload of a tarball. 

In this codelab, you will deploy artifacts to Google App Engine (GAE) via a Spinnaker pipeline.
The pipeline is configured to trigger on Pub/Sub messages from a GCS bucket serving as an artifact repository.
The Pub/Sub messages contain context that allows Spinnaker to parse and deploy the stored artifacts.

This codelab takes about an hour.

## Prerequisites

This codelab assumes you have a billing-enabled GCP project.

## Set Up Your Environment

### Create a GCS Bucket to store Artifacts

In the environment where you have `gcloud` installed, run the following commands:

```
$ export BUCKET_NAME=gs://<some_name> && export PROJECT_ID=<project_id>
$ gcloud auth login
$ gsutil mb -p $PROJECT_ID $BUCKET_NAME
```

### Set up Google Cloud Pub/Sub to listen to bucket object changes

[GCP documentation includes the steps](https://cloud.google.com/storage/docs/reporting-changes) for configuring GCS to publish Pub/Sub messages, but here is a summary.

1. Enable the [Cloud Pub/Sub API](https://cloud.google.com/pubsub/docs/apis).

2. `export TOPIC_NAME=<topic>` and `export SUBSCRIPTION_NAME=<subscription>`.

3. `gsutil notification create -t $TOPIC_NAME -f json $BUCKET_NAME`.

4. Verify with `gsutil notification list $BUCKET_NAME`.

5. Create a pull subscription with `gcloud beta Pub/Sub subscriptions create $SUBSCRIPTION_NAME --topic $TOPIC_NAME`.

## Configure and Deploy Your Spinnaker instance

### Configure Spinnaker to deploy to GAE

If Spinnaker is not yet configured, follow this Halyard [quickstart](https://www.spinnaker.io/setup/quickstart/halyard-gce/), then 
[configure the GAE cloud provider](https://www.spinnaker.io/setup/providers/appengine/).

### Configure Spinnaker to listen to the Google Cloud Pub/Sub subscription

Configure your GCS artifact provider.

1. `hal config features edit --artifacts true`.

2. `hal config artifact gcs enable`.

3. `hal config artifact gcs account add --json-path <key> <artifact_account>`.

Configure Spinnaker to receive messages from your Google Cloud Pub/Sub subscription.

1. `hal config Pub/Sub google enable`.

2. Create a JSON file and add the following contents to the file:

    ```
    [
      {
        "reference": "{{ bucket }}/{{ name }}",
        "name": "gs://{{ bucket }}/{{ name }}",
        "type": "gcs/object"
      }
    ]
    ```

    This is a [Jinja](http://jinja.pocoo.org/docs/2.9/) template that defines the tranformation from the Pub/Sub message structure to the artifact format
    Spinnaker understands. The JSON snippet above defines the mapping specific to the GCS Pub/Sub message, but these are entirely
    user-supplied and can specify any valid Jinja transformation.

    Make sure the file permissions on this template file are configured so that Spinnaker can read it: `sudo chown spinnaker <template>`.

3. `hal config Pub/Sub google subscription add --project $PROJECT_ID --json-path <key> --subscription-name $SUBSCRIPTION_NAME --template-path <template> <subscription_name>`.

### Deploy Spinnaker with Halyard

Run `hal deploy apply`. Wait a few minutes for the deploy to complete.

## Configure Your Pipeline

1. Declare your application tarball as an expected artifact in the "Expected Artifacts" section.

 ![Declare expected artifact](images/01_expected_artifacts.png)

2. Add a Pub/Sub trigger to your pipeline, select the *Pub/Sub System Type*, *Subscription Name*, and add the tarball as an expected
artifact.

 ![Trigger configuration](images/02_trigger_config.png)

3. Add a deploy stage with one server group.

    - Select a *Source Type* of *GCS*.

    - Select your configured *Storage Account* from the dropdown.

    - Select *via pipeline artifact* for *Resolve URL*.

    - Select your configured "app.tar" expected artifact.

 ![Deployment configuration](images/03_deploy_config.png)

## Package and upload your application to GCS

### Acquire a "Hello World" application and upload to GCS

1. Clone a sample GAE application: `git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git`.

2. Package your application as a tarball: `cd python-docs-samples/appengine/standard/hello_world tar -cvf app.tar *`.

3. Upload the tarball to the GCS bucket: `gsutil cp app.tar $BUCKET_NAME`.
