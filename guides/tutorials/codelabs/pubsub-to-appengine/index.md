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

## Set Up Your Environment

### Create a GCS Bucket to store artifacts

In the environment where you have `gcloud` installed, run the following commands:

```
$ BUCKET_NAME=gs://<some_name> && PROJECT_ID=<project_id>
$ gcloud auth login
$ gsutil mb -p $PROJECT_ID $BUCKET_NAME
```

### Set up Google Cloud Pub/Sub to listen to bucket object changes

[GCP documentation includes the steps](https://cloud.google.com/storage/docs/reporting-changes) for configuring GCS to publish Pub/Sub messages, but here is a summary.

1. Enable the [Cloud Pub/Sub API](https://cloud.google.com/pubsub/docs/apis).

2. Name your topic and subscription:

```
TOPIC_NAME=<topic>
SUBSCRIPTION_NAME=<subscription>`
```

3. Create the GCS Pub/Sub notification:
`gsutil notification create -t $TOPIC_NAME -f json $BUCKET_NAME`.

4. Verify with `gsutil notification list $BUCKET_NAME`.

5. Create a pull subscription:
`gcloud beta Pub/Sub subscriptions create $SUBSCRIPTION_NAME --topic $TOPIC_NAME`.

## Configure and Deploy Your Spinnaker instance

### Configure Spinnaker to deploy to GAE

If Spinnaker is not yet configured, follow this Halyard [quickstart](https://www.spinnaker.io/setup/quickstart/halyard-gce/), then
[configure the GAE cloud provider](https://www.spinnaker.io/setup/providers/appengine/).

Note that while configuring the GAE cloud provider, you will create a service account with the `roles/storage.admin`
enabled and set two environment variables:

```
SERVICE_ACCOUNT_NAME=spinnaker-appengine-account
SERVICE_ACCOUNT_DEST=~/.gcp/appengine-account.json
```

We'll need this service account later, so keep these variables handy.

### Configure Spinnaker to listen to the Google Cloud Pub/Sub subscription

First, configure your GCS artifact provider.

1. Enable artifiact support:
`hal config features edit --artifacts true`.

2. Enable the GCS artifact provider:
`hal config artifact gcs enable`

4. Add Spinnaker configuration for the GCS artifact provider's account:
`hal config artifact gcs account add --json-path $SERVICE_ACCOUNT_DEST my-artifact-account`

Note that we're using the environment variable set in configuring the GAE provider here.

Now configure Spinnaker to receive messages from your Google Cloud Pub/Sub subscription.

1. Enable Google Pub/Sub:
`hal config pubsub google enable`

2. Create a transformation template file.

    a. Create a JSON file named 'gcs-jinja.json' and add the following contents to the file:

    <script src="https://gist.github.com/spinnaker-release/3f72a7efe5bc7914ba81170af6a59ffa.js"></script>

    This is a [Jinja](http://jinja.pocoo.org/docs/2.9/) template that defines the tranformation from the Pub/Sub message structure to the artifact format
    Spinnaker understands. The JSON snippet above defines the mapping specific to the GCS Pub/Sub message, but these are entirely
    user-supplied and can specify any valid Jinja transformation.

    Here is an example message payload from uploading an object to a GCS bucket:

    ```
    {
      "kind": "storage#object",
      "id": "gcs-pub-sub/app.tar/1511803705417483",
      "selfLink": "https://www.googleapis.com/storage/v1/b/gcs-pub-sub/o/app.tar",
      "name": "app.tar",
      "bucket": "gcs-pub-sub",
      "generation": "1511803705417483",
      "metageneration": "1",
      "contentType": "application/x-tar",
      "timeCreated": "2017-11-27T17:28:25.218Z",
      "updated": "2017-11-27T17:28:25.218Z",
      "storageClass": "MULTI_REGIONAL",
      "timeStorageClassUpdated": "2017-11-27T17:28:25.218Z",
      "size": "20480",
      "md5Hash": "K8fipg9xurPwrBEEfrkP9w==",
      "mediaLink": "https://www.googleapis.com/download/storage/v1/b/gcs-pub-sub/o/app.tar?generation=1511803705417483&alt=media",
      "crc32c": "T4DRpw==",
      "etag": "CIu+09aj39cCEAE="
    }
    ```

    Any of the keys present in this message can be used in the transformation definition. Jinja is expressive, so you can even include
    things like loops, array indices, and paths to sub-objects in your template. The only constraint on the template file is that
    the resultant object must match [the artifact model class](https://github.com/spinnaker/kork/blob/master/kork-artifacts/src/main/java/com/netflix/spinnaker/kork/artifacts/model/Artifact.java),
    and that one must be supplied to Spinnaker.

    b. Store the path to 'gcs-jinja.json' as an environment variable for the next step:
    `TEMPLATE_PATH="$(pwd)/gcs-jinja.json"`

    c. Make sure the file permissions on this template file are configured so that Spinnaker can read it:
    `sudo chown spinnaker $TEMPLATE_PATH`


3. Add your subscription to Google Pub/Sub:
`hal config pubsub google subscription add --project $PROJECT_ID --json-path $SERVICE_ACCOUNT_DEST --subscription-name $SUBSCRIPTION_NAME --template-path $TEMPLATE_PATH my-gcs-subscription`

### Deploy Spinnaker with Halyard

`sudo hal deploy apply`
Wait a few minutes for the deploy to complete.

## Configure Your Pipeline

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

    d. Select the '.../app.tar' expected artifact in the `Expected Artifacts` drop down.

    e. Save the pipeline with the `Save Changes` button in the bottom right corner of the pipeline configuration screen.

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
`cd python-docs-samples/appengine/standard/hello_world tar -cvf app.tar *`

3. Upload the tarball to the GCS bucket:
`gsutil cp app.tar $BUCKET_NAME`
