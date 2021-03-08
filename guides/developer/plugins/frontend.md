---
layout: single
title: "Frontend Plugin Development"
sidebar:
  nav: guides
---

{% include toc %}

## Overview of Frontend plugins
{% include fe-plugin-intro.md %}

## Before you begin

Make sure you have the following tools installed:

- [Gradle](https://gradle.org/install/)
- [NPM and NPX](https://docs.npmjs.com/cli/v7/configuring-npm/install)
- [Yarn](https://yarnpkg.com/getting-started/install)

You also need access to a running Spinnaker instance `>= 1.20.6` running in a Kubernetes cluster.

This guide focuses on a frontend plugin, but if you need help configuring
a backend plugin, see the [Plugin Project Configuration]({% link guides/developer/plugins/project-config.md %}) and [Backend Extension
Points]({% link guides/developer/plugins/backend.md %}) guides.

##  Plugin scaffolding

You can write a Frontend plugin as standalone or as part of a broader set of functionality. In both cases, you need the Gradle toolchain to build and
release your plugin. The [Deck](https://github.com/spinnaker/deck) project has the `@spinnaker/pluginsdk` [NPM package](https://www.npmjs.com/package/@spinnaker/pluginsdk) that you can use to generate your new frontend plugin's project structure and configuration files.

### Create the plugin project structure

For a new plugin, create a top-level directory:

```shell
mkdir my-plugin
```

Then, from the root of the `my-plugin` directory, run the `@spinnaker/pluginsdk`
scaffold script to create your frontend plugin:

```shell
npx -p @spinnaker/pluginsdk scaffold
```

The script asks a few questions about your plugin. Enter the requested
information and wait for the command to complete:

```shell
npx: installed 117 in 6.229s
Enter the short name for your plugin (default: myplugin): my-plugin
Directory to scaffold into (default: my-plugin-deck):
Deck plugin scaffolded into my-plugin-deck
Installing dependencies using 'yarn' and 'npx check-peer-dependencies --install' ...
```

The script creates the following project structure:

```bash
my-plugin
├──  my-plugin-deck
    ├── .eslintrc.js
    ├── .prettierrc.js
    ├── package.json  
    ├── my-plugin-deck.gradle  
    ├── tsconfig.json  
    ├── rollup.config.js  
    ├── yarn.lock  
    ├── node_modules  
    └── src  
        ├── index.ts  
        ├── WidgetizeStage.less  
        └── WidgetizeStage.tsx  
```  

You may see this `scaffold` command fail to resolve dependencies initially. If
this is the case, you can run the `check-peerdependencies` and `check-plugin`
commands from the `my-plugin-deck` directory until these errors are resolved.

```shell
cd my-plugin-deck
npx check-peer-dependencies --install
```

```shell
npx check-plugin --fix
```

You should now be able to successfully build the plugin:

```shell
yarn && yarn build
```

### Add top-level `build.gradle` file

Your plugin can extend functionality from one or more Spinnaker services. Each service has its own directory within your plugin project structure. Here is an example of the `my-plugin` directory with backend plugins that extends Deck, Gate, and Orca:

```shell
.
├── build.gradle
├── my-plugin-deck
├── my-plugin-gate
└── my-plugin-orca
```

The top-level `build.gradle` file contains plugin metadata, such as the `pluginId`, that Spinnaker needs in order to load the plugin. Since the `scaffold` script does not create a top-level `build.gradle` file, you need to create one at the `my-project` level with the following contents:

```gradle
pluginId = "YourCompany.Plugin.Name"
```

The development tooling uses this top-level Gradle file to create a simple
plugin metadata file. See the [Building & Releasing](#building-and-releasing)
section to learn how to configure the rest of this file to create release
distributions and proper plugin manifest metadata.

## Development workflow

The plugin resources created by the `scaffold` command include functionality to
run your plugin locally, provided that you can connect to an external Spinnaker
instance. The most common way to do this is to `port-forward` your running Deck
instance to your local machine using `kubectl`.

```shell
kubectl port-forward service/spin-deck 90001:9000
```

This forwards Deck to your local machine on port 9001. Then you can run your plugin locally on port 9000 using `yarn develop`.

```shell
DEV_PROXY_HOST=http://localhost:9001 yarn develop
```

You should now be able to navigate to `http://localhost:9000` and access
the Deck UI.  Create a new pipeline and search for the `Widgetize` stage to verify that Spinnaker loaded the frontend plugin correctly.

You can also verify your plugin loaded correctly by navigating to
`http://localhost:9000/plugin-manifest.json`. You should see at least two
plugins listed, the one with your `pluginId` as well as a `plugindev.livereload`
plugin. The development tooling uses `plugindev.livereload` to reload Deck on
each code change in your plugin directory.

### Fixing CORS errors when using a remote deck instance

During development, you may run into
[CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)-related
errors if your Deck service runs on an address other than
`localhost`. If you can, consider [modifying your Gate
instance](https://support.armory.io/support?id=kb_article_view&sysparm_article=KB0010084)
to allow for CORS requests during development.

## Adding new stages

The plugin SDK allows for the addition of new stages and `kinds` within
Spinnaker.  These additions are often be accompanied by changes to Orca and
related services. If you haven't started work on these backend components,
see the [Backend Extension Points]({% link guides/developer/plugins/backend.md %}) guide.

The `scaffold` command creates the most up-to-date schema example, which you
should use as your template when you develop your plugin. If you are writing
a plugin that targets an older version of Spinnaker, you may need to refer to
existing stages for your release to ensure you're following the correct schema.

In general, a Deck stage has these elements:

- A `StageConfig` React component
    - This component wraps `FormikStageComponent` and refers to the React `StageForm` component
- A `StageForm` React component
    - This component provides a set of `FormikFormField` components that
      encapsulate the configuration options for your stage
- A (optional) `validate` function
    - The `validate` function validates a stage configuration. When added to a stage object, `validate` is called whenever input changes in the config form
- A Stage object that encapsulates the previous components
    - This object is passed to the plugin config object and registered
      when Deck starts

You can define more than one stage per plugin. When you're ready to register
your plugin and test in Deck, add all your stages to the `stage` field in your
plugin `index.ts` file like so:

```javascript
import { IDeckPlugin } from '@spinnaker/core';
import { widgetizeStage } from './WidgetizeStage';

export const plugin: IDeckPlugin = {
  stages: [widgetizeStage],
};
```

<!-- FIXME link to a frontend plugin example
https://github.com/spinnaker-plugin-examples/pf4jStagePlugin  needs to be updated to use the latest architecture
-->

## Overriding existing components

You can also override existing components within Deck, so long as they have
an `Overridable` annotation or are registered as an overridable component. In
this use case you would define your replacement component, then leverage the
`initialize` method of your plugin object to override the component when it is
loaded.

For example, if you want to remove the ability to modify Application
configuration in Deck, you would define a component like this:

```javascript
import React from 'react';

export const InvisibleConfig = () => {
  return <h1>No config here!</h1>;
}
```

In order to override the component, you need to know the Application
configuration registration key. You can find its definition in the
source project. There, you find the `Overridable` annotation is
`applicationConfigView`. Then, in your `index.ts` file where your plugin object
is defined, you would override that component in the `initialize` method. For example:


```javascript
import { IDeckPlugin, overrideRegistrationQueue } from '@spinnaker/core';
import { InvisibleConfig } from './InvisibleConfig';

export const plugin: IDeckPlugin = {
  initialize: _ => {
    overrideRegistrationQueue.register(InvisibleConfig, 'applicationConfigView')
  }
};
```

Once installed, you see the Application configuration page now displays our `h1`
header.

## Building and releasing


