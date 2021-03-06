---
layout: single
title: "Plugins Overview"
sidebar:
  nav: guides
redirect-from:
  - /guides/developer/plugin-creators/
  - /guides/developer/plugin-creators/overview/
  - /guides/developer/plugins/
  - /guides/developer/plugin-core-developers/
  - /guides/developer/plugin-core-developers/getting-started/
---

Plugins enable operators to extend Spinnaker with custom functionality. Use
cases include fetching credentials from a custom authorization service, adding
a wait stage to a pipeline, updating a Jira ticket, and sending Echo events to
third-party tools.

The goal of this guide is to help with the core services side of plugin
development: Understanding how plugins work, and how to create new extension
points for plugin developers to use.

> Plugins are available in Spinnaker `1.20.6` and higher, configured with
> Halyard `1.36` and higher.

{% include toc %}

# Motivation

Spinnaker was originally written with extensibility in mind. Netflix
wrote huge amounts of custom code atop OSS Spinnaker, decorating existing
functionality or replacing entire areas to suit their needs. This was done either
by consuming the OSS projects as libraries and laying custom code on top, or
wiring it together via Spring configuration (or something else in Deck-land).

This is well and good, but by making the method of extension application
configuration classes, the contract for extensions is essentially the entire
codebase. Good for getting things done fast, but bad for creating clear domain
contracts, which leads to a mixing of core service code and integrations. Over
time, this extension pattern manifests itself in making the core services
heavy and difficult to maintain.

