---
layout: single
title: "ExtensionPoint Plugin Walkthrough"
sidebar:
  nav: guides
---

{% include toc %}

<div class="notice--danger">
  <strong>Note:</strong> Plugins are an alpha feature that is under active development and may change.
</div>


# Prerequisites

* Spinnaker v1.19.0
* Halyard 1.32
* Orca branch `release-1.19.x` (for local testing)
* IntelliJ IDEA (for local testing)
* You have read the [Plugin Creators Guide Overview](/guides/developer/plugin-creators-guide/overview/).


# pf4jStagePlugin ExtensionPoint plugin

The [pf4jStagePlugin](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin) creates a custom pipeline stage that waits a specified number of seconds before signaling success.

## Structure

The plugin has frontend (`random-wait-deck`) and backend (`random-wait-orca`) components.

The backend consists of five [Kotlin](https://kotlinlang.org/docs/reference/) classes in the `io.armory.plugin.state.wait.random` package:

* `Context.kt`: a data class that stores the `maxWaitTime` value
* `Output.kt`: a data class that stores the `timeToWait` getValue
The plugin backend implements the Orca `com.netflix.spinnaker.orca.api.SimpleStage` interface.

# Project Configuration

Keep the following recommendations and requirements in mind:
- We recommend making the project a Gradle project. There is Gradle tooling to support plugin development.
- You can add any dependencies you need to make your plugin successful.. *TODO-CF* this is almost certainly a lie when
  it comes to things that conflict with the dependencies in the compileOnly scope...

## Gradle configuration

Some important aspects of your project's gradle build:

### gradle.properties
This is optional, but externalizes the versions of tooling and API dependencies from your
build script.
```
spinnakerGradleVersion=7.5.2
pf4jVersion=3.2.0
korkVersion=7.30.0
orcaVersion=8.2.0
version=1.2.3
```

Note that managing the version of your plugin here (`version=1.2.3`) requires modifying
this file for each release. There are fancier ways (the example project uses a git tag
strategy and additional gradle plugins) but those are outside the scope of this
documentation.

### top level build.gradle
```
// (1):
buildscript {
  repositories {
    maven { url "https://dl.bintray.com/spinnaker/gradle/" }
  }
  dependencies {
    classpath("com.netflix.spinnaker.gradle:spinnaker-extensions:$spinnakerGradleVersion")
  }
}

// (2):
plugins {
  //... other plugins you might be using
  id("com.moowork.node").version("1.3.1").apply(false)
}

// (3):
apply plugin: "io.spinnaker.plugin.bundler"
spinnakerBundle {
  pluginId = "Armory.RandomWaitPlugin"
  description = "An example of a PF4J based plugin, that provides a new stage."
  provider = "https://github.com/spinnaker-plugin-examples"
  version = rootProject.version
}
```

**Notes:**
1. The `buildscript` block brings in the spinnaker-extensions gradle tooling, which includes
   plugins for creating a bundle, ui-extension, and service-extension.
2. The `plugins` block imports the node plugin but does not apply it. This plugin is needed by
   the ui-extension to build the us assets.
3. At the top level we apply the `io.spinnaker.plugin.bundler` to define the name of the plugin
   bundle this project is producing along with bundle metadata.

### ui-extension build.gradle

To build a UI extension with the base conventions, the only thing necessary is
applying the `io.spinnaker.plugin.ui-extension` plugin.

**TODO** document what the ui-extension plugin supplies / supports. Maybe some of that is below?

```
apply plugin: "io.spinnaker.plugin.ui-extension"
```

### service-extension build.gradle
Here are the basic things your service-extension gradle build needs. Note that the example project
includes a bunch of additional configuration to configure kotlin for the plugin. The configuration
below strips that out to just include the basic gradle configuration necessary for a JVM plugin, if
you wish to develop plugins in kotlin refer to the gradle build from the example project.

```
// (1):
apply plugin: "io.spinnaker.plugin.service-extension"
apply plugin: "maven-publish"

// (2):
sourceCompatibility = 1.8
targetCompatibility = 1.8

dependencies {
  // (3):
  annotationProcessor("org.pf4j:pf4j:$pf4jVersion)

  // (4):
  compileOnly("com.netflix.spinnaker.kork:kork-plugins-api:$korkVersion")
  compileOnly("com.netflix.spinnaker.orca:orca-api:$orcaVersion")

  // (5):
  // implementation("com.something.my.plugin.needs:dependency:version")
}

// (6):
spinnakerPlugin {
  serviceName = "orca"
  pluginClass = "io.armory.plugin.stage.wait.random.RandomWaitPlugin"
}
```

**Notes:**
1. The `io.spinnaker.plugin.service-extension` and `maven-publish` are used for plugin bundling
   and metadata generation.
2. Spinnaker services require JDK 1.8 compatible bytecode.
3. Enable pf4j annotation processing to build plugin extension metadata
4. The plugin APIs are marked as `compileOnly` so as to not include them in the resulting plugin
   jar. These dependencies must be loaded from the service's classloader, not the plugin classloader.
5. You can include additional dependencies that your plugin requires. These dependencies will be
   bundled into the plugin and in a private classloader for the plugin.
6. The `spinnakerPlugin` block is used to generate plugin and bundle metadata. The `serviceName`
   is the spinnaker service this plugin extends (and should match the service api depenency
   brought in in `(4)` above).
```

## IntelliJ Configuration

With the gradle configuraton above, you should be able to import your plugin into IntelliJ as a project.

### ui-extension IDE configuration

**TODO**

### service-extension IDE configuration

#### plugin debugging in a local service

If you have a local instance of a host service (in the plugin example this is `orca`) running, you can link your plugin into that service with a `plugin-ref` that points to your local development workspace.

There are two options, depending on how you run the host service:

##### Running the host service in the IDE

If you have the ability to run a service locally in IntelliJ (the configuration for that is outside the scope of this document), then you can add configure your IntelliJ project with both the host service and your plugin in the same workspace.

Open the IntelliJ project you have configured for the host service, click the `+` button on the Gradle tab, and navigate to your plugin project's build.gradle. This will include the plugin project in the workspace.

##### Attaching to a remote JVM process for the host service

You can debug a service extension in the IDE, provided you have an instance of the host service to
attach a debugger to, and that the host service shares a filesystem with your plugin development workspace.

In your plugin project in IntelliJ, in the run configurations, add a configuration of type Remote.

Select "Attach to a remote JVM"

In use module classpath, select the main classpath from the service-extension plugin (helloworld-orca.main) in the example project.

Copy the command-line arguments for the JVM from this dialog, and ensure however you are launching the host service locally that it gets those JVM arguments.

#### linking the plugin-ref to the host service

When you build your plugin project with gradle, it will produce a `.plugin-ref` file in the build/ directory for the plugin. You only need to do this once initially, and if your plugin dependencies are changed to regenerate it.

Once you have that file generated, navigate to the `plugins` directory for the host service, wherever you are running it. You can then create a symlink to the `.plugin-ref` file, and this will cause the host service to see your plugin and load the classes from your development workspace when the host service starts up.

For the example project:
```
$ cd /path/to/orca/plugins
$ ln -sf /path/to/dev/workspaces/spinnaker-plugin-helloworld/helloworld-orca/build/orca.plugin-ref
```

Now, when you attach your debugger to the host services, any breakpoints in your plugin code will be hit and you can step throught them in your IDE, evaluate expressions, etc.

# Create The Frontend For Stage Plugins

## Setting Up Your Project

### Rollup Configuration
Here is an example of a `rollup.config.js` to build your plugin:

```
import nodeResolve from 'rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs';
import typescript from 'rollup-plugin-typescript';
import postCss from 'rollup-plugin-postcss';
import externalGlobals from 'rollup-plugin-external-globals';

export default [
  {
    input: 'src/index.tsx',
    plugins: [
      nodeResolve(),
      commonjs(),
      typescript(),
      // Map imports from shared libraries (React, etc) to global variables exposed by Spinnaker.
      externalGlobals(spinnakerSharedLibraries()),
      // Import from .css, .less, and inject into the document <head></head>.
      postCss(),
    ],
    output: [{ dir: 'dist', format: 'es', }]
  }
];

function spinnakerSharedLibraries() {
  const libraries = ['react', 'react-dom', '@spinnaker/core'];

  function getGlobalVariable(libraryName) {
    const prefix = 'spinnaker.plugins.sharedLibraries';
    const sanitizedLibraryName = libraryName.replace(/[^a-zA-Z0-9_]/g, '_');
    return `${prefix}.${sanitizedLibraryName}`;
  }

  return libraries.reduce((globalsMap, libraryName) => {
    return { ...globalsMap, [ libraryName ]: getGlobalVariable(libraryName) }
  }, {});
}
```

`spinnakerSharedLibraries` pulls dependencies from Spinnaker. The libraries constant is a list of libraries that make the plugin work correctly.
Items in this list must be from the [shared libraries](https://github.com/spinnaker/deck/blob/master/app/scripts/modules/core/src/plugins/sharedLibraries.ts#L32) exposed to plugin creators.

### Dependencies
As mentioned above, Spinnaker exposes libraries for plugins to use. Define dependencies in package.json. For this example plugin, the dependencies are:

```
"@spinnaker/core": "0.0.432",
"react": "^16.12.0",
"react-dom": "^16.12.0"
```

## Writing The Frontend

```
import * as React from 'react';
import { IStageTypeConfig, IStageConfigProps } from '@spinnaker/core';

const customStage: IStageTypeConfig = {
  label: 'Random Wait',
  description: 'Stage that waits a random amount of time up to the max inputted',
  key: 'randomWait',
  component: RandomWaitStage,
};

function setMaxWaitTime(event: React.SyntheticEvent, props: IStageConfigProps) {
  let target = event.target as HTMLInputElement;
  props.updateStageField({'maxWaitTime': target.value});
}

// Our stage component
function RandomWaitStage(props: IStageConfigProps) {
  return (
    <div>
      <label>
          Max Time To Wait
          <input value={props.stage.maxWaitTime} onChange={(e) => setMaxWaitTime(e, props)} id="maxWaitTime" />
      </label>
    </div>
  );
}

const plugin = {
  name: 'randomWait',
  stages: [customStage],
};

export { plugin };
```

### IStageTypeConfig
Define Spinnaker Stages with IStageTypeConfig. Required [options:](https://github.com/spinnaker/deck/blob/abac63ce5c88b809fcf5ed1509136fe96489a051/app/scripts/modules/core/src/domain/IStageTypeConfig.ts)
- label -> The name of the Stage
- description -> Long form that describes what the Stage actually does
- key -> A unique name for the Stage
- component -> The rendered React component

### IStageConfigProps
`IStageConfigProps` defines properties passed to all Spinnaker Stages. See [IStageConfigProps.ts](https://github.com/spinnaker/deck/blob/master/app/scripts/modules/core/src/pipeline/config/stages/common/IStageConfigProps.ts) for a complete list of properties. Pass a JSON object to the `updateStageField` method to add the `maxWaitTime` to the Stage.

### RandomWaitStage
This method returns [JSX](https://reactjs.org/docs/introducing-jsx.html) that gets displayed to the plugin user.

### How Spinnaker Loads The Plugin
Each plugin must export an object named `plugin`. You can only add Stages to this object. At startup, Spinnaker looks at `plugin.stages` and adds each defined Stage to the Stage Registry.

# Writing The Plugin Manifest

Here is an example of a plugin manifest:
```
name: armory/randomWaitStage
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

The `name` is the name of the plugin that is being written. Names are namespaced so that plugins can have the same name but be made by different vendors. In this case, the namespace is `armory` and the name of the plugin is `s3copy`.

The `description` gives the plugin user an idea of what the plugin will be doing.

The `manifestVersion` tells Spinnaker what version to use to validate the manifest. This is needed because lugin manifests can change overtime. Currently, there is only the `plugins/v1` version.

`version` is the version of the plugin.

The `options` key gives the plugin users that flexibility to change some settings to control how the plugin works. For example, controlling what username and password to use to connect to S3. The plugin user can modify anything under `options`.

The final section in the manifest is for `resources`. Resources are files that are required for the plugin to run.
For example, Orca needs access to a plugin's jar(s) in order to provide the functionality for a custom stage.
Since there are many Spinnaker services, we use the manifest to let Spinnaker operators know which resources need to be put on which service.
In the example above, we include a list of URLs where the jar(s) are located for Orca to use.


[SimpleStage]: https://github.com/spinnaker/orca/blob/ab89a0d7f847205ccd62e70f8a714040a8621ee7/orca-api/src/main/java/com/netflix/spinnaker/orca/api/SimpleStage.java

[PreconfiguredJobConfigurationProvider]: https://github.com/spinnaker/orca/blob/master/orca-api/src/main/java/com/netflix/spinnaker/orca/api/preconfigured/jobs/PreconfiguredJobConfigurationProvider.java

[SimpleStageStatusLink]: https://github.com/spinnaker/orca/blob/ab89a0d7f847205ccd62e70f8a714040a8621ee7/orca-api/src/main/java/com/netflix/spinnaker/orca/api/SimpleStageStatus.java

[EchoEventListener]: https://github.com/spinnaker/echo/blob/master/echo-api/src/main/java/com/netflix/spinnaker/echo/api/events/EventListener.java
