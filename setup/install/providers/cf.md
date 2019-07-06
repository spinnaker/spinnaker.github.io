---
layout: single
title:  "Cloud Foundry"
sidebar:
  nav: setup
redirect_from: /setup/providers/cf/
---

{% include toc %}

In [Cloud Foundry](https://www.cloudfoundry.org) (CF), an Account maps to a user account on a CF foundation (a BOSH Director and all the VMs it deploys). You can add multiple accounts for one or more CF foundations.

## Prerequisites

Your CF foundations' [API endpoints](https://docs.cloudfoundry.org/running/cf-api-endpoint.html) must be reachable from your installation of Spinnaker.

## Add an account

First, make sure that the provider is enabled:

``` bash
hal config provider cloudfoundry enable
```

Next, run the following `hal` command (replacing placeholders with actual values) to add an account named `my-cf-account` to your list of Cloud Foundry accounts:

``` bash
hal config provider cloudfoundry account add my-cf-account \
  --api-host=[api.sys.endpoint.for.foundation] \
  --user=[user-account] \
  --password=[user-password] \
  --environment=[dev,prod,...] \
  --apps-manager-url=[http://apps.sys.endpoint.for.foundation] \
  --metrics-url=[http://metrics.sys.endpoint.for.foundation] \
  --skip-ssl-validation=[true|false] (optional, default: false)
```

> NOTE:
> 1. `--skip-ssl-validation=true` may be necessary when adding an account with a CF API endpoint using a self-signed SSL certificate or a certificate issued by an internal certificate authority. Turning this on will generate a warning.


As part of the command execution, Halyard will attempt to connect to the Cloud Foundry instance. Halyard will return an error if this attempt fails.

To see the current accounts configured for the provider, you can run:

``` bash
hal config provider cloudfoundry account list
```

To see details about any account for the provider, you can run:

``` bash
hal config provider cloudfoundry account get [account-name]
```

Finally, apply your changes:

```
$ hal deploy apply
```

Within a few minutes after applying your changes, you should be able to view the CF instance's existing applications from your installation of Spinnaker.

## Next steps

Optionally, you can [set up another cloud provider](https://www.spinnaker.io/setup/install/providers/), but otherwise you're ready to [choose an environment](https://www.spinnaker.io/setup/install/environment/) in which to install Spinnaker.
