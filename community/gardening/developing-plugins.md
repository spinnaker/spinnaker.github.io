---
layout: single
title:  "Plugin Development at Spinnaker Gardening Days"
sidebar:
  nav: community
---
The Spinnaker plugin framework simplifies loading and managing third-party extensions. This makes it easier to extend and integrate with Spinnaker, and to share and evolve those extensions throughout their lifecycles. At this stage, the new plugin framework has a growing list of well-defined extension points. It's time for the community to begin leveraging those extension points to add functionality to Spinnaker, and to explore development of new extension points.

## Intro to plugins assignment at Spinnaker Gardening Days

To jump into Spinnaker plugins, start by creating a custom stage plugin. This will help you become familiar with the framework. For your first plugin project, we recommend that you use the new `SimpleStage` extension point to add your custom pipeline stage to Spinnaker. Read more in the [Plugin Creators Guide](https://www.spinnaker.io/guides/developer/plugin-creators/).

__Consult these guides to get started. Check this page for more plugin training videos, to be added soon!__

### <a href="https://youtu.be/b7BmMY1kR10" target="_blank">How to build a Plugin: Creating a Spinnaker-native custom stage (16m 55s)</a>

<iframe width="560" height="315" src="https://www.youtube.com/embed/b7BmMY1kR10" frameborder="0" allowfullscreen></iframe>

_The Spinnaker plugin framework leverages PF4J. This video focuses on extending functionality via stable, well-defined extension points. It demonstrates using the Orca stage extension point to add an example custom stage that waits a random amount of time as part of a Spinnaker pipeline. It also shows how to set up IntelliJ to debug plugins._

### <a href="https://www.youtube.com/u9NVlG58NYo" target="_blank">How to build a Plugin: Building the frontend for a Spinnaker-native custom stage (8m 56s)</a>

<iframe width="560" height="315" src="https://www.youtube.com/embed/u9NVlG58NYo" frameborder="0" allowfullscreen></iframe>

_This video focuses on creating a presentation layer for Deck using TypeScript and React. It discusses the frontend-backend interaction in a Spinnaker plugin and demonstrates what a native custom stage looks like in the Spinnaker UI._

### <a href="https://www.youtube.com/watch?v=-AIOXdgvNqs" target="_blank">How to build a PLUGIN: The build process for a Spinnaker plugin (4m 53s)</a>

<iframe width="560" height="315" src="https://www.youtube.com/watch?v=-AIOXdgvNqs" frameborder="0" allowfullscreen></iframe>

This video focuses on the Gradle build process for packaging plugin development projects, using the custom stage plugin as an example.

### <a href="https://www.youtube.com/watch?v=G2eyc9gzNS0" target="_blank">How to build a PLUGIN: Delivering a plugin to your Spinnaker environment (10m 53s)</a>

<iframe width="560" height="315" src="https://www.youtube.com/watch?v=G2eyc9gzNS0" frameborder="0" allowfullscreen></iframe>

This video focuses on delivering a plugin to a running Spinnaker instance for integration testing and beyond. It uses the custom stage plugin as an example.

