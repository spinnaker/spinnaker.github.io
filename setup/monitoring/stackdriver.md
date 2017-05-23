---
layout: single
title:  "Stackdriver"
sidebar:
  nav: setup
---

{% include toc %}

There are two ways to use Stackdriver with Spinnaker. The easiest is
to configure Spinnaker microservices to push metrics directly into
stackdriver. Additionally the Spinnaker Monitoring Daemon can write
into Stackdriver for you.

Note that Spinnaker talks to Stackdriver via HTTP so you do not need
to install the Stackdriver Agent. Since the Agent is only available on
Google Cloud Platform or Amazon Web Services, this means that you can
write metrics into Stackdriver regardless of what platform you are running
Spinnaker on. You may still want to install a Stackdriver Agent for
local machine monitoring or monitoring other services. However, the
agent itself does not know about Spinnaker and will not monitor it.

Note that the current integration with Stackdriver is based on using
custom metrics. All told there are a few hundred metrics and several
thousand time series (exact numbers depend on individual circumstances).
Custom metrics are considered a premium stackdriver feature and may incur
[additional costs](https://cloud.google.com/stackdriver/pricing)
depending on your situation. If you are interested in using
Stackdriver, please contact us through the Spinnaker Slack channel.


# Installing Stackdriver

## Configure the Spinnaker Monitoring Daemon for Stackdriver


First, you need a service account with the `roles/monitoring.viewer` and
`roles/monitoring.metricWriter` roles enabled. If you don't already have this,
run the following commands:

```bash
SERVICE_ACCOUNT_NAME=spinnaker-monitoring-account
SERVICE_ACCOUNT_DEST=~/.gcp/gce-monitoring-account.json

gcloud iam service-accounts create \
    $SERVICE_ACCOUNT_NAME \
    --display-name $SERVICE_ACCOUNT_NAME

SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SERVICE_ACCOUNT_NAME" \
    --format='value(email)')

PROJECT=$(gcloud info --format='value(config.project)')

# permission to read existing configured metrics
gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$SA_EMAIL \
    --role roles/monitoring.viewer

# permission to write new metrics 
gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$SA_EMAIL \
    --role roles/monitoring.metricWriter

mkdir -p $(dirname $SERVICE_ACCOUNT_DEST)

gcloud iam service-accounts keys create $SERVICE_ACCOUNT_DEST \
    --iam-account $SA_EMAIL
```

Now you have a service account with the correct roles sitting in
`$SERVICE_ACCOUNT_DEST`.

Finally, run the following hal commands to configure Stackdriver:

```bash
hal config metric-stores stackdriver edit \
    --credentials-path $SERVICE_ACCOUNT_DEST

hal config metric-stores stackdriver enable
```

There are further flags that can be provided if you would like to push metrics
to a different project, or associate them with a different zone. Please refer
to the [halyard command
reference](/reference/halyard/commands/#hal-config-metric-stores-stackdriver-edit).

Proceed to [install the dashboards](#installing-the-stackdriver-dashboards)


## Installing the Stackdriver Dashboards

*__Note__: The Stackdriver Dashboard API is currently whitelisted, so
you need a registered STACKDRIVER_API key in order to use it. If you
are so inclined, [contact your sales
representative](https://cloud.google.com/contact/).

To install the stackdriver dashboards, you need to have the monitoring daemon
installed. But you only need it installed while you upload the dashboards.
You can do this on a temporary VM.

```
export STACKDRIVER_API_KEY=<your api key>
sudo apt-get update -y
sudo apt-get install spinnaker-monitoring-daemon -y
sudo apt-get install spinnaker-monitoring-third-party -y
/opt/spinnaker-monitoring/third_party/stackdriver/install.sh --dashboards_only
```

With your browser, log into
[app.google.stackdriver.com](https://app.google.stackdriver.com)
and select your project. You should be able to see the various Spinnaker
dashboards and select from them.


## Caveats

Stackdriver dashboards do not have the ability to manipulate metrics so
can only show raw values coming from Spinnaker. In particular, latencies
cannot be computed and time values will be in nanoseconds rather than
milliseconds or seconds.

If you are using Stackdriver, you may wish to complement it with Datalab
for the visualization or to manipulate the data. There are no datalab
dashboards provided at present. See the
[Google DataLab Website](https://cloud.google.com/datalab/)
for more information.
