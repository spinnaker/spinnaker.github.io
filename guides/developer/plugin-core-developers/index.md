---
layout: single
title:  "Plugins Guide for Core Contributors"
sidebar:
  nav: guides
---

The goal of this guide is to help with the core services side of plugin development: Understanding how plugins work, and how to create new extension points for plugin developers to use.

> For an introduction into Plugins and its high-level taxonomies, see the [Plugin Guide's Getting Started](https://www.notion.so/netflixdet/Getting-Started-489d6349bc8e486f9390e8d30134db56) page.

## Why?

Spinnaker was originally written with extensibility in mind. We at Netflix wrote huge amounts of custom code atop OSS Spinnaker, decorating existing functionality or replacing entire areas to suit our needs. This was done either by consuming the OSS projects as libraries and laying custom code on-top or wiring it together via Spring configuration (or something else in Deck-land).

This is well and good, but by making the method of extension application configuration classes, the contract for extensions was essentially the entire codebase. Good for getting things done fast, but bad for creating clear domain contracts, which led to a mixing of core service code and integrations. Over time, this extension pattern has manifested itself in making the core services heavy and difficult to maintain.

Realizing this, we started an early initiative called [*Lean Core, Fat Ecosystem*](https://docs.google.com/document/d/1cgKBdT5xVFvMwut7Wji_-bC_12GoQtyZ2MQ958LDcOY/edit?usp=sharing). Plugins were the first major manifestation of this initiative: To take the already-built functionality in Spinnaker and start breaking it out into composable, separately distributable binaries.

## Extension Points

Extension Points are the cornerstone to the Plugins effort. They provide a method of defining contracts between what is considered "core" service code, and integrations built atop that core functionality.

Extension Points can target either in-process or remote invocation targets, or both.

### What should be an Extension Point?

Extension points should be made at intersections between a service's core functionality and what it considers an integration. An integration is value added to a service, but not value that impacts the core functionality offerings of the service: The differentiator is that a service cannot function without its core functionality, whereas an integration, as critical as it may be for a particular configuration of that service, is ultimately optional.

Let's take [Orca](https://github.com/spinnaker/orca) as an example: Individual Pipeline Stages and SpEL Functions are two integrations. Service code that enables the use of Stages, such as the pipeline engine itself, is a core feature that isn't an extension point.

When we look at a service under the lens of *Lean Core, Fat Ecosystem*, we want to have stable core services that only change for the purpose of enabling or fixing core functionality. Most service deployments for Spinnaker today are for integrations.

So, for a Spinnaker service, if there is an integration, it should be enabled by one or more Extension Points. Going back to the Orca Stage example, a Stage is actually comprised of multiple Extension Points: There is `Task`, which is responsible for performing a small, discrete action, as well as `StageDefinitionBuilder`, which is responsible for defining how various `Task` classes interact with each other, and when.

Extension Points should be small and composable and, when used in concert with each other, enable larger value for Spinnaker than the sum of its parts.

## Next

- [Backend Guide](/guides/developer/plugin-core-developers/backend)
- Frontend Guide (TBD)