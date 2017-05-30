---
layout: single
title:  "Overview"
sidebar:
  nav: setup
---

Spinnaker requires an external storage source for persisting your Application
settings and configured Pipelines. Since these data are sensitive and can be
costly to lose, we recommend using a hosted storage source you are confident
in.

You have a few different options, enumerated below. Keep in mind
whichever option you chose does not preclude any choice of [Cloud
Provider](/setup/providers/), i.e. there is no problem with using
[Google Cloud Storage](https://cloud.google.com/storage/) as a storage source
when deploying to [Microsoft Azure](https://azure.microsoft.com/).

## Supported Storage Sources

These are the storage sources currently supported by Spinnaker:

* [Azure Storage](/setup/storage/azs)
* [Google Cloud Storage](/setup/storage/gcs)
* [Redis](/setup/storage/redis)
* [S3](/setup/storage/s3)
