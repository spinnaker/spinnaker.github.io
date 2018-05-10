---
layout: single
title:  "Set up canary support"
sidebar:
  nav: setup
---

{% include toc %}

Setting up automated canary analysis in Spinnaker consists of running a bunch
of Halyard commands, as described in this doc. Before you can use the canary
analysis service, you must configure at least one metrics service, and at least
one storage service. The most common setup is to have one metrics service
configured (e.g. Stackdriver, Atlas, Prometheus or Datadog) and one storage
service (e.g. S3, GCS or Minio) configured. For further details, [here's a
comprehensive reference](/reference/halyard/commands/#hal-config-canary).

## Quick start

If you'd prefer to just get up and running quickly now, this set of sample Halyard commands will enable
Kayenta and configure it to retrieve metrics from Stackdriver and use GCS for persistent storage:

```
hal config canary enable
hal config canary google enable
hal config canary google account add my-google-account \
  --project $PROJECT_ID \
  --json-path $JSON_PATH \
  --bucket $MY_SPINNAKER_BUCKET
hal config canary google edit --gcs-enabled true \
  --stackdriver-enabled true
```

In the commands above...

`$PROJECT_ID` is your GCP project ID

`$JSON_PATH` points to your service account JSON file&mdash;don't include quotes

`$MY_SPINNAKER_BUCKET` points to a GCS bucket that accepts your credentials.

These can be the same values you used when configuring your other Spinnaker
services (like Clouddriver).

> __Note__ All canary-specific Halyard commands require Halyard version 0.46.0
> or later.
>
> `sudo update-halyard`
>
> or
>
> `sudo apt-get update && sudo apt-get install halyard`

Next, set the Spinnaker version to v1.7.0 or higher:

`hal config version edit --version 1.7.0`

Lastly, update your Spinnaker deployment to include Kayenta:

`hal deploy apply` (to Kubernetes)
`sudo hal deploy apply` (to local VM)

## Enable/disable canary analysis

```
hal config canary enable
```

```
hal config canary disable
```

## Specify the scope of canary configs

By default, each [canary configuration](/guides/user/canary/config/) is
visible to all pipeline canary stages in all apps. But you can change that so
each canary config can be used only within the Spinnaker application in which it
was created:

```
hal config canary edit --show-all-configs-enabled false
```

Set it to `true` to revert to global visibility.

## Set the canary judge

The current default judge is `NetflixACAJudge-v1.0`. The behavior of this judge
is described [here](/guides/user/canary/judge/).

If there are any other judges available in your world, you can set Spinnaker to
use it:

```
hal config canary edit --default-judge JUDGE
```

## Identify your metrics provider

```
hal config canary edit --default-metrics-store STORE
```

`STORE` can be...

* `atlas`
* `datadog`
* `stackdriver`
* `prometheus`

## Provide the default metrics account

Add the account name to use for your metrics provider. This default can be
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

See the [command reference](/reference/halyard/commands/#hal-config-canary)
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
documentation](/reference/halyard/commands/#hal-config-canary)

#### Add an account to your Datadog service integration

```
hal config canary datadog account add ACCOUNT --api-key --application-key
--base-url
```

See the [command reference](/reference/halyard/commands/#hal-config-canary)
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
documentation](/reference/halyard/commands/#hal-config-canary)

#### Add an account to your Google service integration

```
hal config canary google account add ACCOUNT --bucket --bucket-location
--json-path --project --root-folder
```

See the [command reference](/reference/halyard/commands/#hal-config-canary)
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
documentation](/reference/halyard/commands/#hal-config-canary)

#### Add an account to your Prometheus service integration

```
hal config canary prometheus account add ACCOUNT --base-url
```

See the [command
reference](/reference/halyard/commands/#hal-config-canary)
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
