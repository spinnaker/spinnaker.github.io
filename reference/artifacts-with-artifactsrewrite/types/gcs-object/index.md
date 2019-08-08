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

## GCS object artifact in the UI

The pipeline UI exposes the following fields for the GCS object artifact:

<table>
  <thead>
    <tr>
      <th>Field</th>
      <th>Explanation</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Account</strong></td>
      <td>A GCS artifact account.</td>
    </tr>
    <tr>
      <td><strong>Object path</strong></td>
      <td>The path to the artifact file, beginning with <code>gs://</code>.</td>
    </tr>
  </tbody>
</table>

### In a trigger

When configuring certain triggers (such as a Pub/Sub trigger with __Pub/Sub
System Type__ "Google"), you can use a GCS object as an expected artifact.

{%
  include
  figure
  image_path="./expected-artifact-gcs-object.png"
  caption="Configuring GCS object fields in a pipeline trigger's expected
           artifact settings."
%}

### In a pipeline stage

When configuring a "Deploy (Manifest)" or "Deploy" stage, you can use a GCS
object as a manifest or application artifact.

{%
  include
  figure
  image_path="./deploy-manifest-stage-gcs-object.png"
  caption="Configuring a Deploy (Manifest) stage to use a GCS object as a
           manifest source."
%}

## GCS object artifact in a pipeline definition

The following are the fields that make up a GCS object artifact:

| Field | Explanation |
|-|-----------|
| `type` | Always `gcs/object`. |
| `reference` | The reference to the artifact file, beginning with `gs://` and optionally ending with the object's [version](https://cloud.google.com/storage/docs/gsutil/addlhelp/ObjectVersioningandConcurrencyControl). Example: `gs://bucket/file.yml#1360383693620000` |
| `name` | The same as `reference`, but never with a version. |
| `version` | The object's [version](https://cloud.google.com/storage/docs/gsutil/addlhelp/ObjectVersioningandConcurrencyControl), if applicable. |
| `location` | N/A |

The following is an example JSON representation of a GCS object artifact, as it
would appear in a pipeline definition:

```json
{
  "type": "gcs/object",
  "reference": "gs://bucket/file.yml#1360383693620000",
  "name": "gs://bucket/file.yml",
  "version": "1360383693620000"
}
```
