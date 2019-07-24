---
layout: single
title:  "Set up Clouddriver to use SQL"
sidebar:
  nav: setup
---

{% include toc %}

You can configure Clouddriver to use a MySQL compatible database in place of Redis for all of its persistence use cases. These are:

1. Caching the state of all supported cloud resources and graphing their relationships
2. The cloud operations task repository
3. Distributed locking for the caching agent scheduler

You can also use Redis for one of the above, and SQL for another. A `DualTaskRepository` class is provided to enable online migrations between Redis and SQL in either direction without impact to running pipelines.

This guide covers database and Clouddriver configuration details, as well as tips on how Clouddriver is operated at Netflix.

## Why SQL

Growth in Netflix's infrastructure footprint over time exposed a number of scaling challenges with Clouddriver's original Redis-backed caching implementation. For example, the functional use of unordered Redis sets as secondary indexes incurs linear cost while also making it challenging to shard the keyspace without hotspots. Additionally, Clouddriver's data is highly relational, making it a good candidate for modeling to either relational or graph databases.

Small Spinnaker installations (managing up-to a few thousand instances across all applications) are unlikely to see significant performance or cost gains by running Clouddriver on an RDBMS as opposed to Redis. In the Netflix production environment, we have seen improvements of up to 400% in the time it takes to load the clusters view for large applications (hundreds of server groups with thousands of instances) since migrating from Redis to Aurora. We also see greater consistency in 99th percentile times under peak load and have reduced the number of instances required to operate Clouddriver. Besides improving performance at scale, we believe the SQL implementation is better suited to future growth. We've load tested Clouddriver backed by Aurora with the Netflix Production data set at more than 10x traffic rates, which previously resulted in Redis related outages.

At some point in the future, Spinnaker may drop support for Redis, but today it remains a good choice for evalauating Spinnaker as well as local development.

Note that cache provider classes within Clouddriver may need development to take full advantage of the `SqlCache` provider. The inital release adds secondary indexing by application specifically to accelerate `/applications/{application}/serverGroups` calls made by the UI, but only AWS caching agents and providers initially take advantage of this. Prior to adding application based indexing of AWS resources, Netflix still saw performance and consistency gains using Aurora over Redis. Performance of the SQL cache provider should increase over time as Clouddriver's data access patterns evolve to better utilize features of the underlying storage.

## Configuration Considerations

At Netflix, Orca and Clouddriver run with their own dedicated Aurora cluster but this isn't required. When sizing a database cluster for Clouddriver, make sure the full dataset fits within the InnoDB buffer cache. If migrating an existing Clouddriver installation from Redis to SQL, provisioning database instances with 4x the RAM of the current Redis working set should ensure a fit with room for growth. Much of the additional memory use is accounted for by secondary indexes.

Throughput and write latency are important considerations, especially for Spinnaker installations that manage many accounts and regions. Each distinct `(cloudProvider, account, region, resourceType)` tuple generally gets an independently scheduled caching-agent instance within Clouddriver. The number of these instances per Clouddriver configuration can be considered the upper bound for concurrent write-heavy sessions to the database, if not limited by the `sql.agent.maxConcurrentAgents` property. Caching-agent write throughput can directly impact deployment times, especially in large environments with many accounts or multiple cloud providers. Clouddriver only tries to write new or modified resources to the database however, moderating write requirements after initial population.

## Database Setup

Clouddriver ships with `mysql-connector-java` by default. You can provide additional JDBC connectors on the classpath such as `mariadb-connector-j` if desired. Use of a different RDBMS family will likely require some development effort at this time. Clouddriver was developed targeting Amazon Aurora's MySQL 5.7 compatible engine.

Before you deploy Clouddriver, you need to manually create a logical database and user grants.

