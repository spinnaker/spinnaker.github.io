---
layout: single
title:  "Users Guide"
sidebar:
  nav: guides
redirect_from:
  - /guides/user/plugin-users/
---

{% include alpha version="1.20.6" %}

{% include toc %}

In this guide, you add an existing plugin from an [example repository](https://github.com/spinnaker-plugin-examples/examplePluginRepository) to Spinnaker. See the [Plugin Creators Guide](/guides/developer/plugin-creators/overview/) for how to create a plugin.

## Requirements

* The plugin is either a [Plugin Framework for Java](https://github.com/pf4j/pf4j)(PF4J) plugin or a Spring plugin
* The plugin resides in a location that Spinnaker can access
* You use Spinnaker v1.20.6 or later
* You use Halyard v1.36 or later to deploy Spinnaker

## Plugins overview

Spinnaker uses [PF4J-Update v2.3.0](https://github.com/pf4j/pf4j-update) to load and manage third-party plugins. Spinnaker supports local, remote, and file system repositories.

Each plugin repository is defined in a `repositories.json` file. Spinnaker must have access to a repository's location. A repository contains a list of one or more plugins defined in a `plugins.json` file. Spinnaker reads the `repositories.json` file and then loads enabled plugins from the corresponding `plugins.json` file.

See the PF4J-Update [README](https://github.com/pf4j/pf4j-update/tree/release-2.3.0) for a full explanation of the `repositories.json` and `plugins.json` structures.

## Define plugins

Define plugins in a file called `plugins.json`. The basic format is shown below.

```json
[
 {
   "id": "<unique-plugin-id>",
   "description": "<description>",
   "provider": "<provider>",
   "releases": [
	 {
	   "version": "<version>",
	   "date": "<date>",
	   "requires": "<comma-delimited-list-of-spinnaker-services>",
	   "sha512sum": "<checksum>",
	   "state": "<state>",
	   "url": "<complete-url-to-bundle-zip-file>"
	 }
   ]
 }
]
```

An example [plugins.json](https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/plugins.json) from the `spinnaker-plugin-examples` repository:

```json
[
  {
    "id": "Armory.RandomWaitPlugin",
    "description": "An example of a PF4J-based plugin that provides a new stage.",
    "provider": "https://github.com/spinnaker-plugin-examples",
    "releases": [
      {
          "version": "1.0.17",
          "date": "2020-03-25T16:07:51.524Z",
          "requires": "orca>=0.0.0,deck>=0.0.0",
          "sha512sum": "17f23cc00a3f931c66b6fe90f69fca3a8221687900163ff54e942be1b05c405bf7250a5be2a9265f7f204ec4f4fcb2afedaebd7c903f2f3c7127c1c6902fdc93",
          "state": "RELEASE",
          "url": "https://github.com/spinnaker-plugin-examples/pf4jStagePlugin/releases/download/v1.0.17/pf4jStagePlugin-v1.0.17.zip"
        },
      {
        "version": "1.0.16",
        "date": "2020-02-26T18:42:44.793Z",
        "requires": "orca>=0.0.0,deck>=0.0.0",
        "sha512sum": "0a218278c8f9083f54117983e64ae508c5f21ddfc4dc5e5a6b757d73d61f216407cfa92a42d63ebd01ef80937373c973acc103ef5c758333511f66ec239c9943",
        "state": "RELEASE",
        "url": "https://github.com/spinnaker-plugin-examples/pf4jStagePlugin/releases/download/v1.0.16/pf4jStagePlugin-v1.0.17.zip"
      }
    ]
  }  
]
```


## Define a plugin repository

Define a plugin repository in a file called `repositories.json`. A repository exposes the plugins in the corresponding `plugins.json` file to Spinnaker. The basic format is shown below.

```json
[
  {
    "id": "<unique-repo-name>",
    "url": "<url-of-plugins.json-file>"
  }
]
```

An example [repositories.json](https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/repositories.json) from the `spinnaker-plugin-examples` repository:

```json
[
  {
    "id": "examplePluginsRepo",
    "url": "https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/plugins.json"
  }
]
```


## Configure Spinnaker for the plugin repository

Use `hal plugins repository add REPOSITORY [parameters]` to add the repository file to Spinnaker's configuration:

```
hal plugins repository add spinnaker-plugin-examples \
    --url=https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/repositories.json
```

See the command [reference](/reference/halyard/commands/#hal-plugins-repository) for a complete list of parameters.

## Deploy Spinnaker

Use `hal deploy apply` to redeploy Spinnaker with the updated configuration.

## Additional plugin repository commands

### List configured plugin repositories

```
hal plugins repository list
```

### Edit a plugin repository

You can update a repository's URL using `hal`. For example:

```
hal plugins repository edit spinnaker-plugin-examples \
    --url=https://github.com/aimeeu/examplePluginRepository/blob/master/plugins.json
```

### Delete a plugin repository

You can use `hal` to delete a plugin repository. For example:  

```
hal plugins repository delete spinnaker-plugin-examples
```

## Install the plugin

After you add your plugin repository, you must configure Spinnaker to use your plugin.

This guide uses the [pf4jStagePlugin](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin) plugin as an example.

### Configure Spinnaker for the plugin

Use `hal` to enable your plugin so that Spinnaker will load it. Do not use `hal plugins enable`, which enables all plugins.

```
hal plugins add Armory.RandomWaitPlugin \
	--enabled=true \
	--extensions=armory.randomWaitStage \
    --version=<version>             
```

See the command [reference](/reference/halyard/commands/#hal-plugins-add) for the complete list of parameters.

### Configure the plugin

Manually edit the `.hal/config` file to configure custom values for your plugin.
Find the `plugins` section, locate your plugin's definition, and then change values in the `config` section.

The `RandomWaitPlugin` has a configurable `defaultMaxWaitTime` field that takes number of seconds.

```yaml
spinnaker:
  extensibility:
    plugins:
      Armory.RandomWaitPlugin:
        enabled: true
        extensions:
          armory.randomWaitStage:
            enabled: true
            config:
              defaultMaxWaitTime: 60
```


### Deploy Spinnaker

Use `hal deploy apply` to redeploy Spinnaker with the updated configuration.

## Additional plugin commands

### List configured plugins

```
hal plugins list
```

### Delete a plugin

You can use `hal plugins delete PLUGIN` to delete a plugin.

```
hal plugins delete Armory.RandomWaitPlugin
hal deploy apply
```

## Resources

You can ask for help with plugins in the [Spinnaker Slack's](https://join.spinnaker.io/) `#plugins` channel.
