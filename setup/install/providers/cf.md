---
layout: single
title:  "Cloud Foundry"
sidebar:
  nav: setup
redirect_from: /setup/providers/cf/
---

{% include alpha version="1.10 and later" %}

{% include toc %}

In [Cloud Foundry](https://www.cloudfoundry.org) (CF), an Account maps to a user account on a CF foundation (a BOSH Director and all the VMs it deploys). You can add multiple accounts for one or more CF foundations.

## Prerequisites

Your CF foundations' [API endpoints](https://docs.cloudfoundry.org/running/cf-api-endpoint.html) must be reachable from your installation of Spinnaker.

## Add an account

While the Cloud Foundry provider is in alpha, the hal CLI does not have support for adding a CF account (this support will be added soon). Instead, you can use Halyard's [custom configuration](https://www.spinnaker.io/reference/halyard/custom/) to add a CF account to an existing installation of Spinnaker.

On the machine running Halyard, Halyard creates a `.hal` directory. It contains a subdirectory for your Spinnaker deployment; by default, this subdirectory is called `default`. The deployment subdirectory itself contains a `profiles` subdirectory. Change to this subdirectory (an example path might be something like `~/.hal/default/profiles/`) and within it, create the two files shown below.

Create a file called `settings-local.js`, with the following contents:

```
window.spinnakerSettings.providers.cloudfoundry = {
  defaults: {account: 'my-cloudfoundry-account'}
};
```

This file tells Spinnaker's Deck microservice to load functionality supporting CF.

Create another file called `clouddriver-local.yml`, modifying the contents to include the relevant CF credentials:

```
cloudfoundry:
  enabled: true
  accounts:
    - name: account-name
      user: 'account-user'
      password: 'account-password'
      api: api.foundation.path
    - name: optional-second-account
      api: api.optional.second.foundation.path
      user: 'second-account-user'
      password: 'second-account-password'
```

This file gives Spinnaker account information with which to reach your CF instance.

If you are setting up a new installation of Spinnaker, proceed to "Next steps" below.

If you are working with an existing installation of Spinnaker, apply your changes:

```
$ hal deploy apply
```

Within a few minutes after applying your changes, you should be able to view the CF instance's existing applications from your installation of Spinnaker.

## Next steps

Optionally, you can [set up another cloud provider](https://www.spinnaker.io/setup/install/providers/), but otherwise you're ready to [choose an environment](https://www.spinnaker.io/setup/install/environment/) in which to install Spinnaker.
