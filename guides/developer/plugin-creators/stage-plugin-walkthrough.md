---
layout: single
title: "Pipeline Stage Plugin Walkthrough"
sidebar:
  nav: guides
---

{% include alpha version="1.19.4" %}


{% include toc %}


# Prerequisites

* You have read the [Plugin Creators Guide Overview](/guides/developer/plugin-creators/overview/).
* [Gradle](https://gradle.org/) and [Yarn](https://classic.yarnpkg.com/en/) for building the plugin locally
* Orca branch `release-1.19.x` and IntelliJ IDEA for local testing
* Spinnaker v1.19.4 and Halyard 1.34 for deploying the plugin

# pf4jStagePlugin plugin

The [pf4jStagePlugin](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin) creates a custom pipeline stage that waits a specified number of seconds before signaling success. The plugin consists of a `random-weight-orca` [Kotlin](https://kotlinlang.org/docs/reference/) server component and a `random-wait-deck` [React](https://reactjs.org/) UI component.

This plugin is for demo purposes only. You can use this plugin as a starting point to create a custom pipeline stage.

## random-weight-orca

This component implements the [SimpleStage](https://github.com/spinnaker/orca/blob/ab89a0d7f847205ccd62e70f8a714040a8621ee7/orca-api/src/main/java/com/netflix/spinnaker/orca/api/SimpleStage.java) PF4J extension point in Orca and  consists of five classes in the `io.armory.plugin.state.wait.random` package:

* `Context.kt`: a data class that stores the `maxWaitTime` value; `SimpleStage` uses `Context`
* `Output.kt`: a data class that stores the `timeToWait` getValue; this data is returned to the extension point implementation and can be used in later stages
* `RandomWeightConfig.kt`: a data class with the `@ExtensionConfiguration` tag; key-value pairs in this class map to the plugin's configuration
* `RandomWeightInput.kt`: a data class that contains the key-values pairs that we care about from the Context map
* `RandomWaitPlugin.kt`: this is the plugin's main class; implements `SimpleStage`

See the code comments for detailed explanations.

## random-weight-deck

* `rollup.config.js`:  ??
* `plugins.json`: defines dependencies
* `RandomWaitStage.tsx`: defines the custom pipeline stage; renders UI output
* `RandomWaitStageIndex.ts`: exports the name and custom stages; ?? assuming Deck consumes this somehow??


See the code comments for detailed explanations.

# Debugging random-wait-orca in Orca

@TODO

install correct version of jdk

clone orca branch release-1.19.x

import into IntelliJ

build plugin, copy `.plugin-ref` copy steps from pf4jStagePlugin README (add screenshots?)




# Plugin configuration files

list the places where values must match between code and configuration files
