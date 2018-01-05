---
layout: single
title:  "Storage"
sidebar:
  nav: setup
---

Spinnaker relies on having an external Persistent Storage source to store
Spinnaker-specific metadata, such as your [Pipelines](/concepts/#pipeline), or 
configured [Applications](/concepts/#applications). Before you can deploy
Spinnaker, you must configure it to use one of the supported storage types.

## Supported Storage Types

* <a href="/setup/storage/azs">Azure Storage</a>
* <a href="/setup/storage/gcs">Google Cloud Storage</a>
* <a href="/setup/storage/redis">Redis</a>
* <a href="/setup/storage/s3">S3</a>

## Next Steps

Now that the core components of Spinnaker have been configured, but before 
Spinnaker becomes useful you need to enable and [Configure a Cloud
Provider](/setup/providers/).

