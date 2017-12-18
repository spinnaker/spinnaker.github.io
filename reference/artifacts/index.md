---
layout: single
title:  "Artifacts"
sidebar:
  nav: reference
---

{% include toc %}

In Spinnaker, artifacts represent a common abstraction for references to remote
data/resources. Examples include Docker images, files stored in GitHub, Amazon
Machine Images (AMIs), binary blobs in S3/GCS, etc... All of these can be
located and fetched using a
[URI](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier), and can be
used within a Spinnaker pipeline.

However, a URI alone isn't always enough. Take the following examples:

* We have a pipeline where we want to easily express which packages need to be
  consumed by a "Bake Image" stage, which images are to be deployed into each
  environment, and which configuration files are to be mounted. If each of
  these three types of artifacts is just a URI, we'll have to resort to writing
  and maintaining RegEx (or similar) against URIs to match artifacts to stages.

* Say our build system produces provenance information about our Docker images
  (which commit triggered the build, and which build steps were used). This
  isn't easy to store/retrieve from Docker image alone, but we want to trigger
  our pipeline on the arrival of a new Docker image. If all we capture is the
  URI (e.g. `gcr.io/your-project/your-image:v1.0.0`), we lose that provenance
  information.

* Perhaps your Spinnaker instance is used by many teams in your organization,
  and you have configured authorization policies to isolate teams'
  infrastructure and pipelines from one-another. Odds are, you'll want your
  packages/configs/images published and accessible only by the teams that need
  them. You'll need some way to annotate a URI with an account that can fetch
  it based on a user's permissions.

To address this, we have a format for decorating URIs with metadata
pertinent to Spinnaker.

# Artifact Decoration

In Spinnaker, artifacts must match a specification. This specification is
consistent between artifacts supplied to pipelines, artifacts accessed within
pipelines, and artifacts produced by pipelines.

## Format

```js
{
  "type":       // How this artifact is classified. Allows for easy distinction
                // between docker images and debian packages, for example.

  "reference":  // The URI.

  "artifactAccount": // The account configured within Spinnaker that has
                // permission to download this resource.

  "name":       // (Optional) A human-readable name that makes matching
                // artifacts simpler.

  "version":    // (Optional) The version of this artifact. By convention, the
                // "version" should be compared against other artifacts with
                // the same "type" and "name".

  "provenance": // (Optional) A link to whatever produced this artifact. This
                // is used for deep-linking into other systems from Spinnaker.

  "metadata":   // (Optional) Arbitrary k/v metadata useful for scripting
                // within stages.

  "location":   // (Optional) The region/zone/namespace this artifact can be
                // found in. This doesn't add information to the URI, but makes
                // multi-regional deployments easier to configure.

  "uuid":       // (Assigned by Spinnaker) Used for tracing artifacts within
                // Spinnaker.
}
```

## Examples

```js
// A docker image
{
  "type": "docker/image",
  "reference": "gcr.io/project/image@sha256:29fee8e284",
  "name": "gcr.io/project/image",
  "version": "sha256:29fee8e284"
}
```

```js
// A GCS object
{
  "type": "gcs/object",
  "reference": "gs://bucket/file.json#135028134000",
  "name": "gs://bucket/file.json",
  "version": "135028134000"
  "location": "us-central1"
}
```
