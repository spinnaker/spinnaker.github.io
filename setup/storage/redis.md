---
layout: single
title:  "Redis"
sidebar:
  nav: setup
---

{% include toc %}

> :warning: Redis can be used as Spinnaker's persistent storage source, but
> it is __not__ recommended for production use-cases because it mixes fungible,
> short-lived cache entries with the Pipeline and Application data that deploy
> all of your infrastructure. This means you will have to be extra careful
> when clearing your Spinnaker Redis cache.

## Prerequisites

Currently, Halyard only allows you to use the Redis instance that Halyard
provisions/installs on your behalf. While this is likely to change, for you 
don't need to preconfigure anything to get this storage source working.


## Editing Your Storage Settings

All that's needed is the following command:

```
hal config storage edit --type redis
```
