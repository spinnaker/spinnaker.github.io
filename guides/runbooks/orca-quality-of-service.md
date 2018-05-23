---
layout: single
title:  "Orca Quality of Service"
sidebar:
  nav: guides
---

{% include toc %}

**EXPERIMENTAL**: This feature is still in an early adoption / experimental phase. 
While you can use it today (Orca v6.71.0), Netflix is currently running this in learning mode / judiciously enabling in response to on-call events.

Spinnaker ships with an optional Quality of Service (QoS) module that can be used to manage the amount of active executions running at any given time.
By default, this QoS module is disabled, but can be enabled and tuned with a handful of knobs and different strategies.
Before we dive into the configuration settings, we'll go over how QoS works.

# How QoS Works

The QoS system is self-contained within Orca's [orca-qos][module] module and operates only on newly created executions (both pipeline and orchestrations).
That is to say, the QoS system will _not_ impact running executions: Once an execution has started, it is completely outside of the domain of the QoS module.
The rest of this section assumes that QoS is enabled.

When an execution is submitted to Orca (either manually via the API or UI, or through an automated trigger), Orca will first emit a synchronous `BeforeExecutionPersist` event which the QoS [ExecutionBufferActuator][actuator] is listening on.
The behavior of the `ExecutionBufferActuator` depends firstly on the result of a
[BufferStateSupplier][buffer-state-supplier]. 
The `BufferStateSupplier` can perform whatever heuristics necessary to determine whether or not any new execution should go through the QoS process. 
If the `BufferStateSupplier` returns `false`, no other QoS actions occur and the execution is started as normal.

In the event `BufferStateSupplier` returns `true`, the execution is passed through a chain of ordered [BufferPolicy][buffer-policy] functions.
These `BufferPolicy` functions return a result defining whether or not to `BUFFER` or `ENQUEUE` the execution. 
All `BufferPolicy` functions must return `ENQUEUE`, otherwise the execution will be assigned a status of `BUFFERED`, delaying the initialization of the execution.
When an execution is `BUFFERED`, it will effectively stay in a waiting state until it is unbuffered, which we'll go over later.

`BufferPolicy` functions are pluggable and can contain arbitrary logic. 
For example, one `BufferPolicy` that is always enabled is [EnqueueDeckOrchestrationBufferPolicy][deck-buffer-policy], which will always `ENQUEUE` an execution it is an Orchestration and from the UI. 
This specific policy forces the `ENQUEUE` status, even if other policies call for the execution to be buffered; this is done through a `force` flag that policies can return.
An example of other pluggable behavior is determining buffering action based on criticality of the execution: At Netflix we have a custom concept of application criticality, so we can buffer low criticality executions to allow capacity for higher criticality executions.

Once an execution is put into a `BUFFERED` state, it will remain in that state until the [ExecutionPromoter][promoter] decides to change it to `NOT_STARTED` and enqueue it for processing.
Similar to the `ExecutionBufferActuator`, the `ExecutionPromoter` uses an ordered chain of [PromotionPolicy][promotion-policy] functions to determine what buffered executions to promote.
Every promotion cycle, the list of buffered executions (called candidates) are passed through the policies, each reducing the list of candidates to a final list of executions that will be promoted.
Again, these policies can have arbitrary logic, but by default a naive promotion policy is included that will promote the _N_ oldest executions.
This promotion process happens (by default) on a 5-second interval on every Orca instance.

With both `BufferPolicy` and `PromotionPolicy`, the results of each function returns a result with a human readable "reason", which is logged out for each execution that is evaluated so it is easy to trace.

<div class="mermaid">
    sequenceDiagram
    participant ExecutionPersister
    participant ExecutionBufferActuator
    participant BufferPolicy
    participant ExecutionPromoter
    participant PromotionPolicy
    participant ExecutionLauncher
    ExecutionPersister->>ExecutionBufferActuator: BeforeExecutionPersistEvent
    ExecutionBufferActuator->>BufferPolicy: Execution
    loop Buffer Chain
        BufferPolicy->BufferPolicy: Evaluate if BUFFERED or ENQUEUED
    end
    alt ENQUEUED
        BufferPolicy->>ExecutionLauncher: Start Execution
    else BUFFERED
        Note over BufferPolicy: Set BUFFERED status
    end
    note right of ExecutionPromoter: Every n seconds
    ExecutionPromoter->>PromotionPolicy: All BUFFERED executions "candidates"
    loop PromoteCycle
        PromotionPolicy->PromotionPolicy: Reduce candidates
    end
    PromotionPolicy->>ExecutionPromoter: Final promotion candidates
    loop Promote Executions
        note over ExecutionPromoter: For each promoted execution
        ExecutionPromoter->>ExecutionPersister: Update Execution status to NOT_STARTED
        ExecutionPromoter->>ExecutionLauncher: Start Execution
    end
