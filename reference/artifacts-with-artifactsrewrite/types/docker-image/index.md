---
layout: single
title:  "Docker Image"
sidebar:
  nav: reference
---

{% include toc %}

A Docker image is a snapshot of a container, to be run locally or in the
cloud. Docker image artifacts are used as references to images in
[registries](https://docs.docker.com/registry/), such as
[Google Container Registry](https://cloud.google.com/container-registry/)
or [Docker Hub](https://index.docker.io). The artifacts can be deployed to
Kubernetes or App Engine, and generally trigger pipelines from notifications
sent by their registry.

## Docker image artifact in the UI

The pipeline UI exposes the following fields for the Docker image artifact:

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
      <td>A Docker registry artifact account.</td>
    </tr>
    <tr>
      <td><strong>Docker image</strong></td>
      <td>The name of the Docker image, including the registry and image repository.</td>
    </tr>
  </tbody>
</table>

### In a trigger

When configuring the Docker Registry trigger, you can use a Docker image as an
expected artifact.

{%
  include
  figure
  image_path="./expected-artifact-docker-image.png"
  caption="Configuring Docker image fields in a pipeline trigger's expected
           artifact settings."
%}

### In a pipeline stage

When configuring certain stages, such as a  "Deploy (Manifest)" stage, you can
use a Docker image as a required artifact. You can either use a
previously-defined artifact (for example, an artifact defined in a trigger) or
define an artifact inline.

{%
  include
  figure
  image_path="./deploy-manifest-stage-docker-image.png"
  caption="Configuring a Deploy (Manifest) stage to use a Docker image as a
           required artifact."
%}

## Docker image artifact in a pipeline definition

The following are the fields that make up a Docker image artifact:

| Field | Explanation |
|-|-----------|
| `type` | Always `docker/image`. |
| `reference` | The fully-qualified image name, including the version and registry. This can be done by either tag (`gcr.io/project/my-image:v1.2`) or image digest `gcr.io/project/my-image@sha256:28f82eba`. |
| `name` | The image's name (typically the registry and repository) without the image's version. Example: `gcr.io/project/my-image` |
| `version` | The image's tag or digest. |
| `location` | N/A |

The following is an example JSON representation of a Docker image artifact, as it
would appear in a pipeline definition:

```json
{
  "type": "docker/image",
  "reference": "gcr.io/project/my-image@sha256:28f82eba",
  "name": "gcr.io/project/my-image",
  "version": "sha256:28f82eba"
}
```
