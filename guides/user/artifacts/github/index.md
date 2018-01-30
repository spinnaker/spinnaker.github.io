---
layout: single
title:  "Receiving artifacts from GitHub"
sidebar:
  nav: guides
---

{% include toc %}

This guide explains how to configure Spinnaker to trigger pipelines based on
commits to a [GitHub repostory](https://github.com) and inject changed GitHub
files as [artifacts](/reference/artifacts) into a pipeline.

This functionality uses GitHub
[Webhooks](https://developer.github.com/webhooks/) for delivering messages to
Spinnaker, and must be configured to send messages to Spinnaker's event bus as
shown below.

# Prerequisite Configuration/Setup

If you (or your Spinnaker admin) have already configured Spinnaker to listen to
a GitHub webhooks from the repository you plan to publish commits to, you can
skip this section.

You need the following:

* A GitHub repository either under your user, or in an organization or user's
  account that you have permission to publish commits to.

  This will be referred to as `$ORGANIZATION/$REPOSITORY` from now on (e.g.
  `spinnaker/clouddriver`).

* [A running Spinnaker instance](/setup/install). This guide shows you how to
  update it to accept messages from GitHub.

At this point, we will configure GitHub webhooks, and a GitHub artifact
account. The intent is that the webhook will be received by Spinnaker whenever
a commit is made, and the artifact account will allow you to download any
pertinent files.

## 1. Configure GitHub Webhooks

Follow the [GitHub webhook configuration](/setup/triggers/github/).

## 2. Configure a GitHub Artifact Account

Follow the [GitHub artifact configuration](/setup/artifacts/github/).

## 3. Apply Your Configuration Changes

Once the artifact changes have been made using Halyard, run

```bash
hal deploy apply
```

to apply them in Spinnaker.

# Using GitHub Artifacts in Pipelines

We will need either an existing or a new pipeline that we want to be triggered
on changes to GCS artifacts. If you do not have a pipeline, create one as shown
below.

{%
  include
  figure
  image_path="./create-pipeline.png"
  caption="You can create and edit pipelines in the __Pipelines__ tab of
  Spinnaker"
%}

## Configure the GitHub artifact

Once you have your pipeline ready, we need to declare that this pipeline
expects to have a specific artifact matching some criteria available before
the pipeline starts executing. In doing so, you guarantee that an artifact
matching your description is present in the pipeline's execution context. If no
artifact for this description is present, the pipeline won't start.

{%
  include
  figure
  image_path="./add-artifact.png"
%}

Now to configure the artifact, change the "Custom" dropdown to "GitHub", and
enter the __File path__ field. Note: this path can be a regex. You can, for
example, set the object path to be `folder/.*\.yml` to trigger on any change to
a YAML file inside `folder` in your repository.

{%
  include
  figure
  image_path="./set-expected-artifact.png"
%}

## Configure the GitHub Trigger

Now that the expected artifact has been added, let's add a Git trigger to
run our pipeline. To configure the trigger:

| Field | Value |
|-------|-------|
| __Type__ | "Git" | 
| __Repo Type__ | "GitHub" |
| __Organization or User__  | `$ORGANIZATION` from above |
| __Project__ | `$REPOSITORY` from above |
| __Branch__ | (optional) Can be used (via regex) to describe which branches to listen to changes one |
| __Secret__ | (optional) _Strongly encouraged_ It must match the secret provided to the [webhook configuration](/setup/triggers/github/#configuring-your-github-webhook) |
| __Expected Artifacts__ | Must reference the artifact defined previously |

{%
  include
  figure
  image_path="./git-config.png"
  caption="By setting the __Expected Artifacts__ field in the trigger config,
  you guarantee that git webhooks will only trigger this pipeline
  when an artifact matching your requirements is present in the commit."
%}

## Test the pipeline

If you add or modify a file matching your expected artifact to the configured
repository, it should execute. If it doesn't, you can start by checking the
logs of the __Echo__ service.


