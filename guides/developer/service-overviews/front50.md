---
layout: single
title:  "Front50 Internals Overview"
sidebar:
  nav: guides
---

From Front50's [README](https://github.com/spinnaker/front50/blob/master/README.md):
> Front50 is the system of record for all Spinnaker metadata, including: application, pipeline and service account configurations. 
>
> All metadata is durably stored and served out of an in-memory cache.

# Internals

## Persistence

The following storage backends are supported:

- Amazon S3
- Google Cloud Storage
- Redis
- [SQL](https://github.com/spinnaker/front50/blob/master/front50-sql/src/main/kotlin/com/netflix/spinnaker/front50/model/SqlStorageService.kt) - _recommended_

`SQL` is a cloud agnostic storage backend that offers strong read-after-write consistency and metadata versioning. 


## Metadata

The following types are represented in Front50 ([data models](https://github.com/spinnaker/front50/tree/master/front50-core/src/main/groovy/com/netflix/spinnaker/front50/model)):

| *Type* | *Description* |
| Application | Defines a set of commonly named resources managed by Spinnaker (metadata includes name, ownership, description, source code repository, etc.). |
| Application Permission | Defines the group memberships required to read/write any application resource. |
| Entity Tags | Provides a general purpose and cloud agnostic tagging mechanism. |
| Notification | Defines application-wide notification schemes (email, slack and sms). |
| Pipeline | Defines a reusable delivery workflow (exists within the context of a specific application). |
| Pipeline Strategy | Defines a custom deployment strategy (exists within the context of a specific application). | 
| Project | Provides a (many-to-many) grouping mechanism for multiple applications. |
| Service Account | Defines a system identity (with group memberships) that can be associated with one or more pipeline triggers. |


## Domain

We strive to make it easy to introduce additional metadata attributes; models are simple objects and serialized to `JSON` at persistence time. 

Migrators for non-trivial attribute changes are supported via implementations of the `Migration` interface. 

The `StorageServiceSupport` class maintains an in-memory cache for each metadata type and delegates read/write operations to a storage backend-specific `StorageService` implementation. 


## Relevant Metrics

The following metrics are relevant to overall `Front50` health:

| *Metric* | *Description* | *Grouping* |
| `controller.invocations` (count) | Invocation counts. | `controller` |
| `controller.invocations` (average) | Invocation times. | `controller`, `statusCode` and `method` |
| `controller.invocations` (count) | All 5xx responses. | `controller`, `statusCode` and `status` = `5xx` |