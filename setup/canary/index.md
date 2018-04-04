---
layout: single
title:  "Set up canary support"
sidebar:
  nav: setup
---

All setup for automated canary analysis in Spinnaker is done using Halyard
commands.
[Here's a reference](/reference/halyard/commands/#hal-config-canary) for this
canary set of Halyard commands.


## Enable/disable canary Analysis

```
hal config canary enable
```

```
hal config canary disable
```

### Options

`--deployment` tells Halyard to use this same Halyard deployment. Does not
create a new deployment.

`--no-validate` skips validation.

## Specify the scope of canary configs

Each [canary configuration](/guides/user/canary/config/) is available to all
pipeline canary stages in all apps, by default. But you can change that so each
canary config is only visible within the app in which it is created:

```
hal config canary edit --show-all-configs-enabled
```

The default for this is `true`, which means that all apps can see (in Deck) and
use all canary configs. Set to false to limit each config to the app in which
it was created.


## Specify location of web components (for Atlas)
If you're using Atlas as your  telemetry provider...

```
hal config canary edit --atlasWebComponentsUrl [url]
```

## Enable canary Analysis


## Enable canary Analysis


## Enable canary Analysis


## Enable canary Analysis


## Enable canary Analysis

## Specify location of web components (for Atlas)
If you're using Atlas as your  telemetry provider...

```
hal config canary edit --atlasWebComponentsUrl [url]
```
