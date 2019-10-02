---
layout: single
title:  "Get Started Using Spinnaker"
sidebar:
  nav: guides
---

{% include toc %}

This is an early alpha feature that is under active development and will likely change

# Plugin Users Guide
This guide is for adding plugins to Spinnaker. This assumes that Spinnaker is already setup and configured. Currently this is only support in 1.16 version of Spinnaker or later. This also requires version 1.23.0 of Halyard or later.

Note that adding a plugin to Spinnaker requires redeploying Spinnaker with Halyard.

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
  deck:
  - https://stage-plugin-test.s3-us-west-2.amazonaws.com/stage-plugin-ui-0.0.1-SNAPSHOT.js
```
## Enabling Plugins

To enable plugins for Spinnaker run the following [command](https://www.spinnaker.io/reference/halyard/commands/#hal-plugins-enable)
`hal plugins enable`

This will enable plugins to be loaded if the individual plugin(s) are enabled.

## Adding A Plugin

To add a plugin to Spinnaker, the plugin manifest location needs to be known. Adding the plugin is as easy as:

```
hal plugins add plugin-name --enabled\
  --manifest-location="https://path/to/plugin/manifest.yml"
```
The `--enabled` is to automatically enable the plugin. Plugins by default are disabled, unless the `--enabled` flag is passed when adding the plugin.

**Applying Changes**
Anytime things via Halyard change, the command `hal deploy apply` needs to be ran to send the configuration off to Spinnaker. Plugins are no different. After modifying any plugin remember to run `hal deploy apply` for the changes to be passed to Spinnaker.

## Controlling Plugin Downloading

If Spinnaker is deployed to Kubernetes, Halyard has to enable Spinnaker to download the plugin resources. To do that, run the following command to enable plugin downloading:
`hal plugins enable-downloading` 

If Spinnaker is deployed to something else besides Kubernetes, plugin resources will have to be manually added to the correct locations.

## Modifying Plugins

To modify an existing plugin, the `hal plugins edit` [command](https://www.spinnaker.io/reference/halyard/commands/#hal-plugins-edit) is where we recommend to start. Add the plugin name that needs to be modified to the command and then the manifest location can be modified.

For example, to disable a plugin, run the following command
`hal plugins edit plugin-name` `--``disable` 

Remember to run `hal deploy apply` after running any modifications

## Deleting Plugins

To delete a plugin, run the `hal plugins delete plugin-name` command

Remember to run `hal deploy apply` after running any deletions

## Listing All Plugins Configured

Run `hal plugins list` to see what plugins are currently configured for Spinnaker