```sql
CREATE DATABASE `clouddriver` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

GRANT
  SELECT, INSERT, UPDATE, DELETE, CREATE, EXECUTE, SHOW VIEW
ON `clouddriver`.*
TO 'clouddriver_service'@'%'; -- IDENTIFIED BY "password" if using password based auth

GRANT
  SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, LOCK TABLES, EXECUTE, SHOW VIEW
ON `clouddriver`.*
TO 'clouddriver_migrate'@'%'; -- IDENTIFIED BY "password" if using password based auth
```

The following MySQL configuration parameter is required:

- `tx_isolation` Set to `READ-COMMITTED`

The following MySQL configuration parameter may improve performance for large data sets:

- `tmp_table_size` Increase if the `Created_tmp_disk_tables` MySQL metric regularly grows

## Configure Clouddriver to use MySQL

The following yaml-based parameters provide a Clouddriver configuration that entirely uses MySQL in place of Redis. [Halyard](/reference/halyard/) does not yet natively support Clouddriver SQL configuration. Halyard users can provide these as overrides via a `clouddriver-local.yml` file.

```yaml
sql:
  enabled: true
  taskRepository:
    enabled: true
  cache:
    enabled: true
    # These parameters were determined to be optimal via benchmark comparisons
    # in the Netflix production environment with Aurora. Setting these too low
    # or high may negatively impact performance. These values may be sub-optimal
    # in some environments.
    readBatchSize: 500
    writeBatchSize: 300
  scheduler:
    enabled: true
  connectionPools:
    default:
      # additional connection pool parameters are available here,
      # for more detail and to view defaults, see:
      # https://github.com/spinnaker/kork/blob/master/kork-sql/src/main/kotlin/com/netflix/spinnaker/kork/sql/config/ConnectionPoolProperties.kt
      default: true
      jdbcUrl: jdbc:mysql://your.database:3306/clouddriver
      user: clouddriver_service
      # password: depending on db auth and how spinnaker secrets are managed
    # The following tasks connection pool is optional. At Netflix, clouddriver
    # instances pointed to Aurora read replicas have a tasks pool pointed at the
    # master. Instances where the default pool is pointed to the master omit a
    # separate tasks pool.
    tasks:
      user: clouddriver_service
      jdbcUrl: jdbc:mysql://your.database:3306/clouddriver
  migration:
    user: clouddriver_migrate
    jdbcUrl: jdbc:mysql://your.database:3306/clouddriver

redis:
  enabled: false
  cache:
    enabled: false
  scheduler:
    enabled: false
  taskRepository:
    enabled: false
```

### Agent Scheduling

The above yaml configures Clouddriver to use a MySQL table as part of a locking service for the caching agent scheduler. This works well for Netflix in production against Aurora, but could result in poor overall performance for all of Clouddriver, depending on how your database is configured. If you observe high database CPU utilization, lock contention, or if caching agents aren't consistently running at the expected frequency, you may want to try using the Redis-based scheduler to determine if this is a contributing factor.

The following modification to the above example configures Clouddriver to use SQL for the cache and task repository, and Redis for agent scheduling.

**IMPORTANT NOTE FOR GOOGLE CLOUDSQL USERS**: The SQL Agent Scheduler does not work in CloudSQL. You must continue to use the Redis scheduler for now.

```yaml
sql:
  scheduler:
    enabled: false

redis:
  enabled: true
  connection: redis://your.redis
  cache:
    enabled: false
  scheduler:
    enabled: true
  taskRepository:
    enabled: false
```

### Maintaining Task Repository Availability While Migrating from Redis to SQL

If you're migrating from Redis to SQL in a production environment, where you need to avoid pipeline failures and downtime, you can modify the configuration, as shown below, to configure Clouddriver use SQL for caching and new tasks, but with fallback reads to Redis for tasks not found in the SQL database.

