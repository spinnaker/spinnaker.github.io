---
layout: single
title:  "Plugin Users Guide"
sidebar:
  nav: guides
---

{% include toc %}

<div class="notice--danger">
  <strong>Note:</strong> Plugins are an early alpha feature that is under active development and will likely change.
</div>

This guide is for adding existing plugins to Spinnaker. For information about how to develop a new plugin, see [Plugin Creators Guide](/guides/developer/plugin-creators). 

## Requirements

To use plugins, ensure that the following requirements are met:
* Your Spinnaker deployment must be version 1.16 or later
* You must use Halyard 1.23.0 or later
* You can redeploy Spinnaker with Halyard to apply changes


## Plugin Manifests

Plugins come with a manifest file that specifies what is needed for the plugin to work. Here is an example of a possible manifest file for a plugin:

```
name: armory/s3copy
description: Copies S3 files to different locations
manifestVersion: plugins/v1
version: 1.2.3
options:
  s3:
    username: user
    password: pass
resources:
  orca:
  - https://stage-plugin-test.s3-us-west-2.amazonaws.com/stage-plugin-0.0.1-SNAPSHOT.jar
```
## Enabling Plugins

To enable plugins for Spinnaker, run the following [command](https://www.spinnaker.io/reference/halyard/commands/#hal-plugins-enable):
`hal plugins enable`

This will enable plugins to be loaded if the individual plugins are enabled.

## Adding A Plugin

To add a plugin to Spinnaker, the plugin manifest location needs to be known. Adding the plugin is as easy as running the following command:

```
hal plugins add plugin-name --enabled\
  --manifest-location="https://path/to/plugin/manifest.yml"
```
The `--enabled` is to automatically enable the plugin. Plugins by default are disabled unless the `--enabled` flag is passed when adding the plugin.

**Applying Changes**
Anytime things due to a Halyard change, the command `hal deploy apply` needs to be ran to apply the configuration to Spinnaker. Plugins are no different. After modifying any plugin, remember to run `hal deploy apply` for the changes to be passed to Spinnaker.

## Controlling Plugin Downloading

If Spinnaker is deployed to Kubernetes, Halyard has to enable Spinnaker to download the plugin resources. To do that, run the following command to enable plugin downloading:
`hal plugins enable-downloading` 

If Spinnaker is deployed to something else besides Kubernetes, plugin resources have to be manually added to the correct locations.

## Modifying Plugins

To modify an existing plugin, we recommend using the `hal plugins edit` [command](https://www.spinnaker.io/reference/halyard/commands/#hal-plugins-edit). Add the plugin name that needs to be modified to the command. The command allows you to modify parameters like the manifest location.

For example, the following command disables a plugin named `puppy-facts`:
`hal plugins edit puppy-facts` `--``disable` 

Remember to run `hal deploy apply` after modifying a plugin.

## Deleting Plugins

To delete a plugin, run the `hal plugins delete plugin-name` command.

For example, the following command deletes a plugin named `puppy-facts`:
`hal plugins delete puppy-facts`

Remember to run `hal deploy apply` after deleting a plugin.

## Listing All Plugins Configured

Run `hal plugins list` to see which plugins are currently configured for Spinnaker.
