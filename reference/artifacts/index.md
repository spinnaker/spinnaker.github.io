---
layout: single
title:  "About Spinnaker Artifacts"
sidebar:
  nav: reference
---

{% include toc %}

In Spinnaker, an artifact is an object that references an external resource. That resource could be… 

* a Docker image
* a file stored in GitHub
* an Amazon Machine Image (AMI)
* a binary blob in S3, GCS, etc.

Any of these can be fetched using a [URI](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier), and can be
used within a Spinnaker pipeline.

However, a URI alone isn't always enough. Take the following examples:

* You have a “Bake Image” stage that defines which packages are to be consumed, 
  which images are deployed into each environment, and which configuration files are mounted. 
  If each of these artifact types is just a URI, you have to write (and maintain) RegEx (or similar) 
  against URIs to match artifacts to stages.

* Your build system produces provenance information about your Docker images 
  (for example, which commit triggered the build, which build steps were used). 
  This isn’t easy to store in or retrieve from the Docker image, but you want to trigger the 
  pipeline on the arrival of a new image. If all you capture is the URI 
  (for example, `gcr.io/your-project/your-image:v1.0.0`) you lose that provenance information.

* Your Spinnaker instance is used by many teams in your organization,
  and your authorization policies isolate teams'
  infrastructure and pipelines from each other. You probably want your
  packages, configs, and images published and accessible only by the teams that need
  them. You need a way to annotate a URI with an account that can fetch
  it based on a user's permissions.

To address situations like these, Spinnaker includes a format for supplying
URIs alongside pertinent metadata. We call this "artifact decoration".

# Decorate your Artifacts

In Spinnaker, artifacts must match a specification. This specification is
consistent among all artifacts, whether they're supplied to pipelines, accessed
within pipelines, or produced by pipelines.

> Every time we refer to an _Artifact_, we mean a JSON payload matching this
> specification, not the actual artifact contents. The key distinction is that
> the artifact is a reference or a pointer to a resource, not the resource
> itself.

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
