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

## Rehydrate the Queue

If the Execution is a zombie, there are no messages on the work queue for that Execution.
You can attempt to re-hydrate the queue --- reissue messages onto the work queue based on the last stored state --- using an [admin API in Orca](https://github.com/spinnaker/orca/blob/master/orca-queue/src/main/kotlin/com/netflix/spinnaker/orca/q/admin/web/QueueAdminController.kt#L33), which must be called directly as it is not exposed through Gate.
This command can take either a single execution or operate on all executions within a time range. 
**This command will dry-run by default.**
To actually rehydrate the queue, pass the query parameter `dryRun=false`.

```bash
$ curl -XPOST \
  https://localhost:8083/admin/queue/hydrate?executionId=01CS076X85RX6MWBTQ0VGBF8VX?dryRun=false
```

This command is **best effort** and may not be able to rehydrate the Execution, especially if the Execution was zombied while running a non-retryable task.

An example response from the endpoint:

```json
{
  "dryRun": false,
  "executions": {
    "01CS076X85RX6MWBTQ0VGBF8VX": {
      "startTime": 1538679600852,
      "actions": [
        {
          "description": "Task is running and is retryable",
          "message": {
            "kind": "runTask",
            "executionType": "PIPELINE",
            "executionId": "01CS076X85RX6MWBTQ0VGBF8VX",
            "application": "myapplication",
            "stageId": "01CS076X8501MNAD2ZTJ4ST2TM",
            "taskId": "1",
            "taskType": "com.netflix.spinnaker.orca.echo.pipeline.ManualJudgmentStage$WaitForManualJudgmentTask",
            "attributes": [],
            "ackTimeoutMs": 600000
          },
          "context": {
            "stageId": "01CS076X8501MNAD2ZTJ4ST2TM",
            "stageType": "manualJudgment",
            "stageStartTime": 1538682406227,
            "taskId": "1",
            "taskType": "waitForJudgment",
            "taskStartTime": 1538682406242
          }
        },
        {
          "description": "Task is running but is not retryable",
          "context": {
            "stageId": "01CS076X85ECXHF3FRWZBTQ359",
            "stageType": "createProperty",
            "stageStartTime": 1538681485559,
            "taskId": "3",
            "taskType": "monitorProperties",
            "taskStartTime": 1538681546116
          }
        }
      ],
      "canApply": false
    }
  }
}
```

For each Execution, a final action summary is provided `canApply`. 
If any part of an Execution cannot be re-hydrated, the entire Execution will be skipped.

## Cancel the Execution

If the Execution cannot be rehydrated, it will need to be canceled. 
You can cancel the Execution via the UI or force cancellation via an Orca admin API:

```
PUT /admin/forceCancelExecution?executionId=01CS076X85RX6MWBTQ0VGBF8VX&executionType=PIPELINE
```

## Known Causes

Zombie Executions can occur due to a loss of the Redis instance backing the Orca queue, or in prolonged unreliable networks.
If you're using the `RedisExecutionRepository`, it's likely that when you lose the Redis backing the queue, you're also losing all running Executions.
However, while using the [SQL backend for Orca](/setup/productionize/persistence/orca-sql/), losing the Redis means you're only losing the in-flight work queue state, not the state of the pipelines.
In such a scenario, once Redis has been restored it will not have any messages to process and existing `RUNNING` Executions will sit unprocessed.
