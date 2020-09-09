---
layout: single
title:  "Plugin Creators Guide"
sidebar:
  nav: guides
---

This section contains the following content:

* [Overview](/guides/developer/plugin-creators/overview/):  Explains the types of plugins you can use with Spinnaker.
* [Plugin Project Configuration](/guides/developer/plugin-creators/project-config): _Work in Progress_ Plugins are an evolving feature.  The easiest way to set up a new plugin project is to copy one of the [spinnaker-plugin-examples](https://github.com/spinnaker-plugin-examples) projects that most closely resembles what you want to do.
* [Test a Pipeline Stage Plugin](/guides/developer/plugin-creators/deck-plugin/): This guide explains how to set up a local Spinnaker environment on your Mac or Windows environment so you can test the `pf4jStagePlugin`, which has both Orca and Deck components. Spinnaker services running locally communicate with the other Spinnaker services running in a local VM. Although this guide is specific to the `pf4jStagePlugin`, you can adapt its contents to test your own plugin.