---
layout: single
title:  "Orca: Redis to SQL Migration"
sidebar:
  nav: guides
---

{% include toc %}

If you are not migrating an existing Orca deployment, refer to [Orca SQL Setup](/setup/productionize/persistence/orca-sql/) instead.

## Migrate from Redis to SQL

Migrating without downtime from Redis to SQL is a three-step process:

1. [Deploy Orca with the `DualExecutionRepository` writing to both Redis and SQL.](#enable-dualexecutionrepository)
2. [Deploy a new Orca cluster with migrators enabled and queue processing disabled.](#deploy-a-migration-cluster)
3. [Once all executions have been migrated, delete migration cluster and disable `DualExecutionRepository`.](#disable-dualexecutionrepository)

When `DualExecutionRepository` is running, writes will be routed to either Redis or SQL.
Executions will only be migrated to SQL once they've completed (either successfully or terminally): This keeps the migration story simple.
As such, the migration agents will need to run for awhile. 
At Netflix, we ran the migration cluster for two weeks, as we had long pipeline executions due to canaries. 
You may only need to run the migration cluster for an hour.

**NOTE**: _Deploying the migrators as a separate cluster is optional, however the migration process is memory hungry, so you may need to devote more resources to the Orca process._

### Enable DualExecutionRepository

Building atop the baseline configuration above, add the following to orca.yml:

```yaml
executionRepository:
  dual:
    enabled: true
    primaryName: sqlExecutionRepository
    previousName: redisExecutionRepository
  sql:
    enabled: true
  redis:
    enabled: true
```

Note that both repositories are enabled. Orca will fail to start up if the `DualExecutionRepository` is misconfigured.

### Deploy a Migration Cluster

At Netflix, we deployed `orca-main`, the cluster that serves our production traffic, as well as `orca-main-sqlmigration`, which does not receive API traffic nor process the work queue. It's sole purpose is to shovel bits from Redis to SQL.

To perform a deploy a migration cluster, add the following configuration to `orca.yml`:

```yaml
---
spring:
  profiles: sqlmigration

pollers:
  orchestrationMigrator:
    enabled: true
    intervalMs: 1800000
  pipelineMigrator:
    enabled: true
    intervalMs: 1800000

queue:
  redis:
    enabled: false

keiko:
  queue:
    enabled: false
```

You will need to launch this migration cluster with `-Dspring.profiles.active=sqlmigration`. 
[Spring Profiles](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-profiles.html) allow you to configure a service to startup with different configurations.

### Disable DualExecutionRepository

Once all executions have been migrated, you can deploy Orca once again without `DualExecutionRepository` and delete the migration cluster.

## SQL-specific Metrics

Orca emits a few handfuls of metrics that are specific to SQL.

The `SqlHealthcheckQueueActivator` class, which will disable work queue processing if SQL connectivity goes unhealthy, emits one metric: `sql.queueActivator.invocations` with a tag of `status` (`disabled` or `enabled`).

The `ExecutionRepository` will emit a bunch of invocation and timing metrics with the following patterns:

- `sql.executionRepository.$method.timing`
- `sql.executionRepository.$method.invocations`

If you are using the default HikariCP connection pool:

- `sql.pool.$poolName.connectionAcquiredTiming`
- `sql.pool.$poolName.connectionUsageTiming`
- `sql.pool.$poolName.connectionTimeout`
- `sql.pool.$poolName.idle`
- `sql.pool.$poolName.active`
- `sql.pool.$poolName.total`
- `sql.pool.$poolName.blocked`

If you are using the MariaDB driver extension:

- `sql.pool.$poolName.active`
- `sql.pool.$poolName.idle`
- `sql.pool.$poolName.total`
- `sql.pool.$poolName.blocked`