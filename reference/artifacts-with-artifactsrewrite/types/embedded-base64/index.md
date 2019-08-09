---
layout: single
title:  "Embedded Base64"
sidebar:
  nav: reference
---

{% include toc %}

Rather than refer to a resource by a URI, you can embed the artifact's contents
directly into the `"reference"` field in Base64.

## Embedded Base64 artifact in the UI

The pipeline UI exposes the following fields for the embedded Base64 artifact:

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
      <td>Always "embedded-artifact".</td>
    </tr>
    <tr>
      <td><strong>Name</strong></td>
      <td>A human-readable identifier for the artifact.</td>
    </tr>
    <tr>
      <td><strong>Contents</strong></td>
      <td>The Base64-encoded contents of the artifact.</td>
    </tr>
  </tbody>
</table>

### In a trigger

When configuring a trigger, you can (for example) configure an embedded Base64
default artifact.

{%
  include
  figure
  image_path="./default-artifact-embedded-base64.png"
  caption="Providing an embedded Base64 default artifact for a trigger's
           expected artifact."
%}

### In a pipeline stage

When configuring certain stages, such as a "Deploy (Manifest)" stage, you can
use embedded Base64 for a required artifact. You can either use a
previously-defined artifact (for example, an artifact defined in a trigger) or
define an artifact inline.

{%
  include
  figure
  image_path="./deploy-manifest-stage-embedded-base64.png"
  caption="Configuring a Deploy (Manifest) stage to use an embedded Base64
           artifact."
%}

## Embedded Base64 artifact in a pipeline definition

The following are the fields that make up an embedded Base64 artifact:

| Field | Explanation |
|-|-----------|
| `type` | Always `embedded/base64`. |
| `reference` | The Base64-encoded artifact contents. |
| `name` | An optional human-readable identifier. |

The following is an example JSON representation of an embedded Base64 artifact, as it
would appear in a pipeline definition:

```json
{
  "type": "embedded/base64",
  "reference": "dmFsdWU6IDEKbXlrZXk6IG15dmFsdWU=",
  "name": "my-properties-file",
}
```
