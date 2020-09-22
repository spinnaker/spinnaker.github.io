---
layout: single
title:  "Configure Spinnaker's Usage of Redis"
sidebar:
  nav: setup
---

{% include toc %}

Spinnaker relies on its Redis cache for a number of reasons: caching
infrastructure, storing live executions, returning pipeline definitions faster,
etc... Most of these can be configured to your needs, whether it is to make
Spinnaker more responsive, or reduce the load on a downstream dependency.

## Configure infrastructure caching

By default, Spinnaker's Clouddriver service spawns "caching agents" every
30 seconds. These agents are scheduled and coordinated across all instances of
Clouddriver, allowing you to reduce the load on any single instance of
Clouddriver by creating more replicas of the service.

To adjust how this caching happens, Clouddriver exposes a few properties that
can be set in `~/.hal/$DEPLOYMENT/profiles/clouddriver-local.yml`:

```yaml
# How many seconds (default 30s) between runs of agent. Lowering this number
# means the resources in the Spinnaker UI will be updated more frequently,
# at the cost higher API/quota usage of your cloud provider.
redis.poll.intervalSeconds:


# How many seconds (default 300s, 5 minutes) Clouddriver will wait to reschedule
# an agent that never completes (never throws an error or returns cache data).
# If your agents are taking a long time to complete their cache cycles
# successfully and Clouddriver is prematurely rescheduling them, you can try to
# raise this number.
redis.poll.timeoutSeconds:
```

> `$DEPLOYMENT` is typically `default`. See [the
> documentation](/reference/halyard#deployments) for more details.

## Configure pipeline cleanup

If you see that your Redis memory usage is growing unbounded, it's probably
because the orchestration engine stores all pipeline executions forever by
default. This can be configured by setting the following properties in
`~/.hal/$DEPLOYMENT/profiles/orca-local.yml`:

```yaml
pollers:
  oldPipelineCleanup:
    enabled: true                  # This enables old pipeline execution cleanup (default: false)
    intervalMs: 3600000            # How many milliseconds between pipeline cleanup runs (default: 1hr or 3600000)
    thresholdDays: 30              # How old a pipeline execution must be to be deleted (default: 30)
    minimumPipelineExecutions: 5   # How many executions to keep around (default: 5)

tasks:
  daysOfExecutionHistory: 180      # How many days to keep old task executions around.
```

> `$DEPLOYMENT` is typically `default`. See [the
> documentation](/reference/halyard#deployments) for more details.
