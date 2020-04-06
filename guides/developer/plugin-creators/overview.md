---
layout: single
title: "Overview"
sidebar:
  nav: guides
---

{% include toc %}

<div class="notice--danger">
  <strong>Note:</strong> Plugins are an alpha feature that is under active development and may change.
</div>


# Requirements

* Spinnaker v1.19.0
* Halyard 1.32

# Plugin overview

A plugin enables an operator to extend Spinnaker with custom functionality. Use cases include fetching credentials from a custom authorization service, adding a wait stage to a pipeline, updating a Jira ticket, and sending Echo events to third-party tools.

You can extend Spinnaker functionality with three types of plugins: ExtensionPoint, Interface (Non-ExtensionPoint), and Spring.

# ExtensionPoint plugins

Spinnaker uses the [Plugin Framework for Java (PF4J)](https://github.com/pf4j/pf4j) to indicate an _extension point_ interface to a service. You can create a plugin that implements the methods declared in an extension point.  Creating a plugin based on an extension point has a number of advantages:

* It's the easiest - use the `@Extension` annotation and implement the methods declared in your chosen extension point
* Spinnaker loads the plugin in an isolated classpath
* It has the least amount of maintenance work; updates to Spinnaker are not likely to break your plugin

## Finding an extension point

An extension point is an interface that extends `org.pf4j.ExtensionPoint` and is located in the `api` module of a service. Spinnaker exposes the following extension points:

* Orca
  - [SimpleStage](OrcaSimpleStage) for creating a custom pipeline stage
  - [PreconfiguredJobConfigurationProvider](OrcaPreconfiguredJobConfigurationProvider) for provisioning preconfigured Job stages

* Echo
  - [EventListener](EchoEventListener) for processing events posted into Echo

Look through the code or ask in the Spinnaker Slack to find extension points not listed here.

## Example ExtensionPoint plugin

The [pf4jStagePlugin](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin) creates a custom pipeline stage that waits a specified number of seconds before signaling success. Consult the [ExtensionPoint plugin walkthrough] for a detailed explanation of this plugin.

# Interface (Non-ExtensionPoint) plugins

The second way you can create a plugin is to implement a regular Java interface that you find in a service. Your plugin uses the PF4J `@Extension` annotation but does not extend a PF4J extension point.    

Advantages:
* Spinnaker loads the plugin in classpath isolation

Disadvantages:
* Requires a moderate knowledge of Spinnaker's architecture and code
* Plugin can break if the service's interface changes

## Example Interface plugin

The [pf4jPluginWithoutExtensionPoint] plugin extends the functionality of Kork's [SecretEngine](KorkSecretEngine). SecretEngine is a regular Java interface that does not import any PF4J classes. pf4jPluginWithoutExtensionPoint's SillySecretEngine implements SecretEngine and uses the `@Extension` annotation to identify itself as a PF4J plugin. See the plugin project's [README](pf4jPluginWithoutExtensionPoint) and code for details on how this plugin works.

# Spring plugins

When you can't find an ExtensionPoint to use or a Java interface to implement, you can create a plugin using Spring. This is should be done as a last resort, since the disadvantages outweigh the advantages.

Advantages:

* Full control

Disadvantages:

* Requires an expert knowledge of Spinnaker's architecture and codebase
* Requires working knowledge of Spring
* High maintenance; plugin can break when Spinnaker dependencies and functionality change


## Example Spring plugin

The [springExamplePlugin] does what??




[OrcaSimpleStage]: https://github.com/spinnaker/orca/blob/ab89a0d7f847205ccd62e70f8a714040a8621ee7/orca-api/src/main/java/com/netflix/spinnaker/orca/api/SimpleStage.java
[OrcaPreconfiguredJobConfigurationProvider]: https://github.com/spinnaker/orca/blob/master/orca-api/src/main/java/com/netflix/spinnaker/orca/api/preconfigured/jobs/PreconfiguredJobConfigurationProvider.java
[EchoEventListener]: https://github.com/spinnaker/echo/blob/master/echo-api/src/main/java/com/netflix/spinnaker/echo/api/events/EventListener.java
[pf4jPluginWithoutExtensionPoint]: https://github.com/spinnaker-plugin-examples/pf4jPluginWithoutExtensionPoint
[KorkSecretEngine]: https://github.com/spinnaker/kork/blob/5c5bf12a54ca840b7c6c9f4a57cf3c445ddd910e/kork-secrets/src/main/java/com/netflix/spinnaker/kork/secrets/SecretEngine.java
[springExamplePlugin]: [https://github.com/spinnaker-plugin-examples/springExamplePlugin]
