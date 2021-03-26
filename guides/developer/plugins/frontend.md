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

- [Gradle](https://gradle.org/install/).
- [NPM and NPX](https://docs.npmjs.com/cli/v7/configuring-npm/install).
- [Yarn](https://yarnpkg.com/getting-started/install).

You also need access to a Spinnaker instance `>= 1.20.6` running in a Kubernetes cluster.

This guide focuses on a frontend plugin, but if you need help configuring
a backend plugin, see the [Plugin Project Configuration]({% link
guides/developer/plugins/project-config.md %}) and [Backend Extension Points]({%
link guides/developer/plugins/backend.md %}) guides.

##  Plugin scaffolding

You can write a Frontend plugin as standalone or as part of a broader set of functionality. In both cases, you need the Gradle toolchain to build and release your plugin. The [Deck](https://github.com/spinnaker/deck) project has the `@spinnaker/pluginsdk` [NPM package](https://www.npmjs.com/package/@spinnaker/pluginsdk) that you can use to generate your new frontend plugin's project structure and configuration files.

### Create the plugin project structure

For a new plugin, create a top-level directory:

```shell
mkdir my-plugin
```

Then, from the root of the `my-plugin` directory, run the `@spinnaker/pluginsdk`
`scaffold` script to create your frontend plugin:

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

### Gradle Configuration

In order to build and release your plugin, you need to ensure that you have
your Gradle environment configured correctly. Follow the advice in the [Plugin
Project Configuration]({% link guides/developer/plugins/project-config.md %})
document up to the `UI-extension build.gradle` section.

The development tooling uses this top-level Gradle file to create a simple
plugin metadata file. See the [Build and release](#build-and-release)
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

### Fix CORS errors when using a remote deck instance

During development, you may run into
[CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)-related
errors if your Deck service runs on an address other than
`localhost`. If you can, consider [modifying your Gate
instance](https://support.armory.io/support?id=kb_article_view&sysparm_article=KB0010084)
to allow for CORS requests during development.

## Add new stages

The plugin SDK enables the addition of new stages and `kinds` within
Spinnaker.  These additions are often accompanied by changes to Orca and
related services. If you haven't started work on these backend components,
see the [Backend Extension Points]({% link guides/developer/plugins/backend.md %}) guide.

The `scaffold` command creates the most up-to-date schema example, which you
should use as your template when you develop your plugin. If you are writing
a plugin that targets an older version of Spinnaker, you may need to refer to
existing stages for the Spinnaker release to ensure you're following the correct schema.

In general, a Deck stage has these elements:

- A `StageConfig` React component.
    - This component wraps `FormikStageComponent` and refers to the React `StageForm` component.
- A `StageForm` React component.
    - This component provides a set of `FormikFormField` components that
      encapsulate the configuration options for your stage.
- A (optional) `validate` function.
    - The `validate` function validates a stage configuration. When added to a stage object, `validate` is called whenever input changes in the config form.
- A Stage object that encapsulates the previous components.
    - This object is passed to the plugin config object and registered
      when Deck starts.

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

## Override existing components

You can also override existing components within Deck, so long as they have
an `Overridable` annotation or are registered as an overridable component. In
this use case, you define your replacement component and then leverage the
`initialize` method of your plugin object to override the component when it is
loaded.

For example, if you want to remove the ability to modify Application
configuration in Deck, you define a component like this:

```javascript
import React from 'react';

export const InvisibleConfig = () => {
  return <h1>No config here!</h1>;
}
```

In order to override the component, you need to know
the Application configuration registration key. You
can find its definition in the GitHub Deck project,
[ApplicationConfig.tsx](https://github.com/spinnaker/deck/blob/43a0f56fa85fa1714fef0ba73810c90761f5996d/app/scripts/modules/core/src/application/config/ApplicationConfig.tsx).
There, you find the `Overridable` annotation is `applicationConfigView`. Then,
in your `index.ts` file where you define your plugin object, you override that
component in the `initialize` method. For example:


```javascript
import { IDeckPlugin, overrideRegistrationQueue } from '@spinnaker/core';
import { InvisibleConfig } from './InvisibleConfig';

export const plugin: IDeckPlugin = {
  initialize: () => {
    overrideRegistrationQueue.register(InvisibleConfig, 'applicationConfigView')
  }
};
```

Once installed, you see the Application configuration page now displays the `h1`
header.

## Build and release

Building and releasing requires adding a distribution repository,
building and committing changes for the plugin, and hosting the plugin.

### Create plugin packages

Creating a plugin distribution starts from the root of your plugin project.
The `releaseBundle` task is responsible for creating zip distributions of all
plugin code and storing it in the `build/distributions` directory. Run the `releaseBundle` task to get started:

```shell
./gradlew releaseBundle
```

If you find the zip archive doesn't contain all your plugin code, make sure
that you've included each plugin sub-directory in the parent build. You can
do that by editing the `settings.gradle` file and ensuring that each project
is `included`. For example:

```gradle
// file: my-plugin/settings.gradle

// other configuration ...

include "my-plugin-deck"

// other configuration ...
```

### Create distribution files

Spinnaker needs a `repositories.json` file and a `plugins.json` file to install a plugin. `repositories.json` represents a set of pointers to plugin files, and `plugins.json` lists all versions of a particular plugin. See the [Plugin Users Guide]({% link guides/user/plugins/index.md %}) for more information.

The format of the `repositories.json` file looks like this:

```json
[
    {
      "id": "myPluginRepo",
      "url": "https://raw.githubusercontent.com/my-org/my-plugin-repo/master/plugins.json"
    }
]
```

The `id` key uniquely identifies your plugin repository. The `url` points to
where your keep your `plugins.json` file. This URL can be any URI so long as Spinnaker can reach it.

The `releaseBundle` command that generates the plugin packages also generates required metadata. You can find this metadata in the `build/distributions/plugin-info.json` file. You must provide the value for the `url` key. The value is the location of your plugin zip file. You can store the file in any location that Spinnaker can access.

Here is an example `plugins.json` file's contents:

```json
[
  {
    "id": "My.Plugin.Id",
    "description": "This a sample plugin.",
    "provider": "https://github.com/my-organization",
    "releases": [
      {
        "version": "0.1.0",
        "date": "2021-03-09T17:30:00.948341Z",
        "requires": "deck>=0.0.0",
        "sha512sum": "a91cb7d412a25ca5e1b2d72e14ab499986d5773ae8016721fbefd0adf430e33b75e8e61bac92244bbbe4811f118724ec6e2bb568fdd8181a9e11327a96b45da9",
        "url": "https://github.com/my-organization/my-plugin/blob/master/my-plugin-v0.1.0.zip?raw=true"
      }
    ]
  }
]
```

You can store the `repositories.json` and `plugins.json` in any location that Spinnaker can reach. Most developers store these files in a repository separate from the plugin code.

### Create an installation README for your users

In addition to explaining what your plugin does, you should include a YAML snippet showing your plugin's configuration. For example:

```yaml
profiles:
  spinnaker:
    spinnaker:
      extensibility:
        plugins:
          # The plugin id you defined in your build.gradle
          My.Plugin.Id:
            enabled: true
            # This must be a SemVer-compatible string
            # (i.e. do not include a `v` in front of the version string)
            version: "0.1.0"
  gate:
    spinnaker:
      extensibility:
        # This snippet is necessary so that Gate can serve your plugin code to Deck
        deck-proxy:
          enabled: true
          plugins:
            My.Plugin.Id:
              enabled: true
        repositories:
          myPluginRepo:
            enabled: true
            url: https://raw.githubusercontent.com/my-organization/my-plugin-repo/master/repositories.json
```


## Next steps

* [Test your plugin locally using Minnaker]({% link guides/developer/plugins/testing/deck-plugin.md %})
* [Plugin Compatibility Testing]({% link guides/developer/plugins/testing/compatibility-testing.md %})
* [Deploy your plugin using Halyard]({% link guides/user/plugins/index.md %})

{% include plugins-spin-operator.md %}

