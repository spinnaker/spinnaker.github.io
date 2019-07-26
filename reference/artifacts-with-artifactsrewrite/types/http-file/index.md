---
layout: single
title:  "HTTP File"
sidebar:
  nav: reference
---

{% include toc %}

An HTTP file artifact is a reference to a file stored in plaintext and
reachable via HTTP. These artifacts are generally consumed by stages that read
configuration from text files, such as a Deploy Manifest stage. 

A file represented by an HTTP file artifact can be downloaded using HTTP Basic
authentication.

## HTTP File Artifact in the UI

The pipeline UI exposes the following fields for the HTTP file artifact:

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
      <td>An HTTP artifact account.</td>
    </tr>
    <tr>
      <td><strong>URL</strong></td>
      <td>The fully-qualified URL from which the file can be read.</td>
    </tr>
  </tbody>
</table>

### In a Trigger

When configuring certain triggers, you can use an HTTP file as an expected
artifact.

{%
  include
  figure
  image_path="./expected-artifact-http-file.png"
  caption="Configuring HTTP file fields in a pipeline trigger's expected
           artifact settings."
%}

### In a Pipeline Stage

When configuring a "Deploy (Manifest)" or "Deploy" stage, you can use an HTTP
file as a manifest or application artifact.

{%
  include
  figure
  image_path="./deploy-manifest-stage-http-file.png"
  caption="Configuring a Deploy (Manifest) stage to use an HTTP file as a
           manifest source."
%}

## HTTP File Artifact in a Pipeline Definition

The following are the fields that make up an HTTP file artifact:

| Field       | Explanation                                                        |
|-------------|--------------------------------------------------------------------|
| `type`      | Always `http/file`.                                                |
| `reference` | The fully-qualified URL from which the file can be read.           |
| `name`      | An optional identifier used for future references to the artifact. |
| `version`   | N/A                                                                |
| `location`  | N/A                                                                |

The following is an example JSON representation of an HTTP file artifact, as it
would appear in a pipeline definition:

```json
{
  "type": "http/file",
  "reference": "https://raw.githubusercontent.com/....",
  "name": "My manifest stored in GitHub",
}
```
