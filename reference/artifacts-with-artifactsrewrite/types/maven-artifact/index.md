---
layout: single
title:  "Maven Artifact"
sidebar:
  nav: reference
---

{% include toc %}

[Maven](https://maven.apache.org) is a build automation tool, and a Spinnaker Maven artifact is a reference to a Maven artifact stored in a Maven repository. These artifacts are generally consumed by stages that deploy application artifacts, such as a Deploy stage.

> The files stored in a Maven repository are typically called "artifacts", so on this page, "Maven artifact" may refer to a Spinnaker artifact of type `maven/file` or to a file (e.g. a JAR file) stored in a Maven repository.

## Maven artifact in the UI

The pipeline UI exposes the following fields for the Maven artifact:

| Field                | Explanation                                                                                       |
|----------------------|---------------------------------------------------------------------------------------------------|
| **Account**          | A Maven artifact account.                                                                         |
| **Maven Coordinate** | The Maven coordinates for the artifact (in the standard Maven form `groupId:artifactId:version`). |

### In a trigger

When configuring certain triggers (such as an Artifactory trigger), you can use a Maven artifact as an expected artifact.

{%
  include
  figure
  image_path="./expected-artifact-maven-artifact.png"
  caption="Configuring Maven artifact fields in a pipeline trigger's expected
           artifact settings."
%}

### In a pipeline stage

When configuring a Deploy stage, you can use a Maven artifact as an application
artifact. You can either use a previously-defined artifact (for example, an
artifact defined in a trigger) or define an artifact inline.

{%
  include
  figure
  image_path="./deploy-stage-maven-artifact.png"
  caption="Configuring a Deploy stage to use a Maven artifact as an
           application artifact."
%}

## Maven artifact in a pipeline definition

The following are the fields that make up a Maven artifact:

| Field | Explanation |
|-|-----------|
| `type` | Always `maven/file`. |
| `reference` | The Maven coordinates for the Maven artifact, in the standard Maven form `groupId:artifactId:version`. |

The following is an example JSON representation of a Maven artifact, as it
would appear in a pipeline definition:

```json
{
	"reference": "io.pivotal.spinnaker:multifoundationmetrics:.*",
	"type": "maven/file"
}
```
