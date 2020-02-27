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

## Requirements

* The plugin is either a PF4J or a Spring plugin
* The plugin resides in a publicly accessible place
* Spinnaker v1.19 or later
* Halyard v1.32.0 or later
* You redeploy Spinnaker using Halyard to apply changes

### Define Plugins

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


### Define a Plugin Repository

Define plugin repositories in a file called `repositories.json`. This guide uses the [file](https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/repositories.json) in the example repository.

Each repository exposes the plugins in the corresponding `plugins.json` file.

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

### Add the Plugin Repository

Use `hal` to add the repository file:

```
hal plugins repository add spinnaker-plugin-examples \
    --url=https://github.com/spinnaker-plugin-examples/examplePluginRepository/blob/master/repositories.json
```

See the Halyard [commands](/reference/halyard/commands/) reference for a complete list of parameters.

### List Configured Plugin Repositories

View configured repositories:

```
hal plugins repository list
```

### Edit a Plugin Repository

You can update a repository's URL using `hal`. For example:

```
hal plugins repository edit spinnaker-plugin-examples \
    --url=https://github.com/aimeeu/examplePluginRepository/blob/master/plugins.json
```


### Delete a Plugin Repository

You can use `hal` to delete a plugin repository. For example:  

```
hal plugins repository delete spinnaker-plugin-examples
```



# Installing Plugins

This guide uses the [pf4jStagePlugin](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin) plugin as an example.

## Adding a Plugin

To add a plugin to Spinnaker, you can run the following command:  

```
hal plugins add Armory.RandomWaitPlugin --enabled=true \
    --extensions=armory.randomWaitStage \
    --ui-resource-location=<url> \
    --version=<version>              // TODO do we support versions?
```

### UI Resource Location
Use `--ui-resource-location=<url>` to configure the frontend portion of the plugin. If there is no UI component to the plugin, this can be left out. The `url` should be accessable by anyone using the Spinnaker UI. It also has to allow for [cross origin](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) requests.

**Applying Changes**
Anytime things due to a Halyard change, the command `hal deploy apply` needs to be ran to apply the configuration to Spinnaker. Plugins are no different. After modifying any plugin, remember to run `hal deploy apply` for the changes to be passed to Spinnaker.

## Modifying a Plugin
To modify an existing plugin, we recommend using the `hal plugins edit` [command](https://www.spinnaker.io/reference/halyard/commands/#hal-plugins-edit). Add the plugin name that needs to be modified to the command. The command allows you to modify parameters like the ui-resource-location.

For example, the following command disables the plugin from the previous section
```
hal plugins edit Armory.RandomWaitPlugin --enabled=false
```

Remember to run `hal deploy apply` after modifying a plugin.

#### Configuring a plugin
While you can edit a plugin with the edit command, in order to configure a plugin, you must do so by hand.
When adding a plugin, halyard adds the `config` field, update this field to configure the plugin.

For example, after adding the plugin from the previous section, we can update it with a custom `defaultMaxWaitTime` :
```
spinnaker:
  extensibility:
    plugins:
      Armory.RandomWaitPlugin:
        enabled: true
        extensions:
          armory.randomWaitStage:
            enabled: true
            config:
              defaultMaxWaitTime: 60       // TODO we should probably set a default value for this
```

## Deleting a Plugin

To delete a plugin, run the `hal plugins delete plugin-name` command.

For example, the following command disables the plugin from the earlier section
```
hal plugins delete Armory.RandomWaitPlugin
```

Remember to run `hal deploy apply` after deleting a plugin.

## Display All Configured Plugins

Run `hal plugins list` to see which plugins are currently configured for Spinnaker.
