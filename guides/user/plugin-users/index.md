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

In this guide, you add an existing plugin from an [example repository](https://github.com/spinnaker-plugin-examples/examplePluginRepository) to Spinnaker. See the [Plugin Creators Guide](/guides/developer/plugin-creators) for how to create a PF4J or Spring plugin.

# Requirements

* The plugin is either a PF4J or a Spring plugin
* The plugin resides in a publicly accessible place
* Spinnaker v1.19 or later
* Halyard v1.32.0 or later
* You redeploy Spinnaker using Halyard to apply changes

# Define Plugins

Define plugins in a file called `plugins.json`. This guide uses the  [file](https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/plugins.json) in the example repository.

```json
[
	{
   "id": <plugin-id>,
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

1. **id**: defined by the plugin creator; find this value in the bundle's `MANIFEST.MF`; unique value
2. **description**: what the plugin does
3. **provider**: plugin provider name
4. **releases**: one-to-many list; each release entry requires:

	* **version**: plugin version (semantic version format, e.g. 1.2.3)
	* **date**: plugin release date in ISO or yyyy-MM-dd format
	* **requires**: list of comma-delimited Spinnaker services; ex: "orca>=0.0.0,deck>=0.0.0"
	* **sha512sum**: a string of the SHA-512 HEX value or the URL to the SHA-512 file
	* **state**: plugin state, usually "RELEASE"
	* **url**: either an absolute or relative URL to the bundle zip file


# Define the Plugin Repository

Define plugin repositories in a file called `repositories.json`. Each repository exposes the plugins in the corresponding `plugins.json` file to Spinnaker.

This guide uses the [file](https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/repositories.json) in the example repository.


```json
[
  {
    "id": <repo-name>,
    "url": <url-of-plugins.json-file>
  }
]
```

1. **id**: unique name
2. **url**: either an absolute or relative URL to the `plugins.json` file

# Configure Spinnaker for the Plugin Repository

Run `hal plugins repository add REPOSITORY [parameters]` to add the repository file to Spinnaker's configuration:

```
hal plugins repository add spinnaker-plugin-examples \
    --url=https://github.com/spinnaker-plugin-examples/examplePluginRepository/blob/master/repositories.json
```

See the command [reference](/reference/halyard/commands/#hal-plugins-repository) for a complete list of parameters.

# Deploy Spinnaker

Use `hal deploy apply` to redeploy Spinnaker with the updated configuration.

# Additional Plugin Repository Commands

## List Configured Plugin Repositories

View configured repositories:

```
hal plugins repository list
```

## Edit a Plugin Repository

You can update a repository's URL using `hal`. For example:

```
hal plugins repository edit spinnaker-plugin-examples \
    --url=https://github.com/aimeeu/examplePluginRepository/blob/master/plugins.json
```

## Delete a Plugin Repository

You can use `hal` to delete a plugin repository. For example:  

```
hal plugins repository delete spinnaker-plugin-examples
```

# Install the Plugin

After you add your plugin repository, you must configure Spinnaker to use your plugin.

This guide uses the [pf4jStagePlugin](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin) plugin as an example.

## Configure Spinnaker for the Plugin

Use `hal` to enable your plugin so Spinnaker will load it. Do not use `hal plugins enable`, which enables all plugins.

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

# Additional Plugin Commands

## List Configured Plugins

View configured plugins:

```
hal plugins list
```

## Edit a Plugin

You can use `hal plugins edit PLUGIN [parameters]` to modify a plugin's `version`, `ui-resource-location`, and `enabled` parameters. For example, to disable an enabled plugin, change the `enabled` parameter to false and then redeploy Spinnaker.

```
hal plugins edit Armory.RandomWaitPlugin --enabled=false
hal deploy apply
```

See the command [reference](/reference/halyard/commands/#hal-plugins-edit) for the complete list of parameters.

## Delete a Plugin

You can use `hal plugins delete PLUGIN` to delete a plugin.

```
hal plugins delete Armory.RandomWaitPlugin
hal deploy apply
```

# Resources

You can ask for help with plugins in the [Spinnaker Slack's](https://join.spinnaker.io/) `#plugins` channel.
