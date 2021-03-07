---
layout: single
title: "Frontend Plugin Development"
sidebar:
  nav: guides
---

{% include fe-plugin-intro.md %}

{% include toc %}

# Required Tools

Before getting started make sure you have the following tools installed:

- [Gradle]
- [NPM]
- [Yarn]

[Gradle]: https://gradle.org/install/
[NPM]: https://docs.npmjs.com/cli/v7/configuring-npm/install
[Yarn]: https://yarnpkg.com/getting-started/install

You will also need access to a running Spinnaker cluster `>= 1.20.6`.

# Plugin Scaffolding

Frontend plugins can be written as part of a broader set of functionality or
on their own. In both cases you will need the Gradle toolchain to build and
release your plugin.

Here is what a typical plugin project will look like for a plugin named
`my-plugin`:

```shell
.
├── build.gradle
├── my-plugin-deck
├── my-plugin-gate
└── my-plugin-orca
```

The top-level `build.gradle` file contains metadata related to your plugin,
such as the plugin id that will allow you to add it to your Spinnaker cluster.
Each core Spinnaker service will have it's own directory. This guide will focus
on frontend, but if you need help configuring a backend plugin check out the
[Plugin Project Configuration] and [Backend Extension Points] guides.

If you're starting from scratch you will need to create a top-level directory
for your plugin:

```shell
mkdir my-plugin
```

Then, from the root of this directory, run the scaffold script to create your
frontend plugin (`npx` is installed for you alongside `npm`):

```shell
npx -p @spinnaker/pluginsdk scaffold
```

You will be asked a few questions about your plugin. Enter the requested
information and wait for the command to complete:

```shell
npx: installed 117 in 6.229s
Enter the short name for your plugin (default: myplugin): my-plugin
Directory to scaffold into (default: my-plugin-deck):
Deck plugin scaffolded into my-plugin-deck
Installing dependencies using 'yarn' and 'npx check-peer-dependencies --install' ...
```

You may see this command fail resolve dependencies initially. If this is the
case, you can run the `check-plugin` and `check-peerdependencies` commands
until these errors go away:

```shell
cd my-plugin && npx check-plugin --fix
```

```shell
npx check-peer-dependencies --install
```

You should now be able to successfully build plugin:

```shell
yarn && yarn build
```

## Pure Frontend Plugins

If you're only writing a frontend plugin then a `build.gradle` will not have
been created for you as part of the scaffolding process. If this is the case,
create this file with the following contents:

```gradle
pluginId = "YourCompany.Plugin.Name"
```

This will allow the development tooling to create a simple plugin metadata file.
In the [Building & Releasing](#building--releasing) section you will learn how
to configure the rest of this file to create release distributions and proper
plugin manifest metadata.

[Plugin Project Configuration]: {% link guides/developer/plugins/project-config.md %}

# Development Workflow

The plugin resources provided by the scaffold command include behavior to run
your plugin locally provided that you can connect to an external Spinnaker. The
most common way to do this is to port-forward your running Deck instance to
your local machine and run the `develop` command like in the following example
commands:

```shell
kubectl port-forward service/spin-deck 90001:9000
```

This will port-forward Deck to your local machine on port 9001. We do this so
that we can run the plugin locally on port 9000.

```shell
DEV_PROXY_HOST=http://localhost:9001 yarn develop
```

You should now be able to navigate to `http://localhost:9000` and see the Deck
UI load. You can verify that the `Widgetize` stage provided by the scaffold
command loads correctly by creating a new pipeline and searching for the
`Widgetize` stage.

You can also verify plugins are loading correctly by navigating to
`http://localhost:9000/plugin-manifest.json`. You should expect to see at least
two plugins listed, the one with your plugin id (`YourCompany.Plugin.Name` from
an earlier step in this document) as well as a `plugindev.livereload` plugin
that is used by the development tooling to reload Deck on each code change in
your plugin directory.

## Fixing CORS Errors When Using a Remote Deck Instance

You may run into CORS related errors if your Deck lives at an address other
than `localhost` when working on your plugin. If it is possible to do so you
may consider [modifying your Gate instance][CORS] to allow for CORS requests
during development.

[CORS]: https://support.armory.io/support?id=kb_article_view&sysparm_article=KB0010084&sys_kb_id=3c1ef17d1b202c1013d4fe6fdc4bcbef&spa=1

# Adding New Stages

The plugin SDK allows for the addition of new stages and kinds within
Spinnaker.  These additions will often be accompanied by changes to Orca and
related services. If you haven't started work on these backend components
consider referring to the [Backend Extension Points] guide.

The scaffolded stage that is provided is considered the most up to date schema
that should be followed when developing plugins. If you are writing a plugin
that targets an older version of Spinnaker you may need to refer to existing
stages for your release to ensure you're following the correct schema.

In general, Deck stages are composed of a few different elements:

- A stage config React component
    - This component wraps `FormikStageComponent` and refers to the form
      component below
- A form React component
    - This component provides a set of `FormikFormField` components that
      encapsulate the configuration options for your stage 
- A (optional) validation function
    - The validation function is provided a snapshot of stage configuration to
      validate against. When added to a stage object it will be called whenever
      input changes in the config form
- A Stage object that encapsulates the previous components
    - This object will be passed to the plugin config object and registered
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

<!-- FIXME link to a frontend plugin example -->

# Overriding Existing Components

You can also override existing components within Deck, so long as they have an
`Overridable` annotation or registered as an overridable component. In this use
case you would define your replacement component, then leverage the
`initialize` method of your plugin object to override the component when it is
loaded.

For example, if we want to remove the ability to modify Application
configuration in Deck, we would define a component like so:

```javascript
import React from 'react';

export const InvisibleConfig = () => {
  return <h1>No config here!</h1>;
}
```

In order to override the component we need to know the key that the Application
configuration is registered as.  We found the element in Deck using the React
developer tools, then found it's definition in the source project. There, we
find the `Overridable` annotation is `applicationConfigView`.  Then, in our
`index.ts` file where our plugin object is defined, we would override that
component in the `initialize` method.


```javascript
import { IDeckPlugin, overrideRegistrationQueue } from '@spinnaker/core'; 
import { InvisibleConfig } from './InvisibleConfig';

export const plugin: IDeckPlugin = {
  initialize: _ => {
    overrideRegistrationQueue.register(InvisibleConfig, 'applicationConfigView')
  }
};
```

Once installed, we see the Application configuration page now displays our `h1`
header.

# Building & Releasing

[Backend Extension Points]: {% link guides/developer/plugins/backend.md %}
