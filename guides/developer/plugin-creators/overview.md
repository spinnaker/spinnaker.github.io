---
layout: single
title: "Overview"
sidebar:
  nav: guides
redirect-from:
  - /guides/developer/plugin-creators/
---

{% include alpha version="1.19.4" %}


{% include toc %}


# Requirements

* Spinnaker v1.19.4+
* Halyard 1.34+

# Taxonomy

**Extension Point**: Defined by a Spinnaker service, it represents an official contract for which extensions can be written against. Defined by using an `org.pf4j.ExtensionPoint` interface. Written by Core Contributors.

**Extension**: A piece of code that implements an Extension Point. Written by Developers.

**Plugin**: A collection of Extensions that can be bundled together and shipped as a single artifact. Also written by Developers.

# Plugin overview

A plugin enables an operator to extend Spinnaker with custom functionality. Use cases include fetching credentials from a custom authorization service, adding a wait stage to a pipeline, updating a Jira ticket, and sending Echo events to third-party tools.

# ExtensionPoint plugins

Spinnaker uses the [Plugin Framework for Java (PF4J)](https://github.com/pf4j/pf4j) to indicate an _extension point_ interface to a service. You can create a plugin that implements the methods declared in an extension point.  Creating a plugin based on an extension point has a number of advantages:

* It's the easiest - use the `@Extension` annotation and implement the methods declared in your chosen extension point
* Spinnaker loads the plugin in an isolated classpath
* It has the least amount of maintenance work
* Updates to Spinnaker are not likely to break your plugin

## Finding an extension point

An extension point is an interface that extends `org.pf4j.ExtensionPoint` and is located in the `api` module of a service. Spinnaker exposes the following extension points:

* Orca
  - [SimpleStage](https://github.com/spinnaker/orca/blob/ab89a0d7f847205ccd62e70f8a714040a8621ee7/orca-api/src/main/java/com/netflix/spinnaker/orca/api/SimpleStage.java) for creating a custom pipeline stage
  - [PreconfiguredJobConfigurationProvider](https://github.com/spinnaker/orca/blob/master/orca-api/src/main/java/com/netflix/spinnaker/orca/api/preconfigured/jobs/PreconfiguredJobConfigurationProvider.java) for provisioning preconfigured Job stages

* Echo
  - [EventListener](https://github.com/spinnaker/echo/blob/master/echo-api/src/main/java/com/netflix/spinnaker/echo/api/events/EventListener.java) for processing events posted into Echo

Look through the code or ask in the [Spinnaker Slack](https://join.spinnaker.io/) to find extension points not listed here.

## Example ExtensionPoint plugin

The [pf4jStagePlugin](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin) creates a custom pipeline stage that waits a specified number of seconds before signaling success. Consult the [Pipeline Stage Plugin Walkthrough](/guides/developer/plugin-creators/stage-plugin-walkthrough/) for a detailed explanation of this plugin.

# Interface (Non-ExtensionPoint) plugins

The second way you can create a plugin is to implement a regular Java interface that you find in a service. Your plugin uses the PF4J `@Extension` annotation but does not extend `org.pf4j.ExtensionPoint`.    

Advantages:
* Spinnaker loads the plugin in an isolated classpath

Disadvantages:
* Requires a moderate knowledge of Spinnaker's architecture and code
* Plugin can break if the service's interface changes

## Example Interface plugin

The [pf4jPluginWithoutExtensionPoint](https://github.com/spinnaker-plugin-examples/pf4jPluginWithoutExtensionPoint) plugin extends the functionality of Kork's [SecretEngine](https://github.com/spinnaker/kork/blob/5c5bf12a54ca840b7c6c9f4a57cf3c445ddd910e/kork-secrets/src/main/java/com/netflix/spinnaker/kork/secrets/SecretEngine.java). SecretEngine is a regular Java interface that does not import any PF4J classes. pf4jPluginWithoutExtensionPoint's SillySecretEngine implements SecretEngine and uses the `@Extension` annotation to identify itself as a PF4J plugin. See the plugin project's [README](https://github.com/spinnaker-plugin-examples/pf4jPluginWithoutExtensionPoint) and code for details on how this plugin works.

# Spring plugins

When you can't find an `org.pf4j.ExtensionPoint` to use or a Java interface to implement, you can create a plugin using Spring. This is should be done as a last resort, since the disadvantages outweigh the advantages.

Advantages:

* Full control

Disadvantages:

* Requires an expert knowledge of Spinnaker's architecture and codebase
* Requires working knowledge of Spring
* High maintenance; plugin can break when Spinnaker dependencies and functionality change


## Example Spring plugin

The Spring Example Plugin does not use a PF4J extension point or dependencies. It uses Spring components and was created to test various use cases. See the [project](https://github.com/spinnaker-plugin-examples/springExamplePlugin) for details.
