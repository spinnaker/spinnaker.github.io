---
 layout: single
 title:  "Deploy GCS Pub/Sub Artifacts to CF"
 sidebar:
   nav: guides
---
 
 {% include toc %}

> This codelab assumes that you have enabled the `artifactsRewrite` feature flag. In `~/.hal/$DEPLOYMENT/profiles/settings-local.js` (where `$DEPLOYMENT` is typically `default`), add:
>
> `window.spinnakerSettings.feature.artifactsRewrite = true;`
 
In this codelab, you will deploy an artifact to Cloud Foundry via a Spinnaker pipeline that is triggered by JAR uploads to a Google Cloud Storage (GCS) bucket.

## Prerequisites

This codelab assumes you have the following:

1. A billing-enabled Google Cloud Platform (GCP) project.
1. The `gcloud` CLI tool (installed locally on your computer).

## 1. Create a GCS Bucket for Artifact Storage

a. Log in with `gcloud`:

  ```
  $ gcloud auth login
  ```

b. Run the `gsutil mb` command to create a bucket within your GCP project, giving your project’s ID (`PROJECT_ID` below) and the name of the bucket to create (`BUCKET`):

  ```
  $ PROJECT_ID=<Insert Project ID>
  $ BUCKET=gs://<Insert Bucket Name>
  $ gsutil mb -p $PROJECT_ID $BUCKET
  ```

## 2. Enable Google Cloud Pub/Sub

a. Enable the GCP Cloud Pub/Sub API, then use `gsutil` to create a Pub/Sub notification, giving a topic name (`TOPIC`) and your GCS bucket name (`BUCKET`):

  ```
  $ TOPIC=<Insert Topic Name>
  $ gsutil notification create -t $TOPIC -f json $BUCKET
  ```

b. Now create a pull subscription, giving a subscription name (`GCP_SUB_NAME`) and the topic name used in the last command (`TOPIC`):

  ```
  $ GCP_SUB_NAME=<Insert Subscription Name>
  $ gcloud beta pubsub subscriptions create $GCP_SUB_NAME --topic $TOPIC
  ```

## 3. Create a GCP Service Account

a. Following the GCP documentation on [Creating and Managing Service Accounts](https://cloud.google.com/iam/docs/creating-managing-service-accounts), create a new service account, giving it the Storage Admin (`roles/storage.admin`) and Pub/Sub Subscriber (`roles/pubsub.subscriber`) roles.

b. Create a key for the service account and download the key in JSON format to your computer. In this codelab, the path to the JSON key file will be referred to as `JSON_SA_KEY`:

  ```
  $ JSON_SA_KEY=<Insert Path to Service Account Key JSON File>
  ```

## 4. Tell Spinnaker to Use the Pub/Sub Subscription

a. Enable artifact support, then enable the GCS artifact provider:

  ```
  $ hal config features edit --artifacts true
  $ hal config artifact gcs enable
  ```

b. Now add an artifact account for your GCS bucket, providing the path to the service account JSON key file and an account name (`ACCOUNT` below):

  ```
  $ ACCOUNT=<Insert Account Name>
  $ hal config artifact gcs account add --json-path $JSON_SA_KEY $ACCOUNT
  ```

c. Enable GCP Cloud Pub/Sub support:

  ```
  $ hal config pubsub google enable
  ```

d. Finally, add the subscription you created in step 2, providing a subscription name (`SPIN_SUB_NAME`), your GCP project’s name (`PROJECT_NAME`), the GCP Cloud Pub/Sub subscription name (`GCP_SUB_NAME`), and the path to the service account JSON key file:

  ```
  $ SPIN_SUB_NAME=<Insert Spinnaker Subscription Name>
  $ PROJECT_NAME=<Insert GCP Project Name>
  $ hal config pubsub google subscription add $SPIN_SUB_NAME \
  --project $PROJECT_NAME \
  --subscription-name $GCP_SUB_NAME \
  --message-format GCS \
  --json-path $JSON_SA_KEY
  ```

e. Apply your changes:

  ```
  $ hal deploy apply
  ```

## 5. Configure the Application and Pipeline

a. Create a new pipeline for your application. In the pipeline configuration, under Automated Triggers, add a new trigger and configure it as follows:

  * For **Type**, select "Pub/Sub".
  * For **Pub/Sub System Type**, select **GCP Cloud Pub/Sub**.
  * For **Subscription Name**, select your GCP Cloud Pub/Sub Spinnaker subscription.
  * Under **Attribute Constraints**, add an entry with the key `eventType` and value `OBJECT_FINALIZE ` (see the [Google Cloud Storage documentation](https://cloud.google.com/storage/docs/pubsub-notifications)).

  {% include figure
     image_path="./add-a-trigger.png"
  %}

b. In the **Artifact Constraints** dropdown, select "Define a new artifact..." to bring up the **Expected Artifact** form. Provide the artifact information:

  * For **Display Name**, enter your own artifact display name or keep the auto-generated default.
  * In the **Account** dropdown, select your GCS account.
  * In the **Object path** field, enter the path to the artifact.

  {% include figure
     image_path="./expected-artifact.png"
  %}

c. Click **Save Artifact**.

d. Add a Deploy stage to the pipeline. Create a new server group and provide details on deployment settings, the application artifact, and the manifest artifact:

  {% include figure
     image_path="./server-group.png"
  %}

## 6. Upload the Application and Manifest Artifacts

a. Upload the application manifest and application archive to your GCS bucket. With the pipeline trigger for your GCP Cloud Pub/Sub subscription, the pipeline will run when you upload the application archive to the bucket. The below example uses the `gsutil cp` command:

  ```
  $ gsutil cp application.jar $BUCKET
  ```

b. The GCS bucket upload will trigger a pipeline execution, and you should see the pipeline deploy a new server group for the application.
