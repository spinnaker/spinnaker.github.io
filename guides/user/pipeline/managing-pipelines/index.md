---
layout: single
title:  "Managing Pipelines"
sidebar:
  nav: guides
---

{% include toc %}

Pipelines are the essential tool in Spinnaker for configuring how to deploy your
application. They are composed of a series of stages that can be combined in
almost any order, which makes them flexible, consistent, and repeatable.

You can configure your pipelines to run entirely automatically or require manual
intervention to ensure that everything is working as expected. Similarly,
pipelines can either be automatically triggered by a wide range of external
inputs, including other pipelines, or be manually triggered.

This guide explains how to configure and control pipelines, including creating,
adding triggers to, or disabling pipelines.

## Create a pipeline
1. Navigate to the **Pipelines** tab in your Spinnaker application.
  ![](images/pipelines-tab.png)
2. Click **Create**, located in the upper right corner of the Pipelines tab.
  ![](images/create.png)
3. Choose **Pipeline** from the drop down menu and name your pipeline.

After you create your pipeline, add stages to specify the actions that your
pipeline will perform.

### Add a stage

1. Select **Add stage** from your pipeline configuration screen.
  ![](images/add-stage.png)
2. Set the stage type using the drop-down menu.
3. If this is not the first stage in your pipeline, make sure that this stage
depends on the desired upstream stage(s) using the **Depends on** field.
  ![](images/stage-depends-on.png)

You can add as many stages as your pipeline needs, in any order that makes sense
for you.

### Add a trigger

Make sure that you are editing the **Configuration** stage of your pipeline.

![](images/configuration-stage.png)

1. Select **Add trigger**.
  ![](images/add-trigger.png)
2. Choose your desired trigger type from the drop-down menu that appears, and
input any further required configuration.

For further information on how triggers work, see the documentation on pipeline
triggers.
<!-- TODO(nhayes): link here to pipeline triggers overview once it exists. -->

## Disable a pipeline

Disabling a pipeline prevents any triggers from firing, as well as preventing
users from running it manually.

1. From the pipelines tab, click **Configure** to modify an existing pipeline.
  ![](images/select-configure.png)
2. Click **Pipeline actions** in the upper right corner, and select **Disable**.
  ![](images/pipeline-actions.png)

In order to re-enable your disabled pipeline, select **Pipeline actions** and
choose **Enable**.

## Delete a pipeline

1. From the pipelines tab, click **Configure** to modify an existing pipeline.
  ![](images/select-configure.png)
2. Click **Pipeline actions** in the upper right corner, and select **Delete**.
  ![](images/pipeline-actions.png)

## Edit as JSON

First, some background: Spinnaker represents pipelines as JSON behind the
scenes. Any changes you make to your pipeline using the UI are converted to JSON
when Spinnaker saves the pipeline.

When you use the **Edit as JSON** feature, you are directly editing the payload.
This can be useful for working around limitations of the UI. However, the JSON
you write here *is not validated* -- **Edit as JSON** essentially allows you to
modify the pipeline via a free-form textbox. Be careful! It is very easy to
break the pipeline.

In order to edit your pipeline as JSON:

1. From the pipelines tab, click **Configure** to modify an existing pipeline.
  ![](images/select-configure.png)
2. Click **Pipeline actions** in the upper right corner, and select
**Edit as JSON**.
  ![](images/pipeline-actions.png)

## View and restore revision history

Each time you save your pipeline, the current version is added to revision
history. You can use revision history to diff two versions of a pipeline or to
restore an older version of a pipeline.

> *Note*: If you are using minio or redis to store your Spinnaker configuration
files, you won't be able to use revision history because neither minio nor redis
supports it.

1. From the pipelines tab, click **Configure** to modify an existing pipeline.
  ![](images/select-configure.png)
2. Click **Pipeline actions** in the upper right corner, and select
**View revision history**.
  ![](images/pipeline-actions.png)

This pulls up a window that shows a JSON representation of your current
pipeline. From there, you can see all previously saved versions via the
drop-down menu in the upper left corner.

### Restore a previous version

1. Choose a version from the **Revision** drop-down.
  ![](images/revision-history.png)
2. A button appears that allows you to restore your pipeline to that version. If
you restore an older version, the current version of your pipeline is saved in
your revision history in case you want to return to it in the future.
  ![](images/restore-revision.png)

### Diff two versions of a pipeline

You can compare any version of your pipeline to either the version before it or
the current pipeline.

1. View revision history.
2. Select a version from the **Revision** drop-down.
  ![](images/revision-history.png)
3. Choose whether to compare that version to the current or previous version.
  ![](images/compare-version.png)
