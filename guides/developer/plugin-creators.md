---
layout: single
title: "Plugin Creators Guide"
sidebar:
  nav: guides
---

{% include toc %}

<div class="notice--danger">
  <strong>Note:</strong> Plugins are an early alpha feature that is under active development and will likely change.
</div>

This guide is for creating a new plugin to Spinnaker. For information about how to use an existing plugin, see [Plugin Users Guide](/guides/user/plugin-users/).

# Create the Backend For Stage Plugins

## Example Plugin

This document shows how to create a simple plugin that waits a random amount of time, from zero to the number of seconds that is entered in the UI. Use this guide as a starting point to facilitate creating more complex plugins. 

## Setting Up Your Project

To get started setting up your project, we highly suggest using [https://start.spring.io](https://start.spring.io/) to create your base project. 

Keep the following recommendations and requirements in mind:

- We recommend making the project a Gradle project. 
- You must set the base package path for the plugin to the following path: `com.netflix.spinnaker.plugin`. You can add anything else after that, but that is required. 
- You can add any dependencies you need to make your plugin successful.

Generate the project and unzip it to a location of your choosing. Modify the `build.gradle`  file to look like the following example:
```
plugins {
    id 'org.springframework.boot' version '2.1.8.RELEASE' apply false
    id 'io.spring.dependency-management' version '1.0.8.RELEASE'
    id 'java'
}

dependencyManagement {
    imports {
        mavenBom(org.springframework.boot.gradle.plugin.SpringBootPlugin.BOM_COORDINATES)
    }
}

group = 'com.netflix.spinnaker.plugin'  // make sure this is your package path!
version = '0.0.1-SNAPSHOT'
sourceCompatibility = '1.8'

repositories {
    mavenCentral()
    jcenter()
    maven { url "https://spinnaker.bintray.com/gradle" }
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    compile group: 'com.netflix.spinnaker.orca', name: 'orca-api', version: '7.36.0'
}
```
Then, we can remove both of the tests and the main application. (Don’t worry, we will add our own tests!)


## Creating The Plugin Stage

In order to create the stage plugin, we first have to define three classes. The three classes that we need to define are our Stage Input, Stage Output Context, and Stage Output Outputs. 

**SimpleStage Input**

SimpleStage Input is what our stage needs to use to do its job. The stage input comes from the Spinnaker UI. First, we have to create a class that will be used as our Stage input. In this example, the plugin will take the max time to wait.
```
@Data
class RandomWaitInput {
    private int maxWaitTime;
}
```

**SimpleStage Context**

Context is used within the stage itself. In this example, the maxWaitTime will be added here.
```
@Data
class Context {
    private int maxWaitTime;
    public Context(int maxWaitTime) {
      this.maxWaitTime = maxWaitTime;
    }
}
```

**SimpleStage Output**

Output is what can be used later in other stages. In this case, the output contains the actual number of seconds the stage waits.
 
```
@Data
class Output {
    private int timeToWait;
    public Output(int timeToWait) {
      this.timeToWait = timeToWait;
    }
}
```
## Create Stage Class

The stage itself needs to implement the `[SimpleStage](https://github.com/spinnaker/orca/blob/ab89a0d7f847205ccd62e70f8a714040a8621ee7/orca-api/src/main/java/com/netflix/spinnaker/orca/api/SimpleStage.java)` interface. The two methods that we need to implement are `getName` and `execute`.

**getName**
`getName` is a method that tells Spinnaker what the name of the stage is. 

**execute**
`execute` is the meat of the stage. `execute` takes in a `SimpleStageInput` that will take in as a generic the class that was created earlier for stage input. `execute` will return a `SimpleStageOutput` that has our `Output` and `Context` classes. `SimpleStageOutput` also needs to know the status of the stage. This is where the `[SimpleStageStatus](https://github.com/spinnaker/orca/blob/ab89a0d7f847205ccd62e70f8a714040a8621ee7/orca-api/src/main/java/com/netflix/spinnaker/orca/api/SimpleStageStatus.java)` comes into play. Currently stages can be in the following states:

1. Terminal → the stage failed
2. Running → the stage is still executing
3. Succeeded → the stage has successfully completed
4. Not Started → the stage has not started yet

**Putting it all together**
```
public class RandomWait<RandomWaitInput> {
  @Override
  public String getName() {
    return "randomWait";
  }

  @Override
  public SimpleStageOutput execute(SimpleStageInput<RandomWaitInput> stageInput) {
    Random rand = new Random();
    int maxWaitTime = stageInput.getValue().getMaxWaitTime();
    int timeToWait = rand.nextInt(maxWaitTime);

    try {
      TimeUnit.SECONDS.sleep(timeToWait);
    } catch(Exception e) {
      log.error("{}", e);
    }

    SimpleStageOutput<Output, Context> stageOutput = new SimpleStageOutput();
    Output output = new Output(timeToWait);
    Context context = new Context(maxWaitTime);

    stageOutput.setOutput(output);
    stageOutput.setContext(context);
    stageOutput.setStatus(SimpleStageStatus.SUCCEEDED);

    return stageOutput;
  }
}
```

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

`spinnakerSharedLibraries` is used to pull depenedencies from Spinnaker. To see the list of depenedcies Spinnaker exposes to plugin creators, please take a look at [shared libraries](https://github.com/spinnaker/deck/blob/master/app/scripts/modules/core/src/plugins/sharedLibraries.ts#L32). `libraries` is the list of libraries needed from Spinnaker to make a plugin work correctly. This list must contain libraries from the shared libraries section in Spinnaker.

### Dependencies
As mentioned above, Spinnaker exposes depenedncies for plugins to use. But the depenedencies need to be defined in the `package.json`. For this example plugin, the dependcies needed are:

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
`IStageTypeConfig` is how Spinnaker Stages are defined. There are only a few required [options](https://github.com/spinnaker/deck/blob/abac63ce5c88b809fcf5ed1509136fe96489a051/app/scripts/modules/core/src/domain/IStageTypeConfig.ts) for configuring a Stage.
1. label -> The name of the Stage
2. description -> Long form that describes what the Stage actually does
3. key -> A unique name for the Stage
4. component -> The React component that will be rendered to the user

### IStageConfigProps
`IStageConfigProps` are the properties passed to all Spinnaker Stages. For a complete list of what is available for `IStageConfigProps`, please check [IStageConfigProps.ts](https://github.com/spinnaker/deck/blob/master/app/scripts/modules/core/src/pipeline/config/stages/common/IStageConfigProps.ts). The method `updateStageField` is what is used to add the `maxWaitTime` to the stage. This method takes a JSON object.

### RandomWaitStage
This method returns [JSX](https://reactjs.org/docs/introducing-jsx.html) that gets displayed to the plugin user.

### How Spinnaker Loads The Plugin
Each plugin has to `export` an object named `plugin`. Currently only Stages can be added to this object. When Spinnaker starts up it will look at `plugin.stages` and add each stage that is defined to the stage registry.

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

