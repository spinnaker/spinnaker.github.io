---
layout: single
title:  "About External Storage"
sidebar:
  nav: setup
redirect_from: /setup/install/storage.html
---

Spinnaker requires an external storage provider for persisting your Application
settings and configured Pipelines. Because these data are sensitive and can be
costly to lose, we recommend you use a hosted storage solution you are confident
in.

Spinnaker supports the storage providers listed below. Whichever option you chose does not affect your choice of [Cloud
Provider](/setup/providers/). That is, you can use
[Google Cloud Storage](https://cloud.google.com/storage/) as a storage source
but still deploy to [Microsoft Azure](https://azure.microsoft.com/).

## Supported Storage Solutions

* [Azure Storage](/setup/storage/azs)
* [Google Cloud Storage](/setup/storage/gcs)
* [Minio](/setup/storage/minio)
* [Redis](/setup/storage/redis)
* [S3](/setup/storage/s3)

## Next Steps

After you've set up your external storage service, you need to enable and [configure a cloud provider](/setup/providers/).