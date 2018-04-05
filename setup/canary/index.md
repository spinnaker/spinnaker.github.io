---
layout: single
title:  "Set up canary support"
sidebar:
  nav: setup
---

{% include toc %}

All setup for automated canary analysis in Spinnaker is done using Halyard
commands.
[Here's a reference](/reference/halyard/commands/#hal-config-canary) for this
canary set of Halyard commands.


## Enable/disable canary analysis

```
hal config canary enable
```

```
hal config canary disable
```


## Specify the scope of canary configs

Each [canary configuration](/guides/user/canary/config/) is available to all
pipeline canary stages in all apps, by default. But you can change that so each
canary config is only visible to the app in which it is created:

```
hal config canary edit --show-all-configs-enabled false
```

Set it to `true` to revert to global visibility.

## Set the canary judge

The current default judge is `NetflixACAJudge-v1.0`. The behavior of this judge
is described [here](/guides/user/canary/judge/)

```
hal config canary edit --default-judge JUDGE
```

## Identify your metrics provider

```
hal config canary edit --default-metrics-store STORE
```

`STORE` currently can be...

* `atlas`
* `datadog`
* `stackdriver`
* `prometheus`

## Provide the default metrics account

Add the account name to use on your metrics provider. This default can be
overridden in [canary configuration](/guides/user/canary/config/).

```
hal config canary edit --default-metrics-account ACCOUNT
```

## Provide the default storage account

Add the account name for your [storage provider](/setup/install/storage).
This default can be overridden in [canary
configuration](/guides/user/canary/config/).

```
hal config canary edit --default-storage-account ACCOUNT
```

## Set up canary analysis for AWS

Configure your canary analysis to use the AWS platform&mdash;S3 in particular.

### Enable/disable AWS support for canary

```
hal config canary aws enable
```

```
hal config canary aws disable
```

### Manage or view AWS account information for canary

You can add, delete, and multiple accounts for AWS service integrations.

#### Add an account to your AWS service integration

```
hal config canary aws account add ACCOUNT --bucket --deployment --no-validate
--root-folder
```

See the [command reference](/reference/halyard/commands/#hal-config-canary-aws)
for more about these parameters.

#### Enable S3 for your canary

```
hal config canary aws account edit --s3-enabled
```

#### View your AWS canary account details

```
hal config canary aws account get
```

#### List your canary AWS accounts

```
hal config canary aws account list
```




## Set up canary analysis to use Datadog

If your telemetry provider is Datadog, use these commands to set up your canary
to work with your Datadog metrics.

### Enable/disable your Datadog service integration

```
hal config canary datadog enable
```

```
hal config canary datadog disable
```

### Manage or view Datadog account information for canary

You can add, delete, and multiple accounts for Datadog service integrations.
For details on the parameters for these commands, see the [Halyard reference
documentation](/reference/halyard/commands/#hal-config-canary-datadog)

#### Add an account to your Datadog service integration

```
hal config canary datadog account add ACCOUNT --api-key --application-key
--base-url
```

See the [command reference](/reference/halyard/commands/#hal-config-canary-datadog)
for more about these parameters.

#### Edit your Datadog account information

```
hal config canary datadog account edit ACCOUNT --api-key --application-key
--base-url
```

#### Delete your account

```
hal config canary datadog account delete ACCOUNT
```

#### View your Datadog canary account details

```
hal config canary datadog account get
```

#### List your canary Datadog accounts

```
hal config canary datadog account list
```





## Set up canary analysis for Google

Configure your canary analysis to work with
Google, including [Stackdriver](https://cloud.google.com/stackdriver)
and [GCS](https://cloud.google.com/storage/).


### Enable/disable your Google service integration

```
hal config canary google enable
```

```
hal config canary google disable
```

### Manage or view Google account information for canary

You can add, delete, and multiple accounts for Google service integrations.
For details on the parameters for these commands, see the [Halyard reference
documentation](/reference/halyard/commands/#hal-config-canary-google)

#### Add an account to your Google service integration

```
hal config canary google account add ACCOUNT --bucket --bucket-location
--json-path --project --root-folder
```

See the [command reference](/reference/halyard/commands/#hal-config-canary-google)
for more about these parameters.

#### Edit your Google account information

```
hal config canary google account edit ACCOUNT --bucket --bucket-location
--json-path --project --root-folder
```

#### Delete your account

```
hal config canary google account delete ACCOUNT
```

#### View your Google canary account details

```
hal config canary google account get
```

#### List your canary Google accounts

```
hal config canary google account list
```




## Set up canary analysis to use Prometheus
Configure your canary analysis to use Prometheus as your telemetry provider.


### Enable/disable your Prometheus service integration

```
hal config canary prometheus enable
```

```
hal config canary prometheus disable
```

### Manage or view Prometheus account information for canary

You can add, delete, and multiple accounts for Prometheus service integrations.
For details on the parameters for these commands, see the [Halyard reference
documentation](/reference/halyard/commands/#hal-config-canary-prometheus)

#### Add an account to your Prometheus service integration

```
hal config canary prometheus account add ACCOUNT --base-url
```

See the [command
reference](/reference/halyard/commands/#hal-config-canary-prometheus)
for more information.

#### Edit your Prometheus account information

```
hal config canary prometheus account edit ACCOUNT --base-url
```

#### Delete your account

```
hal config canary prometheus account delete ACCOUNT
```

#### View your Prometheus canary account details

```
hal config canary prometheus account get
```

#### List your canary Prometheus accounts

```
hal config canary prometheus account list
```




## Specify location of web components (for Atlas)
If you're using Atlas as your  telemetry provider...

```
hal config canary edit --atlasWebComponentsUrl URL
```
