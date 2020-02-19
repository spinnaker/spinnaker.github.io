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
* Your Spinnaker deployment must be version 1.19 or later
* You must use Halyard 1.32.0 or later
* You can redeploy Spinnaker with Halyard to apply changes

# Plugin Delivery
There are multiple ways of delivering plugins to a Spinnaker installation.
This doc describes using PF4J as a way to deliver plugins.

## PF4J Update
This is how to add plugins to a spinnaker installation via [PF4J - Update](https://github.com/pf4j/pf4j-update).
We will be using the [examplePluginRepository](https://github.com/spinnaker-plugin-examples/examplePluginRepository) plugin repository as an example.

### Add a Plugin Repository

To add a plugin repository to Spinnaker, you can run the following command:  
```
hal plugins repository add spinnaker-plugin-examples \
    --url=https://github.com/spinnaker-plugin-examples/examplePluginRepository/blob/master/repositories.json
```

### Edit a Plugin Repository
To update a plugin repository's url, you can run the following command:  
```
hal plugins repository add spinnaker-plugin-examples \
    --url=https://github.com/spinnaker-plugin-examples/examplePluginRepository/blob/master/plugins.json
```

Note that you can point to either a `plugin.json` or a `repositories.json` file, as described in [PF4J - Update](https://github.com/pf4j/pf4j-update)

### Delete a Plugin Repository
To delete a plugin repository, run the following command:  
```
hal plugins repository delete spinnaker-plugin-examples
```

### List Configured Plugin Repositories
To view the configured plugin repositories, run the following command:
```
hal plugins repository list
```

# Installing Plugins
Once you've configured your plugin repositories, you can then configure Spinnaker to use plugin(s) in the configured repositories.
We will be using the [pf4jStagePlugin](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin) plugin as an example.

## Adding a Plugin

To add a plugin to Spinnaker, you can run the following command:  
```
hal plugins add Armory.RandomWaitPlugin --enabled=true \
    --extensions=armory.randomWaitStage \
    --ui-resource-location=<url> \   // TODO should have this ready when we post these docs
    --version=<version>              // TODO do we support versions?
```

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

