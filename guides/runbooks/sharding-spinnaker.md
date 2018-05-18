---
layout: single
title:  "Sharding Spinanker"
sidebar:
  nav: guides
---

{% include toc %}

# Intro

This document shows you how to shard traffic to different areas of Spinnaker: 

The general pattern is that you define a selector class in your configuration. The requests will then be propagated to the defined selected shard.

At Netflix, we create read-only shards for clouddriver to better manage requests. Each readonly shard is connected to a Redis replica. 

Selectors exist at these levels:

* Application
* Execution type (i.e, Pipeline vs Orchestration)
* Origin
* Authenticated User

You want to modify your deployment pipelines to ensure the infrastructure for each shard is correctly created. 

If no selector is specified, the default request will be used.

There is a special additional dynamicEndpoints configuration in gate.yml to send all requests from Deck to that particular shard. 

# Sharding Orca Requests

In gate.yml

```
services:
  orca:
    shards:
      baseUrls:
        - baseUrl: https://orca.example.com
        - baseUrl: https://orca-shard1.example.com
          priority: 10
          config:
            selectorClass: com.netflix.spinnaker.kork.web.selector.ByApplicationServiceSelector
            applicationPattern: xxxxyyyapp |demo.*xxxxyyyy
```

# Clouddriver Read-only Shards

gate.yml

```
services:
  clouddriver:
    baseUrl: https://clouddriver-readonly.example.com
    config:
      dynamicEndpoints:
        deck: https://clouddriver-readonly-deck.example.com
```
       
orca.yml

```
clouddriver:
  readonly:
    baseUrls:
    - baseUrl: https://clouddriver-readonly-orca-1.example.com
      priority: 10
      config:
        selectorClass: com.netflix.spinnaker.orca.clouddriver.config.ByExecutionTypeServiceSelector
        executionTypes:
          - orchestration
    - baseUrl: https://clouddriver-readonly-orca-2.example.com
      priority: 20
      config:
        selectorClass: com.netflix.spinnaker.orca.clouddriver.config.ByApplicationServiceSelector
        applicationPattern: app1|.*app2.*
    - baseUrl: https://clouddriver-readonly-orca-3.example.com
      priority: 30
      config:
        selectorClass: com.netflix.spinnaker.orca.clouddriver.config.ByOriginServiceSelector
        origin: deck
        executionTypes:
          - orchestration
    - baseUrl: https://clouddriver-readonly-orca-4.example.com
      priority: 50
      config:
        selectorClass: com.netflix.spinnaker.orca.clouddriver.config.ByAuthenticatedUserServiceSelector
        users:
          - horseman.*
          - bojack.*
    - baseUrl: https://clouddriver-readonly-orca-5.example.com
```
