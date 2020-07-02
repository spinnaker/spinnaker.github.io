---
layout: single
title:  "Users Guide"
sidebar:
  nav: guides
redirect_from:
  - /guides/user/plugin-users/
---

{% include alpha version="1.20.6" %}

_Note: Spinnaker 1.19.x does not support frontend plugins due to a bug in Deck._

{% include toc %}

## Overview

Spinnaker uses [PF4J-Update](https://github.com/pf4j/pf4j-update) to load and manage third-party plugins. These plugins can implement a PF4J extension point or be Spring components. See the [Plugin Creators Guide](/guides/developer/plugin-creators/overview/) for details.

## Terms

**plugins.json**

* required file
* defines one to many plugins in a plugin repository
* each plugin definition has an id, description, provider, and a collection of releases (version, date, requires, sha512sum, state, url)
* the plugin developer provides access to this file

**repositories.json**

* optional file
* defines one to many plugin repositories
* each repository definition consists of a unique identifier and the path to a `plugins.json` file
* the plugin developer may supply this file

## Plugin requirements

* The plugin is either a [Plugin Framework for Java](https://github.com/pf4j/pf4j)(PF4J) plugin or a Spring plugin
* The plugin repository is a web location that Spinnaker can access, like a GitHub repository

Spinnaker environment:

* Spinnaker v1.20.6 or later
* Halyard v1.36 or later to deploy Spinnaker


## How to add a plugin to Spinnaker

1. Add a plugin repository using Halyard
1. Add a plugin using Halyard
1. Add a `deck-proxy` to `gate-local.yml` (frontend plugins only)
1. Redeploy Spinnaker

## Add a plugin repository using Halyard

When you configure a repository, you tell Spinnaker where to find the `plugins.json` file that defines the plugins you want to use.  Each plugin repository entry in Spinnaker consists of a unique name and a URL.

If you want a repository to point to a single `plugins.json` file, you add it like this:

```bash
hal plugins repository add <unique-repo-name> --url=<path-to-plugins.json-file>
```

For example:

```
hal plugins repository add spinnaker-plugin-examples \
    --url=https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/plugins.json
```

This action creates an entry in your Halconfig:

```yaml
repositories:
  spinnaker-plugin-examples:
    id: spinnaker-plugin-examples
    url: https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/plugins.json
```

If you want a single plugin repository entry to point to multiple `plugins.json` files, you need to create a `repositories.json` file that defines a collection of plugin repositories. The file format is:

```json
[
  {
    "id": "<unique-repo-name>",
    "url": "<url-of-plugins.json-file>"
  }
]
```

For example:

```json
[
  {
    "id": "spinnaker-plugin-examples",
    "url": "https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/plugins.json"
 },
 {
     "id": "my-company-internal-plugins",
     "url": "https://<my-company-internal-github>/<repo-name>/plugins.json"
 },
 {
	  "id": "my-plugins",
	  "url": "https://github.com/aimeeu/pluginRepository/blob/master/plugins.json"
 }
]
```

Save your `repositories.json` file in a web location that Spinnaker can access. Then you can add a new plugin repository using the `repositories.json` file:

```
hal plugins repository add all-the-plugins \
    --url=https://raw.githubusercontent.com/aimeeu/all-the-plugins/master/repositories.json
```

You can also list, edit, and delete repositories. See the command [reference](/reference/halyard/commands/#hal-plugins-repository) for a complete list of parameters.

Don't forget to `hal deploy apply` to apply your configuration changes.

## Add a plugin using Halyard

After you have added your plugin repository, you can add your plugin to Spinnaker. You need information from plugin's definition in the `plugins.json` file to do this.

For example, let's add a plugin called RandomWaitPlugin, which is in the `spinnaker-plugin-examples` GitHub repository. That plugin's entry in `plugins.json` look like this:

```json
[
 {
   "id": "Armory.RandomWaitPlugin",
   "description": "An example of a PF4J-based plugin that provides a custom pipeline stage.",
   "provider": "https://github.com/spinnaker-plugin-examples",
   "releases": [
     {
       "version": "1.1.14",
       "date": "2020-07-01T18:03:00.200Z",
       "requires": "orca>=0.0.0,deck>=0.0.0",
       "sha512sum": "f19deb40c2f386f1334a4ec6bf41bbb58296e489c37abcb80c93a5e423f2fb3522b45e8f9e5c7a188017c125b90bb0aea323e80f281fa1619a0ce769617e020e",
       "state": "",
       "url": "https://github.com/spinnaker-plugin-examples/pf4jStagePlugin/releases/download/v1.1.14/pf4jStagePlugin-v1.1.14.zip"
	 },
	 {
       "version": "1.0.15",
       "date": "2020-02-26T17:02:30.666Z",
       "requires": "orca>=0.0.0,deck>=0.0.0",
       "sha512sum": "58437ae45cdcf44182b4e26379c6363d66b924445c81904f5dbf64441ba94e1b36d3b23557ecc3c6ff96dc5499f40cd1392f170bb3be3349a7c681ffaf26419d",
       "state": "RELEASE",
       "url": "https://github.com/spinnaker-plugin-examples/pf4jStagePlugin/releases/download/v1.0.15/pf4jStagePlugin-v1.0.15.zip"
        }
      ]
	}
]
```


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

## Deployment example

See the [pf4jStagePlugin Deployment Example](/guides/user/plugins/deploy-example/) page.


## Resources

You can ask for help with plugins in the [Spinnaker Slack's](https://join.spinnaker.io/) `#plugins` channel.
