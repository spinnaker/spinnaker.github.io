---
title:  "SAML 2.0 - Pre-built VM Images"
sidebar:
  nav: authentication
---

The all-in-one, prebuilt VM images tunnel all of Gate's traffic through Deck's Apache instance. This was done as a convenience for those just trying out Spinnaker, and has caused numerous headaches for users trying to work around it.

The giveaway is the presense of `/gate` at the beginning of the URL path in network traffic. For example, if you see calls like `http://deck.url:9000/gate/applications` or `http://deck.url:9000/gate/serverGroups`, you are most likely using a pre-built VM image where Gate traffic gets routed through Apache's [ProxyPass](https://httpd.apache.org/docs/2.4/mod/mod_proxy.html#proxypass).

Since Gate doesn't know about being fronted by an Apache instance, we must explicitly set the Gate address in the initial request to the SAML provider. Add the following to your configuration:

```
saml:
  # redirectProtocol: https # default is https
  redirectHostname: gate.url:8084
  redirectBasePath: gate # TODO(ttomsu): verify this.
```

It is **strongly** recommended to _not_ put a load balancer in front of this setup. A request goes through two proxy hops -- one for the load balancer, and one for Apache -- and generally ends with frustration and headache getting the URLs _just_ right.

If you prefer to front this instance with a load balancer, send traffic directly to Gate:

1. Allow Gate to accept connections from anywhere (`/opt/spinnaker/config/gate-local.yml`)
    ```
    server:
      address: 0.0.0.0  # listen for all IPv4 connections
    ```

1. Enable authentication and set the load balancer's address as Gate's URL (`/opt/spinnaker/config/spinnaker-local.yml`):
    ```
    services:
      deck:
        auth.enabled: true
        gateUrl: http://load-balanced.gate.url:8084/
    ```
1. Rerun `/opt/spinnaker/bin/reconfigure_spinnaker.sh`. This ensures Deck's configuration knows about the new address.
1. Remove the ProxyPass configuration from Apache's config (`/etc/apache2/sites-available/spinnaker.conf`).
1. Restart Apache and Gate.
