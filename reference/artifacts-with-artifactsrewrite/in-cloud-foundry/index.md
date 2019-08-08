---
layout: single
title: "Artifacts In Cloud Foundry"
sidebar:
  nav: reference
---

{% include toc %}

In Cloud Foundry, artifacts can used for both an app's manifest and for the deployment archive (e.g. a JAR file for a Java app). These both can be used in a Deploy stage.

## Artifacts referencing app manifest

To use an artifact to reference a manifest file (such as a manifest stored in a GitHub repository), choose "Artifact from execution context" in the Application section of the "Configure Deployment Cluster" screen, and configure the artifact details.

{%
  include
  figure
  image_path="./cf-manifest-artifact-github.png"
  caption="In a Deploy stage, choose a GitHub file artifact as the manifest source for a server group."
%}

## Artifacts referencing app archive

To use an artifact to reference an application archive (such as a JAR file from a Maven repository), choose "Artifact from execution context" in the Manifest section of the "Configure Deployment Cluster" screen, and configure the artifact details.
{%
  include
  figure
  image_path="./cf-application-artifact-maven.png"
  caption="In a Deploy stage, choose a Maven artifact as the application source for a server group."
%}
