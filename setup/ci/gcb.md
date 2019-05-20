---
layout: single
title:  "Google Cloud Build"
sidebar:
  nav: setup
---

{% include toc %}

Setting up [Google Cloud Build](https://cloud.google.com/cloud-build/) as a Continuous Integration (CI)
system within Spinnaker allows you to:
 * trigger pipelines when a GCB build completes
 * add a GCB stage to your pipeline

## Prerequisites

You need to have a [Google Cloud Platform](https://cloud.google.com) project with the
[Cloud Build API](http://console.cloud.google.com/apis/library/cloudbuild.googleapis.com) enabled.
You can enable the API with the following `gcloud` command:

```
gcloud services enable cloudbuild.googleapis.com
```

Google Cloud Build sends [Build Notifications](https://cloud.google.com/cloud-build/docs/send-build-notifications)
when the state of your build changes.  Spinnaker subscribes to these pub/sub messages so that in can track the status
of builds it has initiated in a GCB stage and to trigger pipelines based on build status changes.

Create a Subscription object for the `cloud-builds` topic in your project:

    ```
    PROJECT_ID=
    SUBSCRIPTION_NAME=spinnaker-cloud-build

    gcloud pubsub subscriptions create $SUBSCRIPTION_NAME \
      --topic projects/$PROJECT_ID/topics/cloud-builds \
      --project $PROJECT_ID
    ```
    
Finally, you will need a service account that has both Cloud Build Editor and Pub/Sub Subscriber permissions, which is
assumed to be in a file at path `$SERVICE_ACCOUNT_KEY` in the below commands.

## Configure Spinnaker for Google Cloud Build Support

Use the following Halyard command to create a GCB account, enable the GCB integration, and re-deploy Spinnaker.
```
    hal config ci gcb account add $ACCOUNT_NAME \
      --project $PROJECT_ID \
      --subscription-name $SUBSCRIPTION_NAME \
      --json-key $SERVICE_ACCOUNT_KEY

    hal config ci gcb enable
    
    hal deploy apply
```

## Configure Your Pipeline Trigger

1. In your Pipeline configuration, click the **Configuration** stage on the far left of the pipeline diagram.

2. Click **Automated Triggers**.

3. In the **Type** field, select `Pub/Sub`.

4. In the **Pub/Sub System Type** field, select `google`.

5. In the **Subscription Name** field, select your `$ACCOUNT_NAME` value.

6. In the **Attribute Constraints** field, enter `status` in the **Key**, and `SUCCESS` (all upper case) in the **Value** field.

7. In the **Payload Constraints** field, you can enter any of the top-level fields from the
[Build object documentation](https://cloud.google.com/cloud-build/docs/api/reference/rest/v1/projects.builds#resource-build)
as the key, and a Java regular expression as the value.

8. In the **Expected Artifacts** field, you can add any build artifacts as expected artifacts. For example,
if the build produces a Docker image, you can add an expected artifact of type *Docker* with a value of
`gcr.io/my-project-id/my-application` (replacing `my-project-id` and `my-application` with
appropriate values). You can then [use the produced image](/reference/artifacts/in-pipelines/)
in downstream stages.

## Configure a Google Cloud Build Stage

To run a Google Cloud Build as part of a Spinnaker pipeline, create a stage of type *Google Cloud Build*.  Configure the
stage by selecting the GCB account to use to run the build, and entering the [build configuration YAML](https://cloud.google.com/cloud-build/docs/build-config)
in the provided text box:
![](/setup/ci/gcb_config.png)
You may also provide the build definition YAML as an artifact.

In the *Produces Artifacts* section, you may supply any artifacts that you expect the build to create in order to
make these artifacts available to downstream stages.  Google Cloud Build supports creating either GCS or Docker image
[artifacts](https://cloud.google.com/cloud-build/docs/configuring-builds/store-images-artifacts), either of which
will be converted to Spinnaker artifacts and injected into the pipeline on completion of the build.

While your build is executing, the stage details will provide the current status of the build and a link to view
the build logs in the Google Cloud Console:
![](/setup/ci/gcb_status.png)

## Configuration via Pub/Sub

Prior to version 1.14, Spinnaker did not have built-in support for Google Cloud Build, but pipelines could be
triggered on changes to the build status by directly listening on the Pub/Sub subscription.

    ```
    hal config pubsub google subscription add $PUBSUB_SUBSCRIPTION_NAME \
      --project $PROJECT_ID \
      --subscription-name $SUBSCRIPTION_NAME \
      --message-format GCB

    hal config pubsub google enable

    hal deploy apply
    ```

The steps to create a pipeline trigger in this case are exactly the same except that the **Subscription Name** field
should be set to `$PUBSUB_SUBSCRIPTION_NAME`.

These two methods of triggering pipelines on GCB builds can co-exist, with two important caveats:
* Pub/Sub subscriptions can only have a single listener, so you cannot use the same Pub/Sub subscription in both the
`hal conifg pubsub` command and the `hal config ci gcb` commands.  Instead you should create two subscriptions listening
to your `cloud-builds` topic and use one in each command.
* Builds triggered using the direct Pub/Sub configuration will not correctly inject GCS artifacts produced by the build.
This is because the Pub/Sub message does not directly contain the artifacts, only a reference to a manifest in GCS.
