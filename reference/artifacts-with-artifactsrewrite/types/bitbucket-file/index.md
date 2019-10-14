---
layout: single
title:  "Bitbucket File"
sidebar:
  nav: reference
---

{% include toc %}

A Bitbucket file artifact is a reference to a file stored in
[Bitbucket](https://bitbucket.org). These artifacts are generally consumed by
stages that read configuration from text files, such as a Deploy Manifest
stage.

## Bitbucket file artifact in the UI

The pipeline UI exposes the following fields for the Bitbucket file artifact:

<table>
  <thead>
    <tr>
      <th width="10%">Field</th>
      <th width="90%">Explanation</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Account</strong></td>
      <td>A Bitbucket artifact account.</td>
    </tr>
    <tr>
      <td><strong>File path</strong></td>
      <td>The full path (including filename) for retrieval via the Bitbucket API. Example: <code>https://api.bitbucket.org/1.0/repositories/$ORG/$REPO/raw/$VERSION/$FILEPATH</code>.</td>
    </tr>
  </tbody>
</table>

### In a trigger

When configuring certain triggers, you can use a Bitbucket file as an expected
artifact.

{%
  include
  figure
  image_path="./expected-artifact-bitbucket-file.png"
  caption="Configuring Bitbucket file fields in a pipeline trigger's expected
           artifact settings."
%}

### In a pipeline stage

When configuring a "Deploy (Manifest)" or "Deploy" stage, you can use a
Bitbucket file as a manifest or application artifact. You can either use a
previously-defined artifact (for example, an artifact defined in a trigger) or
define an artifact inline.

## Bitbucket file artifact in a pipeline definition

The following are the fields that make up a Bitbucket file artifact:

| Field | Explanation |
|-|-----------|
| `type` | Always `bitbucket/file`. |
| `reference` | The full path (including filename) for retrieval via the Bitbucket API. Example: `https://api.bitbucket.org/1.0/repositories/$ORG/$REPO/raw/$VERSION/$FILEPATH`. |
| `name` | The path to the file within your repository. Example: `path/to/file.yml`. |
| `version` | N/A--must be specified in `reference`. |
| `location` | N/A. |

The following is an example JSON representation of a Bitbucket file artifact,
as it would appear in a pipeline definition:

```json
{
  "type": "bitbucket/file",
  "reference": "https://api.bitbucket.org/1.0/repositories/org/repo/raw/master/manifests/config.yaml",
  "name": "manifests/config.yaml"
}
```
