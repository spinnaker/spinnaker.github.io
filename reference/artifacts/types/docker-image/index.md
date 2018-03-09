---
layout: single
title:  "Docker Image"
sidebar:
  nav: reference
---

{% include toc %}

A Docker image is a snapshot of a container, to be run locally, or in the
cloud. Docker image artifacts are used as references to images in
[registries](https://docs.docker.com/registry/), such as [GCR](https://gcr.io),
or [Docker Hub](https://index.docker.io). The artifacts can be deployed to
Kubernetes or App Engine, and generally trigger pipelines from notifications
sent by their registry.

## Fields

| Field | Explanation |
|-|-----------|
| `type` | Always `docker/image`. |
| `reference` | The fully-qualified image name, including version and registry. This can be done either by tag (`gcr.io/project/my-image:v1.2`) or image digest `gcr.io/project/my-image@sha256:28f82eba`. |
| `name` | The image's name (typically the registry and repository) without the image's version. `gcr.io/project/my-image` is an example. |
| `version` | The image's tag or digest. |
| `location` | N/A |

## Example

```json
{
  "type": "docker/image",
  "reference": "gcr.io/project/my-image@sha256:28f82eba",
  "name": "gcr.io/project/my-image",
  "version": "sha256:28f82eba"
}
```
