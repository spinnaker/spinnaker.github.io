---
layout: single
title:  "Datadog"
sidebar:
  nav: setup
---

{% include toc %}

[Datadog](https://datadoghq.com) is a modern monitoring & analytics solution.
This document describes how to configure Spinnaker and its monitoring daemon
to publish metrics and dashboards to Datadog.

# Setup Datadog

To get started, you'll need a Datadog account, API and App Keys. You can create
API and App keys [here on the Datadog website](https://app.datadoghq.com/account/settings#api).

It is not required that you run a Datadog agent for this setup to work properly,
but it is recommended to provide greater visibility into your spinnaker installation.
If you do chose to run the agent, you can find more information on the the Datadog website here: [Agent - Datadog Docs](https://docs.datadoghq.com/agent/).

Additionally, you can install the agent with the `spinnaker-third-party` scripts as outlined below.
This document assumes a debian installation.

## Install the Spinnaker Monitoring Daemon

To get started you'll need to make sure the spinnaker-monitoring-daemon is installed on your machines.
If you've configured them with halyard it should be as simple as the following commands.

```
sudo apt-get update -y
sudo apt-get install spinnaker-monitoring-daemon -y
```

## Configure the Spinnaker Monitoring Daemon for Datadog

Now enable the Datadog metrics store with halyard:

```bash
hal config metric-stores datadog enable
```

Configure it with your Datadog API keys:

```bash
hal config metric-stores datadog edit --api-key <API_KEY>
```

And an optional app key (This is only required if you want Spinnaker to push pre-configured Spinnaker dashboards to your Datadog account):

```bash
hal config metric-stores datadog edit --app-key <APP_KEY>
```

These changes will be picked up by your Spinnaker installation next time you run `hal deploy apply`.

## Install Tools and Optionally the Datadog Agent

SSH into your machine however you do so. If you're using an ssh tunnel
to perform this installation, forward the ports 3000 and 9090 so you
can install the dashboards. e.g.

```bash
ssh <host> -L 9090:localhost:9090 -L 3000:localhost:3000
```

1. Install the debian package to get at the scripts and data files.

```bash
sudo apt-get update -y
sudo apt-get install spinnaker-monitoring-third-party
```

2. If you want to install the Datadog server agent for more insight into your spinnaker instance, run the following

This script will prompt you for your Datadog API key if is not set in your Datadog config (`/etc/dd-agent/datadog.conf`)
or exported in the environment as `DATADOG_API_KEY`.

```bash
/opt/spinnaker-monitoring/third_party/datadog/install.sh --server_only
```

Once complete you should have a running datadog agent and find more detailed metrics about the server in Datadog.

3. Proceed to [install the operational dashboards](#install-the-operational-dashboards)

## Install the Operational Dashboards

Having installed `spinnaker-monitoring-third-party` [above](#install-tools-and-optionally-the-datadog-agent),
you can run the same script to install the Datadog dashboards

This script will prompt you for your Datadog API and App keys if they are not set in your Datadog config (`/etc/dd-agent/datadog.conf`)
or exported in the environment as `DATADOG_API_KEY` or `DATADOG_APP_KEY`.

```bash
/opt/spinnaker-monitoring/third_party/datadog/install.sh --dashboards_only
```

Once completed, you should have new dashboards in your datadog account named `Spinnaker Kitchen Sink`, `Minimal Spinnaker`, and `Specific Spinnaker Application`.