</div>

**Note**: This is the first implementation of the QoS system, we plan to iterate on this concept and make it more advanced over time.
You can read the [original proposal][proposal] to get an idea of a potential roadmap.

# Configuration

These configurations are not guaranteed to be fully inclusive of all knobs.
A definitive list is available via the codebase.

* `qos.enabled`: Boolean (default `false`). Global flag controlling whether or not the system is enabled. This flag will not disable the `ExecutionPromoter`.
* `qos.learningMode.enabled`: Boolean (default `true`). If enabled, executions will always be `ENQUEUED`, but log messages & metrics will be emitted saying what the system would have done. This flag has no effect on `ExecutionPromoter`.
* `pollers.qos.promoteIntervalMs`: Integer (default `5000`). The time (in milliseconds) that the promotion process will be run.

## BufferPolicy: Naive

The `NaiveBufferPolicy` will always buffer executions when enabled.

* `qos.bufferPolicy.naive.enabled`: Boolean (default `true`).

## BufferStateSupplier: ActiveExecutions

The `ActiveExecutionsBufferStateSupplier` will enable/disable the buffering state based on the number of active executions in the system.

* `qos.bufferingState.supplier` must be set to `activeExecutions`.
* `qos.bufferingState.activeExecutions.threshold`: Integer (default `100`). The high threshold of active executions before QoS will start actuating on executions.
* `pollers.qos.updateStateIntervalMs`: Integer (default `5000`). The time (in milliseconds) that the function will update its internal record for how many executions are running in the system.

## BufferStateSupplier: KillSwitch

The `KillSwitchBufferStateSupplier` will enable/disable the buffering state based on configuration only.
This is handy if you're evaluating the fundamentals of the QoS system, or you want a break-the-glass operator knob to control QoS.

* `qos.bufferingState.supplier` must be set to `killSwitch`.
* `qos.bufferingState.killSwitch.enabled`: Boolean (default `false`). If `true`, QoS will be enabled.

## PromotionPolicy: Naive

The `NaivePromotionPolicy` will promote _N_ executions every promotion cycle.

* `qos.promotionPolicy.naive.enabled`: Boolean (default `true`). Whether or not this policy is enabled.
* `qos.promotionPolicy.naive.size`: Integer (default `1`). The max number of executions to promote.

# Monitoring

* `qos.executionsBuffered`: Counter. The number of executions that have been buffered.
* `qos.executionsEnqueued`: Counter. The number of executions that have been enqueued (e.g. passed through the system and were judged not to be buffered).
* `qos.actuator.elapsedTime`: Timer. The amount of time that is spent passing an execution through all enabled `BufferPolicy`s.
* `qos.promoter.elapsedTime`: Timer. The amount of time that is spent passing an execution through all enabled `PromotionPolicy`s. Since the promoter is run on a static interval, this should usually be a relatively high, yet constant, number.
* `qos.promoter.executionsPromoted`: Counter. The number of executions that have been promoted.

# Additional Notes

The QoS system is currently shared-nothing state. Each Orca instance will maintain its own state (aside from configuration) about whether or not it should be buffering executions, or when it should be running pollers.

{% include mermaid %}

[module]: https://github.com/spinnaker/orca/tree/master/orca-qos
[actuator]: https://github.com/spinnaker/orca/blob/master/orca-qos/src/main/kotlin/com/netflix/spinnaker/orca/qos/ExecutionBufferActuator.kt
[buffer-state-supplier]: https://github.com/spinnaker/orca/blob/master/orca-qos/src/main/kotlin/com/netflix/spinnaker/orca/qos/BufferStateSupplier.kt
[buffer-policy]: https://github.com/spinnaker/orca/blob/master/orca-qos/src/main/kotlin/com/netflix/spinnaker/orca/qos/BufferPolicy.kt
[deck-buffer-policy]: https://github.com/spinnaker/orca/blob/master/orca-qos/src/main/kotlin/com/netflix/spinnaker/orca/qos/bufferpolicy/EnqueueDeckOrchestrationsBufferPolicy.kt
[promoter]: https://github.com/spinnaker/orca/blob/master/orca-qos/src/main/kotlin/com/netflix/spinnaker/orca/qos/ExecutionPromoter.kt
[promotion-policy]: https://github.com/spinnaker/orca/blob/master/orca-qos/src/main/kotlin/com/netflix/spinnaker/orca/qos/PromotionPolicy.kt
[proposal]: https://docs.google.com/document/d/1Kq9PjfhUu2o8Awt0YQyXf7L14X_PUsS81oaW6tjlgVY/edit#
