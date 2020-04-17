---
layout: single
title:  "Horizontally Scale Spinnaker Services"
sidebar:
  nav: setup
---

You can improve Spinnaker's performance and reliability by scaling its
microservces. This page will explain under which circumstances it can help to
run more than one copy of any single service, and what considerations have to
be made when doing so.

This article assumes you have access to scale the individual Spinnaker
microservices, and the mechanics of this are not covered here.

> Keep in mind, if you are deploying Spinnaker to Kubernetes, you're more
> likely to see benefits of horizontal scaling if you've already allocated
> resource [requests & limits](/reference/halyard/component-sizing) for the
> services being scaled.

## Scaling Clouddriver

Clouddriver is responsible for caching and retrieving infrastructure, and
submitting operations to your cloud provider. The former can be quite resource
intensive, and if you see that calls to

* load cloud infrastructure (e.g. load balancers),
* perform cache updates (e.g. force cache refresh),
* search for specific resources (e.g. via the /search endpoint)

are slowing down, it can help to add more replicas of the Clouddriver service.

For a more technical explanation: every copy of Clouddriver tries to (on a
fixed interval) acquire locks to cache as many shards of your infrastructure as
possible. The way the shards are partitioned depends on your cloud
provider, and can be inferred from log statements. For example, a GCE
provider's caching agents will write:

```
GoogleInfrastructureProvider:my-google-account/europe-west1/GoogleRegionalAddressCachingAgent completed in 0.111s
```

This indicates that the agent is responsible for a single account, region,
and resource type.

In addition, as more nodes of Clouddriver are added, the number of reads
forwarded from Gate are more evenly distributed as well.

## Scaling Orca

Orca is Spinnaker's execution engine, and manages running pipelines by
forwarding and waiting for the status of various tasks requested in a pipeline.
Central to Orca's orchestration is a message queue, written into Redis and
shared among all Orca nodes. This is explained in more detail [in this post on
monitoring
Spinnaker](https://blog.spinnaker.io/monitoring-spinnaker-part-1-4847f42a3abd)
for the curious.

If you see slowdowns in some of Spinnaker's operations, such as...

* creating applications,
* running pipelines,
* submitting ad-hoc operations (clone, resize, rollback)

...it's likely because Orca is having trouble processing messages from this
queue. One key metric to look at is `queue.ready.depth`, which is the count of
messages that can be processed, but haven't been (likely because your Orca
nodes are overworked). These messages are in the 'ready' state. Adding more
nodes is a quick remediation, and should make Spinnaker more responsive.

To track how long it's taking for your messages to be handled while they're in
this 'ready' state , the key metric
to look at is `queue.message.lag`, and should be closely tracked by your Spinnaker
operator. Ideally this number should average below a few hundred millisconds.
