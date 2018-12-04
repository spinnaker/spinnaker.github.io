--
 Layout: single
 title:  "Deploy GCS Pub/Sub Artifacts to CF"
 sidebar:
   nav: guides
---

 {% include alpha version="1.10 and later" %}
 
 {% include toc %}
 
In this codelab, you will deploy an artifact to Cloud Foundry via a Spinnaker pipeline that is triggered by JAR uploads to a Google Cloud Storage (GCS) bucket.

## Prerequisites

This codelab assumes you have the following:

1. A billing-enabled Google Cloud Platform (GCP) project.
1. The `gcloud` CLI tool (installed locally on your computer).

## 1. Create a GCS Bucket for Artifact Storage

Log in with `gcloud`:

```
$ gcloud auth login
```

Run the `gsutil mb` command to create a bucket within your GCP project, giving your project’s ID (`PROJECT_ID` below) and the name of the bucket to create (`BUCKET`):

```
$ PROJECT_ID=<Insert Project ID>
$ BUCKET=<Insert Bucket Name>
$ gsutil mb -p $PROJECT_ID gs://$BUCKET
```

## 2. Enable Google Cloud Pub/Sub

Enable the GCP Cloud Pub/Sub API, then use `gsutil` to create a pub/sub notification, giving a topic name (`TOPIC`) and your GCS bucket name (`BUCKET`):

```
$ TOPIC=<Insert Topic Name>
$ gsutil notification create -t $TOPIC -f json $BUCKET
```

Now create a pull subscription, giving a subscription name (`GCP_SUB_NAME`) and the topic name used in the last command (`TOPIC`):

```
$ GCP_SUB_NAME=<Insert Subscription Name>
$ gcloud beta pubsub subscriptions create $GCP_SUB_NAME --topic $TOPIC
```

## 3. Create a GCP Service Account

Following the GCP documentation on Creating and Managing Service Accounts, create a new service account, giving it the Storage Admin (`roles/storage.admin`) and Pub/Sub Subscriber (`roles/pubsub.subscriber`) roles.

Create a key for the service account and download the key in JSON format to your computer. In this codelab, the path to the JSON key file will be referred to as `JSON_SA_KEY`:

```
$ JSON_SA_KEY=<Insert Path to Service Account Key JSON File>
```

## 4. Tell Spinnaker to Use the Pub/Sub Subscription

Enable artifact support, then enable the GCS artifact provider:

```
$ hal config features edit --artifacts true
$ hal config artifact gcs enable
```

Now add an artifact account for your GCS bucket, providing the path to the service account JSON key file and an account name (`ACCOUNT` below):

```
$ ACCOUNT=<Insert Account Name>
$ hal config artifact gcs account add --json-path $JSON_SA_KEY $ACCOUNT
```

Enable GCP Cloud Pub/Sub support:

```
$ hal config pubsub google enable
```

Finally, add the subscription you created in step 2, providing a subscription name (`SPIN_SUB_NAME`), your GCP project’s name (`PROJECT_NAME`), the GCP Cloud Pub/Sub subscription name (`GCP_SUB_NAME`), and the path to the service account JSON key file:

```
$ SPIN_SUB_NAME=<Insert Spinnaker Subscription Name>
$ PROJECT_NAME=<Insert GCP Project Name>
$ hal config pubsub google subscription add $SPIN_SUB_NAME \
--project $PROJECT_NAME \
--subscription-name $GCP_SUB_NAME \
--message-format GCS \
--json-path $JSON_SA_KEY
```

Apply your changes:

```
$ hal deploy apply
```

## 5. Configure the Application and Pipeline

Create a new pipeline for your application. In the pipeline configuration, configure the Expected Artifacts as shown below, a GCS object with the path to the application archive in your GCS bucket:

{% include figure
   image_path="./expected-artifacts.png"
%}

Configure Automated Triggers, adding the GCP Cloud Pub/Sub Spinnaker subscription as a trigger and selecting the Artifact Constraints:

{% include figure
   image_path="./triggers.png"
%}

Add a Deploy stage to the pipeline. Create a new server group and provide details on deployment settings, the application artifact, and the manifest artifact:

{% include figure
   image_path="./server-group-basic-settings.png"
%}

{% include figure
   image_path="./server-group-artifacts.png"
%}

## 6. Upload the Application and Manifest Artifacts

Upload the application archive and manifest to your GCS bucket. With the pipeline trigger for your GCP Cloud Pub/Sub subscription, the pipeline will run when you upload the application archive to the bucket. The below example uses the `gsutil cp` command:

```
$ gsutil cp application.jar $BUCKET
```

The GCS bucket upload will trigger a pipeline execution, and you should see the pipeline deploy a new server group for the application.