Realizing this, Netflix started an early initiative called [*Lean Core, Fat
Ecosystem*](https://docs.google.com/document/d/1cgKBdT5xVFvMwut7Wji_-bC_12GoQtyZ2MQ958LDcOY/edit?usp=sharing).
Plugins were the first major manifestation of this initiative: To take the
already-built functionality in Spinnaker and start breaking it out into
composable, separately distributable binaries.

# Terminology

- **Extension Point**
    - An interface defined by one of the Spinnaker services for adding specific
      functionality.
- **Extension**
    - An implementation of an **Extension Point**.
- **Plugin**
    - A collection of **Extensions** for a single Spinnaker service.
- **Bundle**
    - A collection of related **Plugins** that span Spinnaker services making
      up a complete feature.
- **SDK**
    - Libraries offered by the plugin framework and Spinnaker services to
      assist common use cases.
- **TCK**
    - Test harnesses and utilities to help plugin developers assert Extension
      functionality.

# What Should Be An Extension Point?

Extension points should be made at intersections between a service's core
functionality and what it considers an integration. An integration is value
added to a service, but not value that impacts the core functionality offerings
of the service: The differentiator is that a service cannot function without
its core functionality, whereas an integration, as critical as it may be for a
particular configuration of that service, is ultimately optional.

Let's take [Orca](https://github.com/spinnaker/orca) as an example: Individual
Pipeline Stages and SpEL Functions are two integrations. Service code that
enables the use of Stages, such as the pipeline engine itself, is a core
feature that isn't an extension point.

When we look at a service under the lens of *Lean Core, Fat Ecosystem*, we want
to have stable core services that only change for the purpose of enabling or
fixing core functionality. Most service deployments for Spinnaker today are for
integrations.

So, for a Spinnaker service, if there is an integration, it should be enabled
by one or more Extension Points. Going back to the Orca Stage example, a Stage
is actually comprised of multiple Extension Points: There is `Task`, which is
responsible for performing a small, discrete action, as well as
`StageDefinitionBuilder`, which is responsible for defining how various `Task`
classes interact with each other, and when.

Extension Points should be small and composable and, when used in concert with
each other, enable larger value for Spinnaker than the sum of its parts.

# Plugin Types

## Frontend (Deck) Plugins

Frontend plugins provide a way to change the behavior of Deck, Spinnaker's UI
service. You can add configuration and validation for new stages provided by
Orca plugins, override existing components with your own implementation, or add
new Kind definitions for custom resources in your environment.

Plugins are written in any Javascript compatible language (Typescript included),
and are loaded at runtime through Gate.

The following are examples of extension points that can be overriden:

  - [ApplicationIcon], replacing the icon used to represent applications in Deck
  - [ServerGroupHeader], replacing how pod status is reported in Deck
  - [SpinnakerHeader], allowing you to override replace the top navigation header

See the [Frontend Plugin Development]({% link guides/developer/plugins/frontend.md %}) guide for more information.

[ApplicationIcon]: https://github.com/spinnaker/deck/blob/master/app/scripts/modules/core/src/application/ApplicationIcon.tsx
[SpinnakerHeader]: https://github.com/spinnaker/deck/blob/master/app/scripts/modules/core/src/header/SpinnakerHeader.tsx
[ServerGroupHeader]: https://github.com/spinnaker/deck/blob/master/app/scripts/modules/core/src/serverGroup/ServerGroupHeader.tsx

## ExtensionPoint Plugins

Spinnaker uses the [Plugin Framework for Java
(PF4J)](https://github.com/pf4j/pf4j) to indicate an _extension point_
interface to a service. You can create a plugin that implements the methods
declared in an extension point.  Creating a plugin based on an extension point
has a number of advantages:

* It's the easiest - use the `@Extension` annotation and implement the methods
  declared in your chosen extension point
* Spinnaker loads the plugin in an isolated classpath
* It has the least amount of maintenance work
* Updates to Spinnaker are not likely to break your plugin

### Finding an extension point

An extension point is an interface that extends `org.pf4j.ExtensionPoint` and
is located in the `api` module of a service. The following list provides a
sample of what these extension points look like in Orca and Echo:

* Orca
  - [StageDefinitionBuilder](https://github.com/spinnaker/orca/blob/master/orca-api/src/main/java/com/netflix/spinnaker/orca/api/pipeline/graph/StageDefinitionBuilder.java) for creating a custom pipeline stage
  - [Task](https://github.com/spinnaker/orca/blob/master/orca-api/src/main/java/com/netflix/spinnaker/orca/api/pipeline/Task.java) for creating a custom pipeline task to use in a custom pipeline stage
  - [PreconfiguredJobConfigurationProvider](https://github.com/spinnaker/orca/blob/master/orca-api/src/main/java/com/netflix/spinnaker/orca/api/preconfigured/jobs/PreconfiguredJobConfigurationProvider.java) for provisioning preconfigured Job stages

* Echo
  - [EventListener](https://github.com/spinnaker/echo/blob/master/echo-api/src/main/java/com/netflix/spinnaker/echo/api/events/EventListener.java) for processing events posted into Echo

### Example ExtensionPoint Plugin

The [pf4jStagePlugin](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin) creates a custom pipeline stage that waits a specified number of seconds before signaling success. Consult the [Test a Pipeline Stage Plugin](/guides/developer/plugin-creators/deck-plugin/) guide for how to test this plugin using a local Spinnaker environment.

## Interface Plugins

The second way you can create a plugin is to implement a regular Java interface
that you find in a service. Your plugin uses the PF4J `@Extension` annotation
but does not extend `org.pf4j.ExtensionPoint`.    

Advantages:
* Spinnaker loads the plugin in an isolated classpath

Disadvantages:
* Requires a moderate knowledge of Spinnaker's architecture and code
* Plugin can break if the service's interface changes

### Example Interface Plugin

The [pf4jPluginWithoutExtensionPoint](https://github.com/spinnaker-plugin-examples/pf4jPluginWithoutExtensionPoint) plugin extends the functionality of Kork's [SecretEngine](https://github.com/spinnaker/kork/blob/5c5bf12a54ca840b7c6c9f4a57cf3c445ddd910e/kork-secrets/src/main/java/com/netflix/spinnaker/kork/secrets/SecretEngine.java). SecretEngine is a regular Java interface that does not import any PF4J classes. pf4jPluginWithoutExtensionPoint's SillySecretEngine implements SecretEngine and uses the `@Extension` annotation to identify itself as a PF4J plugin. See the plugin project's [README](https://github.com/spinnaker-plugin-examples/pf4jPluginWithoutExtensionPoint) and code for details on how this plugin works.

## Spring Plugins

When you can't find an `org.pf4j.ExtensionPoint` to use or a Java interface to
implement, you can create a plugin using Spring. This is should be done as a
last resort, since the disadvantages outweigh the advantages.

Advantages:

* Full control

Disadvantages:

* Requires an expert knowledge of Spinnaker's architecture and codebase
* Requires working knowledge of Spring
* High maintenance; plugin can break when Spinnaker dependencies and functionality change


### Example Spring Plugin

The Spring Example Plugin does not use a PF4J extension point or dependencies.
It uses Spring components and was created to test various use cases. See the
[project](https://github.com/spinnaker-plugin-examples/springExamplePlugin) for
details.
