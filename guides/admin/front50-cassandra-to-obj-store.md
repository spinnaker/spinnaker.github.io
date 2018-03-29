---
layout: single
title:  "Front50: Cassandra to Object Store (S3, Azure, or GCS)"
sidebar:
  nav: guides
redirect_from: /docs/front50-cassandra-to-object-store
---

{% include toc %}

Cassandra is no longer an actively maintained or supported persistence store. 

A migration to S3, GCS, or AZS is **recommended**.

## 1. Create a bucket and folder

Make up a bucket name (or account name if using Azure) that is consistent with the naming policies for the underlying storage service. For purposes of this document, we'll pick ${USER}-spinnaker since many storage services (including Amazon S3, Google GCS, and Azure AZS) require globally unique names.

Make up a folder name within the bucket. The default is "front50". Spinnaker will store all the objects within this folder. The folder name will be used for configuration and managed by Spinnaker. You do not need to physically create the folder.

Note that currently only Amazon Simple Storage Service (S3), Google Cloud Storage (GCS), or Azure Storage (AZS) are supported, and they are mutually exclusive. Pick only one. This is independent of where you are actually running Spinnaker.

### A. Create the bucket in S3

If you wish to use S3 as the storage service, create the bucket and underlying root folder.

See [Amazon's Documentation](http://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html) for more information. 

To enable versioning on an existing bucket, follow [these](http://docs.aws.amazon.com/AmazonS3/latest/UG/enable-bucket-versioning.html) steps.

### B. Create the bucket in GCS

If you wish to use GCS as the storage service, Spinnaker can automatically create the bucket (with versioning) for you if it has the right OAuth scopes (Storage Admin). To create it yourself you are best off using the [gsutil tool](https://cloud.google.com/storage/docs/gsutil). Using `gsutil`, also [turn on versioning](https://cloud.google.com/storage/docs/object-versioning) within the bucket.

```
gsutil mb ${USER}-spinnaker
gsutil versioning set on ${USER}-spinnaker
```

### C. Create the storage account in AZS

If you wish to use Azure Storage, Spinnaker can automatically create the container and root folder (with versioning). Follow instructions [here](https://docs.microsoft.com/azure/storage/storage-create-storage-account#create-a-storage-account) to create a storage account and make sure to note the storage account name and a key.

## 2. Disable Cassandra in spinnaker-local.yml

```
services:
  front50:
    cassandra:
      enabled: false
```

## 3. Enable the object store in spinnaker-local.yml

### A. Enable S3

If you wish to use S3 as the storage service, set the following:

```
services:
  front50:
    storage_bucket: YOUR_S3_BUCKET_NAME (From Step #1)
    bucket_root: YOUR_S3_FOLDER_NAME (From Step #1)
    s3:
      enabled: true
```

### B. Enable GCS

If you wish to use GCS as the storage service, set the following YAML properties.
The default project name is the `${providers.google.primaryCredentials.project}` from `spinnaker-local.yml`. It is needed only if the bucket does not exist and Spinnaker is going to create the bucket for you. The `jsonPath` is used to convey the credentials to use in order to access GCS. The default is `${providers.google.primaryCredentials.jsonPath}` from `spinnaker-local.yml` however if you created the bucket in a different project (e.g. in the project that is running Spinnaker as opposed to the project that Spinnaker may be managing) then you may need to supply different credentials.

For more information about credentials and obtaining a JSON credentials file, see the [discussion on Service Accounts](https://support.google.com/cloud/answer/6158849?hl=en) 

```
services:
  front50:
    storage_bucket: YOUR_GCS_BUCKET_NAME (From Step #1)
    bucket_root: YOUR_GCS_FOLDER_NAME (From Step #1)
    gcs:
      enabled: true
      project: SEE NOTE
      jsonPath: SEE NOTE
```

### C. Enable AZS

If you wish to use Azure Storage, set the following:

```
services:
  front50:
    azs:
      enabled: true
      storageAccountName: YOUR_STORAGE_ACCOUNT_NAME (From Step #1)
      storageAccountKey: YOUR_STORAGE_ACCOUNT_KEY (From Step #1)
      storageContainerName: front50
```

## 4. Export existing applications, pipelines, strategies, notifications and projects

Replace "FRONT50_HOSTNAME" and "FRONT50_PORT" and run the following ("localhost" and "8080" are the defaults):

```
#!/bin/sh

rm applications.json
curl http://FRONT50_HOSTNAME:FRONT50_PORT/v2/applications | json_pp > applications.json

rm pipelines.json
curl http://FRONT50_HOSTNAME:FRONT50_PORT/pipelines | json_pp > pipelines.json

rm strategies.json
curl http://FRONT50_HOSTNAME:FRONT50_PORT/strategies | json_pp > strategies.json

rm notifications.json
curl http://FRONT50_HOSTNAME:FRONT50_PORT/notifications | json_pp > notifications.json

rm projects.json
curl http://FRONT50_HOSTNAME:FRONT50_PORT/v2/projects | json_pp > projects.json
```

## 5. Deploy new Front50

Run `sudo restart front50`

## 6. Import Applications, Pipelines, Strategies, Notifications and Projects

Replace "FRONT50_HOSTNAME" and "FRONT50_PORT" and run the following ("localhost" and "8080" are the defaults):

```
#!/bin/sh

curl -X POST -H "Content-type: application/json" --data-binary @"notifications.json" http://FRONT50_HOSTNAME:FRONT50_PORT/notifications/batchUpdate
curl -X POST -H "Content-type: application/json" --data-binary @"strategies.json" http://FRONT50_HOSTNAME:FRONT50_PORT/strategies/batchUpdate
curl -X POST -H "Content-type: application/json" --data-binary @"pipelines.json" http://FRONT50_HOSTNAME:FRONT50_PORT/pipelines/batchUpdate
curl -X POST -H "Content-type: application/json" --data-binary @"applications.json" http://FRONT50_HOSTNAME:FRONT50_PORT/v2/applications/batch/applications
curl -X POST -H "Content-type: application/json" --data-binary @"projects.json" http://FRONT50_HOSTNAME:FRONT50_PORT/v2/projects/batchUpdate
```
