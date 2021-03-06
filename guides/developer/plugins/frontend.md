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
[Backend Extension Points]: {% link guides/developer/plugins/backend.md %}

# Development Workflow

# Building & Releasing
