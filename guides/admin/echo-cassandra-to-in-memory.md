---
layout: single
title:  "Echo: Cassandra to In-Memory"
sidebar:
  nav: guides
redirect_from: /docs/echo-cassandra-to-in-memory
---

{% include toc %}

Echo's scheduler can be run completely in-memory. On startup or redeploy, echo will check cron schedules to see if it needs to retroactively execute any missed triggers. This migration only requires configuration changes.

## 1. Disable Cassandra in echo.yml

```
spinnaker:
  cassandra:
    enabled: false
```

## 2. Enable in-memory backend in echo.yml

```
spinnaker:
  inMemory:
    enabled: true
```

## 3. Enable the scheduler compensation job in echo.yml

```
scheduler:
  compensationJob:
    enabled: true
    windowMs: 1800000 # optional
```

The `windowMs` property dictates how far in the past echo will look to find missed schedules. By default this is 30 minutes.

## 4. Deploy new Echo
