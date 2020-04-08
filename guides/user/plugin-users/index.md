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

In this guide, you add an existing plugin from an [example repository](https://github.com/spinnaker-plugin-examples/examplePluginRepository) to Spinnaker. See the [Plugin Creators Guide](/guides/developer/plugin-creators/overview/) for how to create a plugin.

# Requirements

* The plugin is either a [Plugin Framework for Java](https://github.com/pf4j/pf4j)(PF4J) plugin or a Spring plugin
* The plugin resides in a location that Spinnaker can access
* You use Spinnaker v1.19 or later
* You use Halyard v1.32.0 or later to deploy Spinnaker

# Plugins overview

Spinnaker uses [PF4J-Update v2.3.0](https://github.com/pf4j/pf4j-update) to load and manage third-party plugins. Spinnaker supports local, remote, and file system repositories.

Each plugin repository is defined in a `repositories.json` file. Spinnaker must have access to a repository's location. A repository contains a list of one or more plugins defined in a `plugins.json` file. Spinnaker reads the `repositories.json` file and then loads enabled plugins from the corresponding `plugins.json` file.

See the PF4J-Update [README](https://github.com/pf4j/pf4j-update/tree/release-2.3.0) for a full explanation of the `repositories.json` and `plugins.json` structures.

# Define plugins

Define plugins in a file called `plugins.json`. This guide uses the [file](https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/plugins.json) in the example repository.

```json
[
 {
   "id": <unique-plugin-id>,
   "description": <description>,
   "provider": <provider>,
   "releases": [
	 {
	   "version": <version>,
	   "date": <date>,
	   "requires": <comma-delimited-list-of-spinnaker-services>,
	   "sha512sum": <checksum>,
	   "state": <state>,
	   "url": <complete-url-to-bundle-zip-file>
	 }
   ]
 }
]
```

```json
[
  {
    "id": "Armory.RandomWaitPlugin",
    "description": "An example of a PF4J-based plugin that provides a new stage.",
    "provider": "https://github.com/claymccoy",
    "releases": [
      {
        "version": "1.0.16",
        "date": "2020-02-26T18:42:44.793Z",
        "requires": "orca>=0.0.0,deck>=0.0.0",
        "sha512sum": "0a218278c8f9083f54117983e64ae508c5f21ddfc4dc5e5a6b757d73d61f216407cfa92a42d63ebd01ef80937373c973acc103ef5c758333511f66ec239c9943",
        "state": "RELEASE",
        "url": "https://github.com/spinnaker-plugin-examples/pf4jStagePlugin/releases/download/v1.0.16/pf4jStagePlugin-v1.0.16.zip"
      },
      {
        "version": "1.0.15",
        "date": "2020-02-26T17:02:30.666Z",
        "requires": "orca>=0.0.0,deck>=0.0.0",
        "sha512sum": "58437ae45cdcf44182b4e26379c6363d66b924445c81904f5dbf64441ba94e1b36d3b23557ecc3c6ff96dc5499f40cd1392f170bb3be3349a7c681ffaf26419d",
        "state": "RELEASE",
        "url": "https://github.com/spinnaker-plugin-examples/pf4jStagePlugin/releases/download/v1.0.15/pf4jStagePlugin-v1.0.15.zip"
      },
      {
        "version": "1.0.14",
        "date": "2020-02-26T04:24:32.070Z",
        "requires": "orca>=0.0.0,deck>=0.0.0",
        "sha512sum": "a6bd3b58e8747acb7c6cfa4d4f06db1c1d0e93b645288b1135607270d75245d0145ef36ca51d7d8d7d34b83e3fd012952400512df259a3ecd3175137d5de327b",
        "state": "RELEASE",
        "url": "https://github.com/spinnaker-plugin-examples/pf4jStagePlugin/releases/download/v1.0.14/pf4jStagePlugin-v1.0.14.zip"
      }
    ]
  }  
]
```


# Define a plugin repository

Define a plugin repository in a file called `repositories.json`. A repository exposes the plugins in the corresponding `plugins.json` file to Spinnaker.

This guide uses the [file](https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/repositories.json) in the example repository.

```json
[
  {
    "id": <unique-repo-name>,
    "url": <url-of-plugins.json-file>
  }
]
```

```json
[
  {
    "id": "examplePluginsRepo",
    "url": "https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/plugins.json"
  }
]
```


# Configure Spinnaker for the plugin repository

Use `hal plugins repository add REPOSITORY [parameters]` to add the repository file to Spinnaker's configuration:

```
hal plugins repository add spinnaker-plugin-examples \
    --url=https://github.com/spinnaker-plugin-examples/examplePluginRepository/blob/master/repositories.json
```

See the command [reference](/reference/halyard/commands/#hal-plugins-repository) for a complete list of parameters.

# Deploy Spinnaker

Use `hal deploy apply` to redeploy Spinnaker with the updated configuration.

# Additional plugin repository commands

## List configured plugin repositories

```
hal plugins repository list
```

## Edit a plugin repository

You can update a repository's URL using `hal`. For example:

```
hal plugins repository edit spinnaker-plugin-examples \
    --url=https://github.com/aimeeu/examplePluginRepository/blob/master/plugins.json
```

## Delete a plugin repository

You can use `hal` to delete a plugin repository. For example:  

```
hal plugins repository delete spinnaker-plugin-examples
```

# Install the plugin

After you add your plugin repository, you must configure Spinnaker to use your plugin.

This guide uses the [pf4jStagePlugin](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin) plugin as an example.

## Configure Spinnaker for the plugin

Use `hal` to enable your plugin so that Spinnaker will load it. Do not use `hal plugins enable`, which enables all plugins.

```
hal plugins add Armory.RandomWaitPlugin \
	--enabled=true \
	--extensions=armory.randomWaitStage \
    --ui-resource-location=<location-of-plugin-ui-resource> \
    --version=<version>             
```

Use `--ui-resource-location=<location-of-plugin-ui-resource>` to configure the frontend portion of the plugin. This parameter may be omitted when the plugin doesn't have a UI component. The `url` must be publicly accessible. It also has to allow for [cross origin](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) requests.

See the command [reference](/reference/halyard/commands/#hal-plugins-add) for the complete list of parameters.

## Configure the plugin

Manually edit the `.hal\config` file to configure custom values for your plugin.
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


## Deploy Spinnaker

Use `hal deploy apply` to redeploy Spinnaker with the updated configuration.

# Additional plugin commands

## List configured plugins

```
hal plugins list
```

## Edit a plugin

You can use `hal plugins edit PLUGIN [parameters]` to modify a plugin's `version`, `ui-resource-location`, and `enabled` parameters. For example, to disable an enabled plugin, change the `enabled` parameter to false and then redeploy Spinnaker.

```
hal plugins edit Armory.RandomWaitPlugin --enabled=false
hal deploy apply
```

See the command [reference](/reference/halyard/commands/#hal-plugins-edit) for the complete list of parameters.

## Delete a plugin

You can use `hal plugins delete PLUGIN` to delete a plugin.

```
hal plugins delete Armory.RandomWaitPlugin
hal deploy apply
```

# Resources

You can ask for help with plugins in the [Spinnaker Slack's](https://join.spinnaker.io/) `#plugins` channel.
