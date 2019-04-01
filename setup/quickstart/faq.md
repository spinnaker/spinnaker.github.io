---
layout: single
title:  "Halyard FAQ"
sidebar:
  nav: setup
---

{% include toc %}

Here are a few Q/A pairs that come up fairly frequently.

## I can't load the Applications screen

After installing Spinnaker and navigating to the <em>Applications</em> screen, you may see one of
following issues:
 * The loading indicator spins continuously (prior to release 1.9)
 * The following error message is displayed (release 1.9 and later):
 ![Error fetching applications. Check that your gate endpoint is accessible. Further information on troubleshooting this error is available here](applications-error.png)

 The most common cause of this error is that your browser can't communicate with your Gate endpoint.
 (This endpoint defaults to `http://localhost:8084`, but can be customized.)

 Check your browser console log and/or network for any failed requests to `<gate-endpoint>/applications`.

 Some things to check while troubleshooting:
 * If you are accessing Spinnaker via the default `http://localhost:9000`, check that you have
   forwarded Gate's port (8084 by default) to the machine where your browser is running.
 * If you are accessing Spinnaker via a custom URL, ensure that you have set `override-base-url`
   for both the UI (Deck) and API (Gate) services, as described in the
   [question below](#i-want-to-expose-localdebian-spinnaker-on-a-public-ip-address-but-it-always-binds-to-localhost).
   These settings will configure cross-origin resource sharing (CORS) between your Gate and Deck
   endpoints; if this is not properly configured, your browser will reject requests from Deck to
   Gate.
 * If you have a local deployment of Spinnaker, ensure that Redis is available at the configured address (localhost:6379 by default). If not, start redis by running `sudo systemctl enable redis-server && sudo systemctl start redis-server` and restart spinnaker by running `sudo systemctl restart spinnaker`.

## I want to expose LocalDebian Spinnaker on a public IP address, but it always binds to localhost

First off, on a local deployment Spinnaker binds to `localhost` intentionally.
Your Spinnaker instance has the ability to deploy and destroy a lot of
infrastructure in whatever accounts it manages, and opening it to the public is
not a good idea without authentication enabled. With that in mind, there are
two solutions.

1. Once you enable an [authentication](/setup/security/) mechanism, Spinnaker
   will bind the UI and API servers to `0.0.0.0` automatically. This is
   [configurable](/reference/halyard/custom/) if you prefer to bind a specify
   address instead. Regardless, you still need to set the API &
   UI baseUrls so CORS and login redirects happen correctly, this is done with
   the commands `hal config security ui edit --override-base-url <full ui url>`
   and `hal config security api edit --override-base-url <full api url>`.

2. If you don't want to rely on authentication, you can follow [this
   guide](https://blog.spinnaker.io/exposing-spinnaker-to-end-users-4808bc936698){:target="\_blank"}.
   This makes sense if you're running Spinnaker in a private network, or have
   another form of authentication fronting Spinnaker.

## I want to expose the distributed, Kubernetes hosted Spinnaker publicly

There is [a guide](/setup/quickstart/halyard-gke-public/) for doing this using
Google's authentication & domain registrar. If this doesn't match your
environment, it may still be helpful to read. The key point is, Halyard does
_not_ touch any of the Kubernetes Service objects once they are created. You
can change their type to `NodePort`, or `LoadBalancer`, front them with Ingress
resources, or manage them like any other Kubernetes service and expose them
however you like.

## Halyard times out during a config change

Odds are Halyard can't connect to the configuration & version bucket (in Google
Cloud Storage) it uses to determine if the configuration you've provided works
for the version of Spinnaker you want to install. The bucket is
`gs://halconfig`, see if you can reach it locally using the
[`gsutil`](https://cloud.google.com/storage/docs/gsutil){:target="\_blank"} CLI.
The remediation will depend on your local network. You can also always omit
validation with the `--no-validate` flag.

## Halyard times out during a deployment

If this happens, there are one of two causes:

1. The services that haven't become healthy are misconfigured. Run `hal deploy
   collect-logs` to collect service logs, which will be placed in
   `~/.hal/default/service-logs`. Check for any obvious errors.
2. You do not have enough resources in your environment to run Spinnaker, and
   the deployer is waiting for some to become available. This varies from
   environment to environment.

## I want to configure a service beyond what Halyard exposes

First, please read the [custom configuration](/reference/halyard/custom/)
documentation. With that in mind, if you're configuring any of Spinnaker's
[Spring-based](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html){:target="\_blank"}
services (everything but deck and spinnaker-monitoring), you're
best off providing a `-local.yml` profile for the service in mind. For example,
say you are configuring the Halyard
[deployment](/reference/halyard/#deployments) `default`, and the service
`gate`, you can write the following file:

`~/.hal/default/profiles/gate-local.yml`
```yaml
example:
  property: value
```

and the properties generated by Halyard will be overwritten by those provided
in that `gate-local.yml` file.

If the service you want to configure does not rely on Spring, you will need to
wholesale overwrite the config in the `~/.hal/default/profiles` directory.

## I don't want to rely on any of the configuration generated by Halyard

You have two options here:

1. Provide [custom configuration](/reference/halyard/custom) for any services
   whose config you prefer to override.
2. Deploy Spinnaker with the `--omit-config` flag. In the Local installation,
   this will pin & download validated debian packages at their respective
   versions without providing any configuration. In a Distributed installation,
   you will need to provide your own mechanisms for loading configuration for
   each subservice.

## I'm seeing duplicate/bad infrastructure entries in the UI after deploying config changes

Spinnaker's cloud provider integration point (clouddriver) does not clean out
cache entries that may be left around after reconfiguring existing
accounts. The best way to get around this is to supply the
`--flush-infrastructure-caches` to a `hal deploy apply`. This may cause
jittering in the UI as the caches are repopulated.

## I want to decouple my Halyard configuration from a single machine

Please read [the backup documentation](/setup/install/backups/).

## Halyard produces a lot of ugly ANSI escape sequences making it frustrating to automate

You can supply the flags `-q -log=info` to any Halyard command to get more
digestable log messages. `-q` suppresses the ANSI pretty-printing, and
`-log=info` enables info-level logs in the CLI.

## I don't want to use a bunch of CLI commands to configure Spinnaker; I prefer my text editor

Anything in the `~/.hal/config` can be edited by hand at any time. You can
validate what you provide there by running `hal config`, and deploy it as you
would normally `hal deploy apply`. For more service-specific edits, please read
the [custom configuration](/reference/halyard/custom/) docs.

## I only want to deploy a subset of Spinnaker's services

You can run `hal deploy apply --service-names <service1> <service2...>` to
deploy only the services you care about. Be careful, if you have sidecars like
the `monitoring-daemon` or the `consul-client` for a VM based distributed
deployment, you will have to supply those as well.

This can be coupled with `--omit-config` in a local installation to provide a
taylored way of deploying & configuring only the services you want on the
machines you care about.

## I want to run Halyard behind a proxy

In the file under `/opt/halyard/bin/halyard`, add the necessary proxy
configuration to the variable `DEFAULT_JVM_OPTS` as described
[here](https://developers.google.com/gdata/articles/proxy_setup){:target="\_blank"}
For example,
```bash
DEFAULT_JVM_OPTS=-Dhttp.proxyHost=my.proxy.domain.com -Dhttp.proxyPort=3128
```

## I want to run a Spinnaker service (Clouddriver, Echo, etc) behind an HTTP proxy server

For most Spinnaker service communication, this can be accomplished by setting appropriate 
JVM options for the service you want to proxy. For example, if you wanted to proxy Echo
communication for Slack notifications, you would add the following proxy settings to 
`~/.hal/default/service-settings/echo.yml`

```yaml
env:
  JAVA_OPTS: "-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XX:MaxRAMFraction=2
              -Dhttp.proxyHost=<proxy host> -Dhttp.proxyPort=<proxy port> -Dhttps.proxyHost=<proxy host>
              -Dhttps.proxyPort=<proxy port> -Dhttp.nonProxyHosts='localhost|127.*|[::1]|*.spinnaker'"
```

These settings will forward all external communication through the proxy server specified while
keeping internal traffic non-proxied. Additional information can be found 
[here.](https://docs.oracle.com/javase/8/docs/technotes/guides/net/proxies.html){:target="\_blank"}

The Kubernetes V2 provider must be handled differently. Because the Kubernetes V2 provider 
uses `kubectl` (which uses curl), you must set environment variablesif you want 
Kubernetes V2 traffic to be proxied. 

An example `clouddriver.yml` that will proxy Kubernetes V2 traffic will look like:
```yaml
env:
  HTTP_PROXY: "proxyaddress:proxyport"
  HTTPS_PROXY: "proxyaddress:proxyport"
  NO_PROXY: "localhost,127.0.0.1,*.spinnaker" 
```

If you are using both the V1 and V2 version of the Kubernetes provider, you'll need to supply both sets of 
proxy definitions. 
