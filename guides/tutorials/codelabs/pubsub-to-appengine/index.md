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

This codelab assumes you have a billing-enabled GCP project. Also, [install gcloud](https://cloud.google.com/sdk/downloads) if you haven't already.

## Set up your environment

### Create a GCS bucket to store artifacts

In the environment where you have `gcloud` installed, run the following commands:

```
$ BUCKET_NAME=gs://<some_name> && PROJECT_ID=<project_id>
$ gcloud auth login
$ gsutil mb -p $PROJECT_ID $BUCKET_NAME
```

### Set up Google Cloud Pub/Sub to listen to bucket object changes

[GCP documentation includes the steps](https://cloud.google.com/storage/docs/reporting-changes) for configuring GCS to publish Pub/Sub messages, but here is a summary.

1. Enable the [Cloud Pub/Sub API](https://console.cloud.google.com/apis/api/pubsub.googleapis.com/).

2. Name your topic and subscription:

```
TOPIC_NAME=<topic>
SUBSCRIPTION_NAME=<subscription>
```

3. Create the GCS Pub/Sub notification:
`gsutil notification create -t $TOPIC_NAME -f json $BUCKET_NAME`.

4. Verify with `gsutil notification list $BUCKET_NAME`.

5. Create a pull subscription:
`gcloud pubsub subscriptions create $SUBSCRIPTION_NAME --topic $TOPIC_NAME`.

## Configure and deploy your Spinnaker instance

### Configure Spinnaker to deploy to GAE

If Spinnaker is not yet configured, follow this Halyard [quickstart](https://www.spinnaker.io/setup/quickstart/halyard-gce/), then
[configure the GAE cloud provider](https://www.spinnaker.io/setup/providers/appengine/).

Note that while configuring the GAE cloud provider, you will create a service account with `roles/storage.admin`
enabled and set two environment variables:

```
SERVICE_ACCOUNT_NAME=spinnaker-appengine-account
SERVICE_ACCOUNT_DEST=~/.gcp/appengine-account.json
```

In addition to the `roles/storage.admin`, the service account also needs `roles/pubsub.subscriber`.

Add the role to the service account:

```
gcloud projects add-iam-policy-binding $PROJECT \
    --role roles/pubsub.subscriber \
    --member serviceAccount:$SA_EMAIL # service account email from GAE setup.
```

Optionally generate a new service account key:

```
rm $SERVICE_ACCOUNT_DEST && gcloud iam service-accounts keys create $SERVICE_ACCOUNT_DEST \
    --iam-account $SA_EMAIL
```

We'll need this service account later, so keep these environment variables handy.

### Configure Spinnaker to listen to the Google Cloud Pub/Sub subscription

First, configure your GCS artifact provider.

1. Enable [artifact support](/reference/artifacts-with-artifactsrewrite//#enabling-artifact-support).

2. Enable the GCS artifact provider:
`hal config artifact gcs enable`

4. Add Spinnaker configuration for the GCS artifact provider's account:
`hal config artifact gcs account add --json-path $SERVICE_ACCOUNT_DEST my-artifact-account`

Note that we're using the environment variable set in configuring the GAE provider here.

Now configure Spinnaker to receive messages from your Google Cloud Pub/Sub subscription.

1. Enable Google Pub/Sub:
`hal config pubsub google enable`

2. Add your subscription to Google Pub/Sub:
`hal config pubsub google subscription add --project $PROJECT_ID --json-path $SERVICE_ACCOUNT_DEST --subscription-name $SUBSCRIPTION_NAME --message-format GCS my-gcs-subscription`

### Deploy Spinnaker with Halyard

Select a Spinnaker version: `hal config version edit --version <version>`. List the available versions with `hal version list`.

`sudo hal deploy apply`
Wait a few minutes for the deploy to complete.

## Configure your pipeline

1. Create an application:

    a. Navigate to the Spinnaker UI by going to `localhost:9000` in a browser.

    b. Create a new Spinnaker application by selecting `Actions` > `Create Application`.

    c. Give the application a name and an admin email. If you have more than one cloud provider configured, add 'appengine' to the `Cloud Providers`.

    d. Click the check box beside 'Consider only cloud provider health when executing tasks' and create the application.

2. Create a new pipeline and add an expected artifact.

    a. Select the `Pipelines` tab in the Spinnaker UI and click `Create` to create a new pipeline.

    b. After naming the pipeline, you will be brought to the pipeline configuration screen.

    c. Add an artifact under the `Expected Artifacts` section of the pipeline configuration.

    d. Select `GCS` as the artifact type.

    e. In the `Object path` text box, put `gs://$BUCKET_NAME/app.tar` with the explicit value for the bucket name (Spinnaker won't know about your environment variables).

3. Configure a pipeline trigger.

    a. In the `Automated Triggers` configuration section, add a new trigger.

    b. Select 'Pub/Sub' as the trigger type.

    c. Select 'google' as the `Pub/Sub System Type` and select 'my-gcs-subscription' as the `Subscription Name`.

    d. Add an attribute constraint with key 'eventType' and value 'OBJECT_FINALIZE'. This prevents your pipeline from triggering twice from one GCS event.

    e. Select the '.../app.tar' expected artifact in the `Expected Artifacts` drop down.

    f. Save the pipeline with the `Save Changes` button in the bottom right corner of the pipeline configuration screen.

4. Create and configure a deploy stage in your pipeline.

    a. Click `Add stage` near the top of the configuration screen to add a new stage.

    b. Select 'Deploy' as the stage `Type`. Click `Add server group` to open the server group configuration modal.

    c. In `Basic Settings`, select 'GCS' as the `Source Type`.

    d. Select 'my-artifact-account' as the `Storage Account`.

    e. Select 'via pipeline artifact' in `Resolve URL`.

    f. Select the '.../app.tar' artifact in the `Expected Artifact` drop down.

    g. In `Config Files`, add 'app.yaml' in the `Config Filepaths`.

## Package and upload your application to GCS

### Acquire a "Hello World" application and upload to GCS

1. Clone a sample GAE application:
`git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git`

2. Package your application as a tarball:
`cd python-docs-samples/appengine/standard/hello_world; tar -cvf app.tar *`

3. Upload the tarball to the GCS bucket:
`gsutil cp app.tar $BUCKET_NAME`
