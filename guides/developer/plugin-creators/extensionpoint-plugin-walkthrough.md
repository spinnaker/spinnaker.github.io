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

This walkthrough assumes you have read the [Plugin Creators Guide Overview](/guides/developer/plugin-creators-guide/overview/).


# pf4jStagePlugin ExtensionPoint plugin

The [pf4jStagePlugin](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin) creates a custom pipeline stage that waits a specified number of seconds before signaling success.

## Structure

The plugin has frontend (`random-wait-deck`) and backend (`random-wait-orca`) components.

The backend consists of five [Kotlin](https://kotlinlang.org/docs/reference/) classes in the `io.armory.plugin.state.wait.random` package:

* `Context.kt`: a data class that stores the `maxWaitTime` value
* `Output.kt`: a data class that stores the `timeToWait` getValue
The plugin backend implements the Orca `com.netflix.spinnaker.orca.api.SimpleStage` interface.

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