```yaml
redis:
  enabled: true
  connection: redis://your.redis
  cache:
    enabled: false
  scheduler:
    enabled: false
  taskRepository:
    enabled: true

dualTaskRepository:
  enabled: true
  primaryClass: com.netflix.spinnaker.clouddriver.sql.SqlTaskRepository
  previousClass: com.netflix.spinnaker.clouddriver.data.task.jedis.RedisTaskRepository
```

## How Netflix Migrated Clouddriver from Redis to SQL

The following steps were taken to live migrate Clouddriver in the Netflix production Spinnaker stack from Redis to SQL.

1. Provision the database. In this case, a multi-AZ Aurora cluster was provisioned with 3 reader instances.
2. Deploy Clouddriver with SQL enabled only for the `dualTaskRepository`. During the migration, traffic is split between Redis-backed Clouddriver instances and SQL-backed instances. It is important that tasks can be read regardless of request routing to avoid pipeline failures.
    ```yaml
    # clouddriver.yml; there were no modifications to the redis: properties at this point. The following properties were added:
    sql:
      enabled: true
      taskRepository:
        enabled: true
      cache:
        enabled: false
        readBatchSize: 500
        writeBatchSize: 300
      scheduler:
        enabled: false
      connectionPools:
        default:
          default: true
          jdbcUrl: jdbc:mysql://clouddriver-aurora-cluster-endpoint:3306/clouddriver
          user: clouddriver_service
          password: hi! # actually injected from encrypted secrets
      migration:
        user: clouddriver_migrate
        jdbcUrl: jdbc:mysql://clouddriver-aurora-cluster-endpoint:3306/clouddriver

    dualTaskRepository:
      enabled: true
      primaryClass: com.netflix.spinnaker.clouddriver.data.task.jedis.RedisTaskRepository
      previousClass: com.netflix.spinnaker.clouddriver.sql.SqlTaskRepository
    ```
3. A [custom Spring profile](https://www.spinnaker.io/reference/halyard/custom/#custom-profiles) was created and scoped to a set of temporary clouddriver-sql-migration clusters. The `dualTaskRepository` class ordering is flipped.
    ```yaml
    sql:
      enabled: true
      taskRepository:
        enabled: true
      cache:
        enabled: true
        readBatchSize: 500
        writeBatchSize: 300
      scheduler:
        enabled: true
      connectionPools:
        default:
          default: true
          jdbcUrl: jdbc:mysql://clouddriver-aurora-cluster-endpoint:3306/clouddriver
          user: clouddriver_service
          password: hi! # actually injected from encrypted secrets
      migration:
        user: clouddriver_migrate
        jdbcUrl: jdbc:mysql://clouddriver-aurora-cluster-endpoint:3306/clouddriver

    redis:
      enabled: true
      connection: redis://your.redis
      cache:
        enabled: false
      scheduler:
        enabled: false
      taskRepository:
        enabled: true

    dualTaskRepository:
      enabled: true
      primaryClass: com.netflix.spinnaker.clouddriver.sql.SqlTaskRepository
      previousClass: com.netflix.spinnaker.clouddriver.data.task.jedis.RedisTaskRepository
    ```
4. A clouddriver-sql-migration-caching server group was deployed with the above configuration, followed by a 5 minute `WaitStage`, allowing time for cache population. Clouddriver API server groups (with caching agent execution disabled) were then deployed behind the same load balancers routing traffic to the Redis-backed server groups.
5. After another 5 minute wait, the Redis-backed server groups were disabled. At this time, any tasks running on the disabled Redis instance continue until finished. All new requests are routed to clouddriver-sql-migration-api server groups. If a requested taskId is not present in the SQL database, Clouddriver attempts to read it from Redis.
6. The clouddriver-sql-migration configuration is merged into main, with the following changes:
    ```yaml
    redis:
      enabled: false

    dualTaskRepository:
      enabled: false
    ```
7. The disabled Redis-backed Clouddriver instances were verified as idle and the new configuration deployed via a red/black.
8. The temporary migration clusters were disabled and then terminated 5 minutes later.
