---
layout: single
title:  "Plugin Development at Spinnaker Gardening Days"
sidebar:
  nav: community
---
The Spinnaker plugin framework simplifies loading and managing third-party plugins. This makes it easier to extend Spinnaker, and to share and evolve those extensions throughout their lifecycles. At this stage, the new plugin framework has a growing list of well-defined extension points. It's time for the community to begin leveraging those extension points to add functionality to Spinnaker, and to explore development of new extension points.

## Intro to plugins assignment at Spinnaker Gardening Days

To jump into Spinnaker plugins, start by creating a custom separate stage plugin. This will help you become familiar with using the framework. For your first plugin project, we recommend that you leverage the new SimpleStage extension point to add your custom pipeline stage to Spinnaker. Read more in the [Plugin Creators Guide](https://www.spinnaker.io/guides/developer/plugin-creators/).

__Consult these guides to get started. Check this page for more plugin training videos, to be added soon!__

### <a href="https://youtu.be/b7BmMY1kR10" target="_blank">How to build a Plugin: Creating a Spinnaker-native custom stage (16m 55s)</a>

<iframe width="560" height="315" src="https://www.youtube.com/embed/b7BmMY1kR10" frameborder="0" allowfullscreen></iframe>

_The Spinnaker plugin framework leverages PF4J. This video focuses on extending functionality via stable, well-defined extension points. We’ll use the Orca stage extension point to add an example custom stage that waits a random amount of time as part of a Spinnaker pipeline. We’ll show how to set up IntelliJ to debug plugins._

### <a href="https://www.youtube.com/u9NVlG58NYo" target="_blank">How to build a Plugin: Building the frontend for a Spinnaker-native custom stage (8m 56s)</a>

<iframe width="560" height="315" src="https://www.youtube.com/embed/u9NVlG58NYo" frameborder="0" allowfullscreen></iframe>

_This video focuses on creating a presentation layer for Deck using TypeScript and React. We’ll discuss the frontend-backend interaction in a Spinnaker plugin and demonstrate what a native custom stage looks like in the Spinnaker UI._
