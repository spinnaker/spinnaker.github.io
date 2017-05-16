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

## Configuring the Microservices

If you are going to have the microservices push directly into stackdriver,
then you need to set the following attributes to `services.stackdriver`
in `spinnaker-local.yml`:

Name | Type | Description
-----|------|------------
enabled | true or false | Whether or not to write to stackdriver directly
projectName | Stackdriver Project name | The stackdriver project to write the metric data into. The default is the `providers.google.primaryCredentials.project` however this is is not necessarily correct. Especially if you are using Stackdriver but not using Google.
credentialsPath | Path to json file | A path to the JSON file containing the service account credentials downloaded from the Google Developer's Console used to authenticate with Stackdriver. The default is providers.google.primaryCredentials.jsonPath, however this might not be the account or credentials you wish to use. If you leave the value empty, it will use the default Service Account credentials for the VM that you are deployed on.

If you are on Google Cloud Platform and using the Default Service Account
credentials then you may need to enable the Monitoring-Write scope.
This scope is enabled by default, however depending on how you create
the VMs that you are deploying into, the scope may have been left out.

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