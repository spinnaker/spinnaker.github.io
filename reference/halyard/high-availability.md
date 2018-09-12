---
layout: single
title:  "High Availability"
sidebar:
  nav: reference
---

{% include toc %}

This page describes how you can configure a Halyard deployment to increase the availability of specific services beyond simply [horizontally scaling](/setup/productionize/scaling/horizontal-scaling/) the service. Halyard does this by splitting the functionalities of a service into separate logical roles. The benefits of doing this is specific to the service that is being split. These deployment strategies are inspired by [Netflix's large scale experience](https://blog.spinnaker.io/scaling-spinnaker-at-netflix-part-1-8a5ae51ee6de).

When split, the new logical services are given new names. This means that these logical services can be configured and scaled independently of each other.

__Important:__ Please note that Halyard only supports this functionality for a [distributed Spinnaker deployment](/setup/install/environment/#distributed-installation) configured with a [manifest based Kubernetes account](/setup/install/providers/kubernetes-v2/).

## HA Clouddriver

Clouddriver benefits greatly from isolating its operations into separate services. To split Clouddriver for increased availability, run:

```hal config deploy ha clouddriver enable```

When Spinnaker is deployed with this flag enabled, Clouddriver will be deployed as three different services, each only performing a subset of the base Clouddriver's operations. Although by default the three Clouddriver services will communicate with the global Redis (all Spinnaker services speak to this Redis) provided by Halyard, it is recommended that the logical Clouddriver services be configured to communicate with an external Redis service. To be most effective, the Clouddriver-Read-Only should be configured to speak to a Redis read replica, while the other two should be configured to speak to the master. This is handled by automatically by Halyard if the user provides the two endpoints using this command:

```hal config deploy ha services clouddriver edit --redis-master-endpoint $REDIS_MASTER_ENDPOINT --redis-slave-endpoint $REDIS_SLAVE_ENDPOINT```

More information on Redis replication can be [found here](https://redis.io/topics/replication).

### Clouddriver-Caching

The first of the three logical Clouddriver services is the Clouddriver-Caching service, or `clouddriver-caching`. This service is responsible for the caching and retrieving of cloud infrastructure data. Since this is all that the Clouddriver-Caching is doing, there is no communication between this service and any other Spinnaker service.

This service's name when [configuring its sizing](/reference/halyard/component-sizing/) is `spin-clouddriver-caching`.

To add a [custom profile](/reference/halyard/custom/#custom-profiles) or [custom service settings](/reference/halyard/custom/#custom-service-settings) for this service, use the name `clouddriver-caching`.

### Clouddriver-Read-Write

The second logical Clouddriver service is the Clouddriver-Read-Write service, or `clouddriver-rw`. This service handles all mutating operations aside from what the Clouddriver-Caching service does. This service can be scaled to handle an increased number of writes.

This service's name when [configuring its sizing](/reference/halyard/component-sizing/) is `spin-clouddriver-rw`.

To add a [custom profile](/reference/halyard/custom/#custom-profiles) or [custom service settings](/reference/halyard/custom/#custom-service-settings) for this service, use the name `clouddriver-rw`.

### Clouddriver-Read-Only

The Clouddriver-Read-Only service, or `clouddriver-ro` handles all read requests to Clouddriver. This service can be scaled to handle an increased number of reads.

This service's name when [configuring its sizing](/reference/halyard/component-sizing/) is `spin-clouddriver-ro`.

To add a [custom profile](/reference/halyard/custom/#custom-profiles) or [custom service settings](/reference/halyard/custom/#custom-service-settings) for this service, use the name `clouddriver-ro`.

## HA Echo

Echo can be split into two separate services that handle different operations. To split Echo for increased availability, run:

```hal config deploy ha echo enable```

When Spinnaker is deployed with this enabled, Echo will be deploy as two different services, one that handles Echo's scheduled cron-jobs and one that handles everything else. Although the logical Echo services still cannot be horizontally scaled, splitting the services will reduce the load on both.

### Echo-Scheduler

The Echo-Scheduler service or `echo-scheduler` handles scheduled tasks, or cron-jobs. Since it performs its tasks periodically (no triggers) there is no need for communication with other Spinnaker services.

This service's name when [configuring its sizing](/reference/halyard/component-sizing/) is `spin-echo-scheduler`. To avoid duplicate triggering, this service must be deployed with exactly one pod.

To add a [custom profile](/reference/halyard/custom/#custom-profiles) or [custom service settings](/reference/halyard/custom/#custom-service-settings) for this service, use the name `echo-scheduler`.

### Echo-Slave

The Echo-Slave service or `echo-slave` handles all operations of Echo besides the cron-jobs.

This service's name when [configuring its sizing](/reference/halyard/component-sizing/) is `spin-echo-slave`. To avoid duplicate triggering, this service must be deployed with exactly one pod.

To add a [custom profile](/reference/halyard/custom/#custom-profiles) or [custom service settings](/reference/halyard/custom/#custom-service-settings) for this service, use the name `echo-slave`.

## HA Topology

With all services enabled for high availability, the new architecture looks like this:

 <div class="mermaid">
 graph TB

 deck(Deck) --> gate;
 api(Custom Script/API Caller) --> gate(Gate);
 gate --> kayenta(Kayenta);
 gate --> orca(Orca);
 gate --> clouddriver-ro(Clouddriver-Read-Only);
 orca --> clouddriver-rw(Clouddriver-Read-Write);
 gate --> rosco(Rosco);
 orca --> front50;
 orca --> rosco;
 gate --> front50(Front50);
 gate --> fiat(Fiat);
 orca --> kayenta;
 clouddriver-ro --> fiat;
 clouddriver-rw --> fiat;
 orca --> fiat;
 front50 --> fiat;
 echo-slave(Echo-Slave) --> orca;
 echo-slave --> front50;
 igor(Igor) --> echo-slave;
 clouddriver-caching(Clouddriver-Caching);
 echo-scheduler(Echo-Scheduler);

 classDef default fill:#d8e8ec,stroke:#39546a;
 linkStyle default stroke:#39546a,stroke-width:1px,fill:none;

 classDef external fill:#c0d89d,stroke:#39546a;
 class deck,api external

 classDef split fill:#42f4c2,stroke:#39546a;
 class clouddriver-caching,clouddriver-ro,clouddriver-rw,echo-scheduler,echo-slave split
 </div>

 {% include mermaid %}


