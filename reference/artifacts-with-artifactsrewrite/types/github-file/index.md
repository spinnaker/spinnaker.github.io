---
layout: single
title:  "GitHub File"
sidebar:
  nav: reference
---

{% include toc %}

A GitHub file artifact is a reference to a file stored in
[GitHub](https://github.com) or [GitHub
Enterprise](https://enterprise.github.com/home). These artifacts are generally
consumed by stages that read configuration from text files, such as a "Deploy
(Manifest)" stage.

## GitHub file artifact in the UI

The pipeline UI exposes the following fields for the GitHub file artifact:

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
      <td>A GitHub artifact account.</td>
    </tr>
    <tr>
      <td><strong>File path</strong></td>
      <td>The path to the artifact file, beginning at the root of the Git repository.</td>
    </tr>
    <tr>
      <td><strong>Content URL</strong></td>
      <td>The GitHub API content URL for the artifact file.</td>
    </tr>
    <tr>
      <td><strong>Commit/Branch</strong></td>
      <td>The commit hash or branch name to use when retrieving the artifact file from GitHub.</td>
    </tr>
  </tbody>
</table>

### In a trigger

When configuring a Git trigger with __Type__ "GitHub", you can use a GitHub file
as an expected artifact.

{%
  include
  figure
  image_path="./expected-artifact-github-file.png"
  caption="Configuring GitHub file fields in a pipeline trigger's expected
           artifact settings."
%}

### In a pipeline stage

When configuring certain stages, such as a "Deploy (Manifest)" or "Deploy"
stage, you can use a GitHub file as a manifest or application artifact.

{%
  include
  figure
  image_path="./deploy-manifest-stage-github-file.png"
  caption="Configuring a Deploy (Manifest) stage to use a GitHub file as a
           manifest source."
%}

## GitHub file artifact in a pipeline definition

The following are the fields that make up a GitHub file artifact:

| Field | Explanation |
|-|-----------|
| `type` | Always `github/file`. |
| `reference` |  The full path (including filename) for retrieval via the GitHub API. This is the `contents_url` referenced by a [PushEvent](https://developer.github.com/v3/activity/events/types/#pushevent). <br /><br />GitHub example: `https://api.github.com/repos/myorg/myrepo/contents/path/to/file.yml`. <br />GHE example: `https://github.mydomain.com/api/v3/repos/myorg/myrepo/contents/path/to/file.yml`. |
| `name` | The path to the artifact file, beginning at the root of the Git repository. Example: `path/to/file.yml`. |
| `version` | The commit hash, branch name, or tag to use when retrieving the artifact file from GitHub. |
| `location` | N/A |

The following is an example JSON representation of a GitHub file artifact, as it
would appear in a pipeline definition:

```json
{
  "type": "github/file",
  "reference": "https://api.github.com/repos/myorg/myrepo/contents/path/to/file.yml",
  "name": "path/to/file.yml",
  "version": "aec855f4e0e11"
}
```
