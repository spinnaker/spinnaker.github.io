---
layout: single
title:  "Google Cloud Build"
sidebar:
  nav: setup
---

{% include toc %}

Setting up [Google Cloud Build](https://cloud.google.com/cloud-build/) as a Continuous Integration (CI)
system within Spinnaker enables triggering pipelines when builds complete.

## Prerequisites

You need to have a [Google Cloud Platform](https://cloud.google.com) project with the
[Cloud Build API](http://console.cloud.google.com/apis/library/cloudbuild.googleapis.com) enabled.
You can enable the API with the following `gcloud` command:

```
gcloud services enable cloudbuild.googleapis.com
```

## Configure Spinnaker to Listen for Google Cloud Build Pub/Sub Notifications

Google Cloud Build sends [Build Notifications](https://cloud.google.com/cloud-build/docs/send-build-notifications)
when the state of your build changes. You can create a pipeline trigger to invoke a pipeline based
on the status of your build.

1. Create a Subscription object for the `cloud-builds` topic in your project:

    ```
    PROJECT_ID=
    SUBSCRIPTION_NAME=gCloudBuilds

    gcloud pubsub subscriptions create $SUBSCRIPTION_NAME \
      --topic projects/$PROJECT_ID/topics/cloud-builds \
      --project $PROJECT_ID
    ```

2. Configure and deploy Spinnaker via Halyard with your newly created subscription.

    ```
    hal config pubsub google subscription add $SUBSCRIPTION_NAME \
      --project $PROJECT_ID \
      --subscription-name $SUBSCRIPTION_NAME \
      --message-format GCB

    hal config pubsub google enable

    hal deploy apply
    ```

## Configure Your Pipeline Trigger

1. In your Pipeline configuration, click the **Configuration** stage on the far left of the pipeline diagram.

2. Click **Automated Triggers**.

3. In the **Type** field, select `Pub/Sub`.

4. In the **Pub/Sub System Type** field, select `google`.

5. In the **Subscription Name** field, select your `$SUBSCRIPTION_NAME` value.

6. In the **Attribute Constraints** field, enter `status` in the **Key**, and `SUCCESS` (all upper case) in the **Value** field.

7. In the **Payload Constraints** field, you can enter any of the top-level fields from the
[Build object documentation](https://cloud.google.com/cloud-build/docs/api/reference/rest/v1/projects.builds#resource-build)
as the key, and a Java regular expression as the value.

8. In the **Expected Artifacts** field, you can add any build artifacts as expected artifacts. For example,
if the build produces a Docker image, you can add an expected artifact of type *Docker* with a value of
`gcr.io/my-project-id/my-application` (replacing `my-project-id` and `my-application` with
appropriate values). You can then [use the produced image](/reference/artifacts/in-pipelines/)
in downstream stages.
