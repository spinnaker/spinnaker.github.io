---
layout: single
title:  "Set up Front50 to use SQL"
sidebar:
  nav: setup
---

{% include toc %}

You can configure Front50 to use a MySQL compatible database in place of any cloud provider-specific storage service (S3, GCS, etc.).

A migration can be performed without downtime by taking advantage of the dual-read/write capabilities in the provided `CompositeStorageService`.


## Why SQL

Netflix has been plagued by eventual consistency-related issues around our usage of versioned S3 buckets and Front50's expectations around read-after-write consistency.

Attempts to work around S3's consistency model have resulted in an operationally complicated production deployment. 

The SQL implementation provides a strongly consistent storage service that is performant, operationally simple and feature rich. It supports object versioning out-of-the-box.


## Configuration Considerations

At Netflix, Orca, Clouddriver and Front50 run with their own dedicated Aurora cluster but this isn't required.


## Database Setup

Front50 ships with `mysql-connector-java` by default. You can provide additional JDBC connectors on the classpath if desired. Use of a different RDBMS family will likely require some development effort at this time. Front50 was developed targeting Amazon Aurora's MySQL 5.7 compatible engine.

Before you deploy Front50, you need to manually create a logical database and user grants.

```sql
CREATE DATABASE `front50` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

GRANT
  SELECT, INSERT, UPDATE, DELETE, CREATE, EXECUTE, SHOW VIEW
ON `front50`.*
TO 'front50_service'@'%'; -- IDENTIFIED BY "password" if using password based auth

GRANT
  SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, LOCK TABLES, EXECUTE, SHOW VIEW
ON `front50`.*
TO 'front50_migrate'@'%'; -- IDENTIFIED BY "password" if using password based auth
```


## Configure Front50 to use MySQL

The following yaml-based parameters provide a Front50 configuration that entirely uses MySQL. [Halyard](/reference/halyard/) does not yet natively support Front50 SQL configuration. Halyard users can provide these as overrides via a `front50-local.yml` file.

You will need to disable any other previously enabled storage services (s3, gcs, etc.).


```yaml
sql:
  enabled: true
  connectionPools:
    default:
      # additional connection pool parameters are available here,
      # for more detail and to view defaults, see:
      # https://github.com/spinnaker/kork/blob/master/kork-sql/src/main/kotlin/com/netflix/spinnaker/kork/sql/config/ConnectionPoolProperties.kt
      default: true
      jdbcUrl: jdbc:mysql://your.database:3306/front50
      user: front50_service
      # password: depending on db auth and how spinnaker secrets are managed    
  migration:
    user: front50_migrate
    jdbcUrl: jdbc:mysql://your.database:3306/front50
```


### Migration

The following steps support a no downtime migration to SQL, substitute `S3StorageService` for the implementation specific to your environment.

```yaml
spinnaker:
  migration:
    enabled: true
    primaryClass: com.netflix.spinnaker.front50.model.SqlStorageService
    previousClass: com.netflix.spinnaker.front50.model.S3StorageService
    compositeStorageService:
      enabled: false
```

Assuming the migration looks good, the following will enable primary and previous writes while leaving reads pointed at previous.

```yaml
spinnaker:
  migration:
    compositeStorageService:
      enabled: true
      reads:
        primary: false
        previous: true
```

Lastly, you can enable primary reads and optionally fallback to previous if an object is not found.

```yaml
spinnaker:
  migration:
    compositeStorageService:
      reads:
        primary: true
        previous: true  # set to `false` to disable fallback reads
```

Once you are satisfied with the migration, remove the `spinnaker.migration` block and disable the previous storage service.


## How Netflix Migrated Front50 from S3 to SQL

The following steps were taken to live migrate Front50 at Netflix from S3 to SQL.

1. Provision the database. In this case, a multi-AZ Aurora cluster was provisioned with 2 reader instances.
2. A [custom Spring profile](https://www.spinnaker.io/reference/halyard/custom/#custom-profiles) was created and scoped to a temporary `front50-sql-migration` cluster. This profile had SQL, S3 and the migrator enabled (_see above for configuration_). The resulting cluster was not added to our load balancer and thus took no traffic.
3. Verify the migration by looking at logs (search for `StorageServiceMigrator`) and the contents of the SQL database.
4. Another [custom Spring profile](https://www.spinnaker.io/reference/halyard/custom/#custom-profiles) was created and scoped to a temporary `front50-sql` cluster. This profile had SQL, S3 and the composite storage service enabled with dual writes (_see above for configuration_). 
5. Verify that writes are happening against SQL and S3 (search for `CompositeStorageService`).
6. Enable reads against SQL with `spinnaker.migration.compositeStorageService.reads.primary: true`.
7. Verify reads are happening against SQL (search for `CompositeStorageService`).
8. Disable reads against S3 with `spinnaker.migration.compositeStorageService.reads.primary: false`.
9. Diable the migrator with `spinnaker.migration.enabled: false`.

To ensure safety, we migrated over the course of a week. 

Our deployment pipelines were updated to include both SQL and non-SQL deploy stages, this made it easy to quickly revert/rollback along the way. 

As of 2019-07, we are still running with the `CompositeStorageService` enabled (reads against SQL only, writes to SQL and S3) but the migrator has been disabled for a few months.

