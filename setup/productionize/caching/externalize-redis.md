---
layout: single
title:  "Externalize Redis"
sidebar:
  nav: setup
redirect_from: /setup/scaling/externalize-redis/
---

{% include toc %}

One of easiest ways to improve Spinnaker's reliability at scale is to use an
external Redis. The Redis installed by Spinnaker (either locally, or in
Kubernetes) isn't configured to be production-ready. If you have a hosted Redis
alternative, or a database team managing a Redis installation, we highly
recommend using that.

## Configure a Spinnaker-wide Redis

First, determine the URL of your Redis installation. Some examples include:

* `redis://some.redis.url:6379`: Redis running at `some.redis.url` on port
  `6379`.

* `redis://admin:passw0rd@some.redis.url:6379`: Same as above, but with
  a username/password pair.

* `redis://admin:passw0rd@some.redis.url:6379/1`: Same as above, but using
  database 1. See [SELECT documentation](https://redis.io/commands/select).

We will refer to this as `$REDIS_ENDPOINT`.

Using [Halyard's custom
configuration](/reference/halyard/custom#custom-service-settings) we will
create the following file `~/.hal/$DEPLOYMENT/service-settings/redis.yml`:

```yaml
overrideBaseUrl: $REDIS_ENDPOINT
skipLifeCycleManagement: true
```

> `$DEPLOYMENT` is typically `default`. See [the
> documentation](/reference/halyard#deployments) for more details.

> __Note__: By setting `skipLifeCycleManagement` we are telling Halyard to stop
> deploying/check the status of the Redis instance. If Halyard has already
> created a Redis instance, you will have to manually delete it.

## Configure per-service Redis

If your single Redis node is overloaded, you can configure Spinnaker's services
to use different Redis endpoints. _You will need to manage these Redis
installations yourself, Halyard does not create them for you_.

Using [Halyard's custom
configuration](/reference/halyard/custom#custom-profiles) we will
create the following file `~/.hal/$DEPLOYMENT/profile-settings/$SERVICE-local.yml`:

```yaml
services.redis.baseUrl: $REDIS_ENDPOINT
```

> `$DEPLOYMENT` is typically `default`. See [the
> documentation](/reference/halyard#deployments) for more details.

> `$SERVICE` is the service name (e.g. `clouddriver`) that is being configured
> to use another endpoint.

## Using a hosted Redis

Gate requires keyspace notifications to be enabled in Redis, and tries to configure
this when it starts up. Some hosted Redis services disable the `CONFIG` command, blocking
Gate from modifying the configuration. In this case:
1. Manually set the configuration parameter `notify-keyspace-events` to `gxE` on your Redis
instance by following the documentation provided by your hosted Redis provider.
2. Disable automatic Redis configuration in Gate by adding the following to your
`gate-local.yml` file:
   ```yaml
      redis:
        configuration:
          secure: true
   ```
