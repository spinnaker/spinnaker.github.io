---
layout: single
title: "Pipeline Stage Plugin Walkthrough"
sidebar:
  nav: guides
---

{% include alpha version="1.19.4" %}
> This guide is a work in progress. Help us improve the content by submitting a pull request!

{% include toc %}


# Requirements

* You have read the [Plugin Creators Guide Overview](/guides/developer/plugin-creators/overview/).
* [Gradle](https://gradle.org/) and [Yarn](https://classic.yarnpkg.com/en/) for building the plugin locally
* IntelliJ IDEA, Orca branch `release-1.19.x` and Deck branch  for local testing
* Spinnaker v1.19.4 and Halyard 1.34 for deploying the pf4jStagePlugin 1.0.16

# pf4jStagePlugin plugin

The [pf4jStagePlugin](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin) creates a custom pipeline stage that waits a number of seconds before signaling success. The plugin consists of a `random-wait-orca` [Kotlin](https://kotlinlang.org/docs/reference/) server component and a `random-wait-deck` [React](https://reactjs.org/) UI component.

This is a very simplistic plugin for educational purposes only. You can use this plugin as a starting point to create a custom pipeline stage.

## `random-wait-orca`

This component implements the [SimpleStage](https://github.com/spinnaker/orca/blob/ab89a0d7f847205ccd62e70f8a714040a8621ee7/orca-api/src/main/java/com/netflix/spinnaker/orca/api/SimpleStage.java) PF4J extension point in Orca and  consists of five classes in the `io.armory.plugin.state.wait.random` package:

* `Context.kt`: a data class that stores the `maxWaitTime` value; `SimpleStage` uses `Context`
* `Output.kt`: a data class that stores the `timeToWait` getValue; this data is returned to the extension point implementation and can be used in later stages
* `RandomWaitConfig.kt`: a data class with the `@ExtensionConfiguration` tag; key-value pairs in this class map to the plugin's configuration
* `RandomWaitInput.kt`: a data class that contains the key-values pairs that we care about from the Context map
* `RandomWaitPlugin.kt`: this is the plugin's main class; implements `SimpleStage`

Watch a [video walkthrough](https://youtu.be/b7BmMY1kR10) and read [code comments](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin/tree/master/random-wait-orca/src/main/kotlin/io/armory/plugin/stage/wait/random) for more information.

## `random-wait-deck`

This component uses the [`rollup.js`](https://rollupjs.org/guide/en/#plugins-overview) plugin library to create a UI widget for Deck.

* `rollup.config.js`: configuration for building the JavaScript application
* `package.json`: defines dependencies
* `RandomWaitStage.tsx`: defines the custom pipeline stage; renders UI output
* `RandomWaitStageIndex.ts`: exports the name and custom stages

Watch a [video walkthrough](https://youtu.be/u9NVlG58NYo) and read [code comments](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin/tree/master/random-wait-deck/src) for details.

# Building the release bundle

After you [download](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin/archive/v1.0.16.tar.gz) the 1.0.16 source code, build the release bundle.

 ```shell
 cd pf4jStagePlugin
 ./gradlew releaseBundle
 ```

This command creates the `pf4jStagePlugin-1.0.16.zip` in `pf4jStagePlugin/build/distributions`. Locate the `MANIFEST.MF` in pf4jStagePlugin-1.0.16.zip -> orca.zip -> classes -> META-INF

```
Manifest-Version: 1.0
Plugin-Description: An example of a PF4J based plugin, that provides a
  new stage.
Plugin-Id: Armory.RandomWaitPlugin
Plugin-Provider: https://github.com/claymccoy
Plugin-Version: unspecified
Plugin-Class: io.armory.plugin.stage.wait.random.RandomWaitPlugin
```


# Debugging `random-wait-orca` in Orca locally

> Help us improve this section by submitting a pull request!

1. Ensure your development environment is set up to run Orca locally.
1. Clone Orca branch release-1.19.x
1. Import into IntelliJ
1. Follow the steps in the [Debugging](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin#debugging) section of the pf4jStagePlugin README.


# Debugging `random-wait-deck` in Deck locally

> Help us improve this section by submitting a pull request!

1. Obtain the Deck release-1.19.x branch.
1. Create a folder called `plugins` in the `deck` directory. Copy `RandomWaitStageIndex.js` to the new directory.
1. Add to  `deck\plugin-manifest.json`:

	```json
	[
	  {
		"id": "Armory.RandomWaitPlugin",
		"version": "1.0.16",
		"url": "/plugins/RandomWaitStageIndex.js>"
	  }
	]
	```

1. Start Deck and navigate to the Pipeline creation screen. Verify that `Random Wait` is an option in the Stage drop-down.

# Plugin build and configuration files

> Help us improve this section by submitting a pull request!

`build.gradle`
- `spinnakerBundle` section
- `subprojects` section


`random-wait-orca` subproject, `random-wait-orca.gradle`
- `spinnakerPlugin` section

If you change   | Update values in these files
:---------------|:---------------------------------
project name    | `settings.gradle`, `build.gradle`
subproject name | `settings.gradle`
