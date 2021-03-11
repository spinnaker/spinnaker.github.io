---
layout: single
title:  "Orca: Zombie Executions"
sidebar:
  nav: guides
---

{% include toc %}

Aliases: `orphaned execution`

A zombie Execution is one that has a status in the database of RUNNING but there are no messages in Orca's work queue or unacked set—the pipeline or task is not doing anything.

# Diagnosis

Logs will be emitted regularly for Executions that are currently running in Orca via the `QueueProcessor` class, which will look similar to the following example.
If no logs have been emitted for over 10 minutes for a `RUNNING` Execution, it is very likely a zombie.

```
Received message RunTask(executionType=pipeline, executionId=01CT1ST3MBJ9ECPH5JM5HVJARE, application=myapplication, stageId=01CT1ST4P79Y3MPW6FC4H38N3A, taskId=8, taskType=class com.netflix.spinnaker.orca.clouddriver.tasks.instance.WaitForUpInstancesTask)
```

## Metrics & Alerting

Orca can be configured to detect and emit metrics for zombie Executions.
This setting is expensive with the `RedisExecutionRepository` and is disabled by default.
You can enable this detection by setting `queue.zombieCheck.enabled: true` in your Orca configuration.

When enabled, any discovered zombies will be logged out, as well as emitted via a metric:

```
Found zombie executionType=pipeline application=myapplication executionName=myexample executionId=01CS076X85RX6MWBTQ0VGBF8VX
```

If you've enabled the zombie check, set an alert on the metric `queue.zombies`, triggering whenever there is a count greater than 0.

# Remediation


```
POST /admin/queue/zombies/{executionId}:kill
```

There is also a blanket kill command, which takes a `minimumActivity` [Duration](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/time/Duration.html) query parameter (e.g. `PT1H` for 1 hour, the default).
This command should be used with caution, as zombie detection can result in false positives. There is no risk in letting a zombie live, so be safe! 
It is not recommended to use a `minimumActivity` value less than 1 hour.

```
POST /admin/queue/zombies:kill?minimumActivity=PT1H
```

## Known Causes

Zombie Executions can occur due to a loss of the Redis instance backing the Orca queue, or in prolonged unreliable networks.
If you're using the `RedisExecutionRepository`, it's likely that when you lose the Redis backing the queue, you're also losing all running Executions.
However, while using the [SQL backend for Orca](/setup/productionize/persistence/orca-sql/), losing the Redis means you're only losing the in-flight work queue state, not the state of the pipelines.
In such a scenario, once Redis has been restored it will not have any messages to process and existing `RUNNING` Executions will sit unprocessed.
