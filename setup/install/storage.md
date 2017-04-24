---
layout: single
title:  "Storage"
sidebar:
  nav: setup
---

{% include toc %}

Spinnaker relies on having an external Persistent Storage source to store
Spinnaker-specific metadata, such as your [Pipelines](/concepts/#pipeline), or 
configured [Applications](/concepts/#applications). Before you can deploy
Spinnaker, you must configure it to use one of the supported storage types.

## Supported Storage Types

* <a href="/setup/storage/abs" target="_blank">Azure Blob Storage</a>
* <a href="/setup/storage/gcs" target="_blank">Google Cloud Storage</a>
* <a href="/setup/storage/s3" target="_blank">S3</a>

## Next Steps

Now we're ready to [deploy Spinnaker](/setup/install/deploy).
