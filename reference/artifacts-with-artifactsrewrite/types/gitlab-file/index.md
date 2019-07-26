---
layout: single
title:  "GitLab File"
sidebar:
  nav: reference
---

{% include toc %}

A GitLab file artifact is a reference to a file stored in
[GitLab](https://gitlab.com). These artifacts are generally consumed by stages
that read configuration from text files, such as a Deploy Manifest stage.

## GitLab File Artifact in the UI

The pipeline UI exposes the following fields for the GitLab file artifact:

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
      <td>A GitLab artifact account.</td>
    </tr>
    <tr>
      <td><strong>File path</strong></td>
      <td>The path to the artifact file, beginning at the root of the Git repository.</td>
    </tr>
    <tr>
      <td><strong>Commit/Branch</strong></td>
      <td>The commit hash or branch name to use when retrieving the artifact file from GitLab.</td>
    </tr>
  </tbody>
</table>

### In a Trigger

When configuring a Git trigger with __Type__ "GitLab", you can use a GitLab file
as an expected artifact.

{%
  include
  figure
  image_path="./expected-artifact-gitlab-file.png"
  caption="Configuring GitLab file fields in a pipeline trigger's expected
           artifact settings."
%}

### In a Pipeline Stage

When configuring certain stages, such as a "Deploy (Manifest)" or "Deploy"
stage, you can use a GitLab file as a manifest or application artifact.

## GitLab File Artifact in a Pipeline Definition

The following are the fields that make up a GitLab file artifact:

| Field | Explanation |
|-|-----------|
| `type` | Always `gitlab/file`. |
| `reference` |  The full path (including filename) for retrieval via the GitLab API. Example: `https://gitlab.example.com/api/v4/projects/13083/repository/files/manifests%2Fconfig%2Eyaml/raw`. For more information, see the [GitLab API documentation](https://docs.gitlab.com/ee/api/repository_files.html#get-raw-file-from-repository). |
| `name` | The path to the artifact file, beginning at the root of the Git repository. Example: `path/to/file.yml`. |
| `version` | The commit hash or branch name to use when retrieving the artifact file from GitLab. |
| `location` | N/A |

The following is an example JSON representation of a GitLab file artifact, as it
would appear in a pipeline definition:

```json
{
  "type": "gitlab/file",
  "reference": "https://gitlab.example.com/api/v4/projects/13083/repository/files/manifests%2Fconfig%2Eyaml/raw",
  "name": "manifests/config.yaml",
  "version": "master"
}
```
