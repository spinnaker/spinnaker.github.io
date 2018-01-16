---
layout: single
title:  "Redis"
sidebar:
  nav: setup
redirect_from: /setup/storage/redis.html
---

> :warning: We _highly_ recommend relying on [Minio](/setup/storage/minio)
> instead of Redis if you are looking for a local persistant storage solution
> for Spinnaker. The Redis storage implementation is untested and unsupported 
> by anyone in the Spinnaker community.

> :warning: Redis can be used as Spinnaker's persistent storage source, but
> it is unsupported and __not__ recommended for production use-cases because
> it mixes fungible, short-lived cache entries with the Pipeline and Application
> data that deploy all of your infrastructure. This means you will have to be
> extra careful when clearing your Spinnaker Redis cache.

## Prerequisites

Currently, Halyard only allows you to use the Redis instance that Halyard
provisions/installs on your behalf. While this is likely to change, for you 
don't need to preconfigure anything to get this storage source working.


## Editing Your Storage Settings

All that's needed is the following command:

```
hal config storage edit --type redis
```
