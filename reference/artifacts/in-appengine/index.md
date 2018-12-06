---
layout: single
title: "Artifacts In App Engine"
sidebar:
  nav: reference
---

{% include toc %}

Artifacts can be used for several things in the Google App Engine provider:

1. They can be used to reference a GCS bucket that contains source code to be deployed on Google App Engine.
2. They can be used to reference a docker image stored in Google Container Registry to be deployed on App Engine Flex.
3. They can be used to reference config files (such as app.yaml) to be used during deployment to App Engine.

## Artifacts Referencing Source Code From GCS

To use an artifact to reference source code that is stored in a GCS bucket, use the "GCS" Source Type
when configuring a Server Group.

In the image below, a GCS Artifact has been configured in the Create Server Group modal as the
source code to deploy to App Engine:

{%
  include
  figure
  image_path="./gcs_bucket_source_code_artifact.png"
%}

## Artifacts Referencing Docker Images From GCR

To use an artifact to reference docker images stored in Google Container Registry, set the Server
Group's Source Type to "Container Image" and set the "Resolve URL" field to "via pipeline artifact".

In the below image, a Docker Artifact has been configured in the Create Server Group modal as the
container image URL to use for deployment to App Engine Flex:

{%
  include
  figure
  image_path="./container_image_artifact.png"
%}

## Artifacts Referencing Config Files

To use an artifact to reference config files used during deployment to App Engine, click the
"Add Config Artifact" button in the Create Server Group modal.

In the below image a GCS Artifact has been added to the Config Files section of the Create Server Group modal:

{%
  include
  figure
  image_path="./config_file_artifact.png"
%}
