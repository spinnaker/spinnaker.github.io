---
layout: single
title:  "S3 Object"
sidebar:
  nav: reference
---

{% include toc %}

[Amazon S3](https://aws.amazon.com/s3/) is an object store, and S3 object
artifacts are references to objects stored in S3 buckets. These artifacts are
generally consumed by stages that read configuration from text files, such as a
Deploy Manifest or AWS Deploy stage.

## S3 object artifact in the UI

The pipeline UI exposes the following fields for the S3 object artifact:

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
      <td>An S3 artifact account.</td>
    </tr>
    <tr>
      <td><strong>Object path</strong></td>
      <td>The full path to the artifact file, beginning with <code>s3://</code>.</td>
    </tr>
  </tbody>
</table>

### In a trigger

When configuring a trigger, you can use an S3 object as an expected artifact.

{%
  include
  figure
  image_path="./expected-artifact-s3-object.png"
  caption="Configuring S3 object fields in a pipeline trigger's expected
           artifact settings."
%}

### In a pipeline stage

When configuring a "Deploy (Manifest)" or "Deploy" stage, you can use an S3
object as a manifest or application artifact.

{%
  include
  figure
  image_path="./deploy-manifest-stage-s3-object.png"
  caption="Configuring a Deploy (Manifest) stage to use an S3 object as a
           manifest source."
%}

## S3 object artifact in a pipeline definition

The following are the fields that make up an S3 object artifact:

| Field | Explanation |
|-|-----------|
| `type` | Always `s3/object`. |
| `name` | The full path to the artifact file, beginning with `s3://`. |
| `reference` | The full path to the artifact file, beginning with `s3://`. |
| `location` | The region of the bucket containing the object. |

The following is an example JSON representation of an S3 object artifact, as it
would appear in a pipeline definition:

```json
{
  "type": "s3/object",
  "name": "s3://bucket/file.json",
  "reference": "s3://bucket/file.json",
  "location": "us-east-1"
}
```
