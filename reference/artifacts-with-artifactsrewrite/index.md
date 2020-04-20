---
layout: single
title:  "What is a Spinnaker Artifact?"
sidebar:
  nav: reference
---

{% include toc %}

A Spinnaker artifact is a named JSON object that refers to an external resource.

Spinnaker supports a wide range of providers. An artifact can reference any of many different external resources, such as&#8230;

* a Docker image
* a file stored in GitHub
* an Amazon Machine Image (AMI)
* a binary blob in Amazon S3, Google Cloud Storage, etc.

Each of these could be fetched using a URI and used within a pipeline, but a URI alone can omit other important information about the resource. You may wish to also fetch provenance information such as the commit that triggered the resource's build, or to store information about the account that has permission to download the resource.

To incorporate metadata such as this along with the resource's URI, Spinnaker artifacts follow a particular specification that includes the human-readable name of the artifact, its URI, and any other applicable metadata. This is called "artifact decoration". Every Spinnaker artifact--whether supplied to a pipeline, accessed within a pipeline, or produced by a pipeline--follows this specification.

Keep in mind that the artifact in Spinnaker is a _reference_ to an external resource--it is not the resource itself. The resource itself could be of any type supported by Spinnaker; the artifact is the named JSON object that contains information about the resource.

## Enabling artifact support

If using a version of Spinnaker prior to 1.20, enable support for the standard artifacts UI:

```bash
hal config features edit --artifacts-rewrite true
```

If using Spinnaker 1.20 or later, support for the standard artifacts UI is enabled by default.

## The artifact format

As an example, an object stored in Google Cloud Storage (GCS) might be accessed using the following Spinnaker artifact:

```js
{
  "type": "gcs/object",
  "reference": "gs://bucket/file.json#135028134000",
  "name": "gs://bucket/file.json",
  "version": "135028134000"
  "location": "us-central1"
}
```

As another example, a Docker image might be accessed using the following artifact:

```js
{
  "type": "docker/image",
  "reference": "gcr.io/project/image@sha256:29fee8e284",
  "name": "gcr.io/project/image",
  "version": "sha256:29fee8e284"
}
```

The fields that make up a Spinnaker artifact are described below.

<table>
  <thead>
    <tr>
      <th style="width:12%">Field</th>
      <th style="width:69%">Explanation</th>
      <th style="width:19%">Notes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>type</code></td>
      <td>How the external resource is classified. (This allows for easy distinction between Docker images and Debian packages, for example).</td>
      <td></td>
    </tr>
    <tr>
      <td><code>reference</code></td>
      <td>The URI used to fetch the resource.</td>
      <td></td>
    </tr>
    <tr>
      <td><code>artifactAccount</code></td>
      <td>The Spinnaker artifact account that has permission to fetch the resource.</td>
      <td></td>
    </tr>
    <tr>
      <td><code>version</code></td>
      <td>The version of the resource. (By convention, <code>version</code> should only be compared between artifacts of the same <code>type</code> and <code>name</code>.)</td>
      <td>Optional.</td>
    </tr>
    <tr>
      <td><code>provenance</code></td>
      <td>The relevant URI from the system that produced the resource. (This is used for deep-linking into other systems from Spinnaker.)</td>
      <td>Optional.</td>
    </tr>
    <tr>
      <td><code>metadata</code></td>
      <td>Arbitrary key / value metadata pertaining to the resource. (This can be useful for scripting within pipeline stages.)</td>
      <td>Optional.</td>
    </tr>
    <tr>
      <td><code>location</code></td>
      <td>The region, zone, or namespace of the resource. (This does not add information to the URI, but makes multi-regional deployments easier to configure.)</td>
      <td>Optional.</td>
    </tr>
    <tr>
      <td><code>uuid</code></td>
      <td>Used for tracing the artifact within Spinnaker.</td>
      <td>Assigned by Spinnaker.</td>
    </tr>
  </tbody>
</table>

## Expected artifacts

Within a pipeline trigger or stage, you can declare that the trigger or stage expects a particular artifact to be available. This artifact is called an _expected artifact_. Spinnaker compares an incoming artifact (for example, a manifest file stored in GitHub) to the expected artifact (for example, a manifest with the file path `path/to/my/manifest.yml`); if the incoming artifact matches the specified expected artifact, the incoming artifact is _bound_ to that expected artifact and used by the trigger or stage.

{%
  include
  figure
  image_path="./expected-artifact-github-file.png"
  caption="Configuring GitHub file fields in a pipeline trigger's Expected
           Artifact settings. The default Display Name value is
           auto-generated."
%}

### Match artifact

When declaring an expected artifact for a trigger, you can use fields under **Match Artifact** to specify metadata against which to compare the incoming artifact. This is how you can distinguish between similar artifacts coming from the same artifact account (for example, multiple manifest files stored in a single Git repository) and specify that the trigger should begin pipeline execution only if the incoming artifact matches the parameters that you provided.

### Prior execution and default artifact

In the fields under **If Missing**, you can provide fallback behavior for the expected artifact in case the trigger doesn't find the desired artifact. If you enable the **Use prior execution** checkbox, Spinnaker will fall back to the artifact used in the last execution. If you enable the **Use default artifact** checkbox, Spinnaker will use a default artifact, which you can specify in the form (this allows you to provide fallback behavior for the first time a trigger is used, when there is no previous execution yet).
