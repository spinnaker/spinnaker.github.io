---
layout: single
title:  "GitLab File"
sidebar:
  nav: reference
---

{% include toc %}

GitLab file artifacts are references to files stored in
[GitLab](https://gitlab.com). They are generally consumed by stages that read
configuration from text files, such as a Deploy Manifest stage.

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
      <td><strong>Content URL</strong></td>
      <td>The GitLab API content URL for the artifact file.</td>
    </tr>
    <tr>
      <td><strong>Commit/Branch</strong></td>
      <td>The commit hash or branch name to use when retrieving the artifact file from GitHub.</td>
    </tr>
  </tbody>
</table>

### In a Trigger

When configuring a Git trigger with __Type__ "GitLab", you can use a GitLab file
as an expected artifact.

{%
  include
  figure
  image_path="./expected-artifact-github-file.png"
  caption="Configuring GitLab file fields in a pipeline trigger's expected
           artifact settings."
%}

### In a Pipeline Stage

When configuring certain stages, such as a "Deploy (Manifest)" or "Deploy"
stage, you can use a GitLab file as a manifest or application artifact.

{%
  include
  figure
  image_path="./deploy-manifest-stage-github-file.png"
  caption="Configuring a Deploy (Manifest) stage to use a GitLab file as a
           manifest source."
%}

## GitLab File Artifact in a Pipeline Definition

The following are the fields that make up a GitLab file artifact:

| Field | Explanation |
|-|-----------|
| `type` | Always `github/file`. |
| `reference` |  The full path (including filename) for retrieval via the GitHub API. This is the `contents_url` referenced by a [PushEvent](https://developer.github.com/v3/activity/events/types/#pushevent). <br /><br />GitHub example: `https://api.github.com/repos/myorg/myrepo/contents/path/to/file.yml`. <br />GHE example: `https://github.mydomain.com/api/v3/repos/myorg/myrepo/contents/path/to/file.yml`. |
| `name` | The path to the artifact file, beginning at the root of the Git repository. Example: `path/to/file.yml`. |
| `version` | The commit hash, branch name, or tag to use when retrieving the artifact file from GitHub. |
| `location` | N/A |

The following is an example JSON representation of a GitLab file artifact, as it
would appear in a pipeline definition:

```json
{
  "type": "github/file",
  "reference": "https://api.github.com/repos/myorg/myrepo/contents/path/to/file.yml",
  "name": "path/to/file.yml",
  "version": "aec855f4e0e11"
}
```
## Fields

| Field | Explanation |
|-|-----------|
| `type` | Always `gitlab/file`. |
| `reference` |  The full path including filename for retrieval via the GitLab API. `https://gitlab.example.com/api/v4/projects/13083/repository/files/manifests%2Fconfig%2Eyaml/raw` is an example from the GitLab documentation. For more info, see the documentation [here](https://docs.gitlab.com/ee/api/repository_files.html#get-raw-file-from-repository).
| `name` | The file path within your repo. `path/to/file.yml` is an example. |
| `version` | The file's commit or branch. |
| `location` | N/A |

## Example

```json
{
  "type": "gitlab/file",
  "reference": "https://gitlab.example.com/api/v4/projects/13083/repository/files/manifests%2Fconfig%2Eyaml/raw",
  "name": "manifests/config.yaml",
  "version": "master"
}
```
