---
layout: single
title:  "GCS Object"
sidebar:
  nav: reference
---

{% include toc %}

[GCS](https://cloud.google.com/storage/) is an object store, and GCS object
artifacts are references to objects stored in GCS buckets. These artifacts are
generally consumed by stages that read configuration from text files, such as a
Deploy Manifest or App Engine Deploy stage.

## Fields

| Field | Explanation |
|-|-----------|
| `type` | Always `gcs/object`. |
| `reference` | The `gs://`-prefixed reference to your file. May be suffixed with the object's [version](https://cloud.google.com/storage/docs/gsutil/addlhelp/ObjectVersioningandConcurrencyControl). `gs://bucket/file.yml#1360383693620000` is an example. |
| `name` | The same as `reference`, but never with a version. |
| `version` | The object's [version](https://cloud.google.com/storage/docs/gsutil/addlhelp/ObjectVersioningandConcurrencyControl), if applicable. |
| `location` | N/A |

## Example

```json
{
  "type": "gcs/object",
  "reference": "gs://bucket/file.yml#1360383693620000",
  "name": "gs://bucket/file.yml",
  "version": "1360383693620000"
}
```
