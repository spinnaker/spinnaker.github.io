---
layout: single
title:  "Prometheus"
sidebar:
  nav: setup
---

{% include toc %}

[Prometheus](https://prometheus.io/){:target="\_blank"} is an open-source
monitoring system that pairs nicely with Spinnaker. Prometheus does not have a
native dashboard, rather it uses [Grafana](http://grafana.org){:target="\_blank"},
another open-source system. The Spinnaker integration bundles the two together,
so as far as this document is concerned, Grafana and Prometheus are treated as
one system.

A typical (and recommended) Prometheus installation contains a Prometheus
server that is configured to actively poll the systems it is monitoring,
as opposed to having the systems being monitored actively push their metrics
into Prometheus. That means that Prometheus needs to be aware of each of the
microservice instances. More specifically, it needs to be aware of each
of the Spinnaker Monitoring Daemons which in turn will poll the microservices
and translate the data model into the one expected by Prometheus.

The current Spinnaker installation script can configure for a simple
single instance VM deployment typically used for prototype purposes, or
a multi-VM "high-availability" production type deployment on Google Cloud
Platform. For more information and custom configuration options, see the
[Prometheus Configuration](https://prometheus.io/docs/operating/configuration/){:target="\_blank"}
documentation. They describe support for discovering services on EC2, Azure,
and other platforms or discovery mechanisms you might be using.

In special circumstances (where there is no other means for Prometheus
to know where the individual microservice endpoints are),
you can deploy Prometheus to use a Gateway server wherein
the microservices (i.e. Spinnaker Monitoring Daemon) can push metrics into
Prometheus. The Gateway is simpler to deploy and manage since it is at a
known fixed location that can be easily configured into the endpoints
(which are typically not known and might be in autoscaled instance groups).
However, Prometheus will still be polling the Gateway server, so the data
it does receive wont be fresh. Making matters worse, the data will be
timestamped at the point it is retrieved from the Gateway server, rather
than at the time it was pushed to the Gateway server. So the data timeline
might be off by as much as a minute from actual time making it hard to
correlate monitoring data to logs or other evidence when diagnosing problems
in addition to the other downsides of having stale data. For long term
trends, this is not so much of an issue since the integrity of the counters
and trends they show will still be accurate.

The Spinnaker installation scripts support Gateway deployments as well.
However, it is recommended that you use a standard direct polling deployment
when possible for beter data accuracy.


# Installing Prometheus

Typically the Prometheus server (along with Grafana) will be installed on
one machine independent of Spinnaker, and the client-side configuration
for the Spinnaker Monitoring Daemon will be installed alongside each of the
spinnaker-monitoring-daemon installations. For a simple monolithic
single-instance deployment, you can install everything together on the
same machine as the microservices.

Prometheus requires two ports, `9090` (for Prometheus) and `3000` (for the
Grafana Dashboard). The Web UI for Grafana needs the Prometheus port so
your browser will need to access both ports (i.e. you may need to tunnel both
as you do for Spinnaker's Gate microservice with its Deck Web UI).


## Configure the Spinnaker monitoring daemon for Prometheus

First, you must enable the Prometheus metric store:

```bash
hal config metric-stores prometheus enable
```

There are two ways to configure how Spinnaker provides metrics to Prometheus:

1. Have Prometheus poll each service's metrics endpoint directly. This is
   the preferred method and the default, so no further configuration of Halyard
   is necessary. However, you will need to configure Prometheus to discover
   each Spinnaker service.
2. Have each service push metrics to a Prometheus gateway server. Since this
   involves periodically pushing metrics collected on a fixed interval, this
   may introduce duplicate time-series entries; however, if you are unable to
   configure Prometheus to discover each Spinnaker service, this may be the
   only way to use Prometheus. To configure this given that `<url`> is the
   URL to the Prometheus gateway server, run the following command:
   ```bash
   hal config metric-stores prometheus edit --push-gateway=<url>
   ```

These changes will be picked up by your Spinnaker installation next time you
run `hal deploy apply`.

## Configure the metric and dashboard servers

### Running Spinnaker + Prometheus Operator on Kubernetes

  When running Spinnaker on a Kubernetes cluster, [Prometheus Operator](https://github.com/coreos/prometheus-operator)
  is often used to install and run Prometheus on your Kubernetes clusters.

  Read about support for [Prometheus Operator](https://github.com/spinnaker/spinnaker-monitoring/tree/master/spinnaker-monitoring-third-party/third_party/prometheus_operator/README.md)
  and leverage the `setup.sh` script to complete your Prometheus Operator + Spinnaker configuration.

### Running Spinnaker + Prometheus on virtual machines

  When you ssh into the machine to perform this installation, forward
  the ports 3000 and 9090 so you can install the dashboards. e.g.
  ```
  ssh <host> -L 9090:localhost:9090 -L 3000:localhost:3000
  ```

  1. Install the debian package to get at the scripts and data files.
     ```
     sudo apt-get update -y
     sudo apt-get install spinnaker-monitoring-third-party
     ```

  2. Run the server-side configuration script.
     ```
     /opt/spinnaker-monitoring/third_party/prometheus/install.sh \
         --server_only
     ```

     * If you wish to use a Gateway-style deployment, then also specify
       the gateway with `--gateway=<url>` where `<url>` is the URL to
       the gateway server.

     * If you are deploying Spinnaker across multiple Google Compute
       Engine instances, add `--gce` to have script configure prometheus
       to discover the daemons running on GCE instances.

     * If you are deploying Spinnaker across multiple VMs on EC2,
       see [Prometheus ec2_sd_config](https://prometheus.io/docs/operating/configuration/#<ec2_sd_config>){:target="\_blank"}.
       If on Azure, see [Prometheus azure_sd_config](https://prometheus.io/docs/operating/configuration/#<azure_sd_config>){:target="\_blank"}.
       If you pursue one of these, please contribute back the work to
       improve the installer for those that follow your lead.

  3. Proceed to [install the operational dashboards](#install-the-operational-dashboards)


## Install the operational dashboards

If you have not already port forwarded `9090` and `3000` or installed
the `spinnaker-monitoring-third-party` package as described above, do so now.

  1. Install the dashboards
  ```
  /opt/spinnaker-monitoring/third_party/prometheus/install.sh --dashboards_only
  ```

  2. Open http://localhost:3000 in your browser

     * If prompted for a user/password using the default `admin` and `admin`.
       You can change these by editing `/etc/grafana/grafana.ini`

     * You should see the Spinnaker datasource and dashboards from the
       topleft pulldown. The dashboards may not have any data on them yet
       because the Daemons might not be polled.


# Using the Prometheus dashboards

Each of the dashboards use Grafana's templating mechanism in order to
allow you to perform some global filtering. The variables provided depend
on the type of dashboard. As a rule of thumb, the following are available:

   * Most if not all dashboards allow you to select the time interval used
     for sampling. This has no impact on the collected data, it is only used
     for purposes of analyzing the already collected data. Longer time periods
     may smooth out some graphs to average values over greater time periods.
     Shorter time periods will show more volatility since Spinnaker processing
     is often sporadic.

   * All dashboards have an instance dropdown that let you select a particular
     instance or all instances. This is helpful if you want to narrow your
     investigation to a particular instance, or look at the system as a whole.
     If you want to look at a subset of instances between 1 and all, you will
     need to create your own custom charts using Grafana.

   * The platform-oriented dashboards often have selectors for a particular
     region or global so that you can narrow your view into a particular
     region or look globally. If you want to look at a subset of regions
     between 1 and all, you will need to create your own custom charts using
     Grafana.

   * There is an application-oriented dashboard that lets you select
     a particular application, or look at them all. This dashboard only
     contains metrics that are tagged with application context. Only a
     few of the metrics within Spinnaker know or care about applications,
     even though most Spinnaker activity is performed in the context of
     an application. The list of applications currently comes from a
     particular metric in Front50. If the application you want does not
     show up there, then you may need to wait a little while longer.
     two things may be causing the delay:

     1. The application is not configured (not saved through Front50)

     2. No operation has been performed on that application, meaning that
        no-time-series wiht that label has been created.

The dashboards manipulate the names of the metrics and labels in order to
provide cleaner and more precise legends and labelings. If you need to know
exact metric names, then you might need to look inside the view definition
to reverse engineer it.

## Caveats

The Grafana dashboards are typically "idelta" (sic) or "rates" at 1m intervals.
When computing the delta, it considers the previous value in the series
for the selected time interval. If there was no value (e.g. this is the first
value seen), then it considers the delta to be 0 rather than the count.
Unfortunately, that means that the charts will show 0 rather than the actual
count. This could mean that you might not see errors and other rare anomolies
occuring the first time they are encountered. Fortunately, there is a
subtle indicator that this is happening because the chart will display the
0 value line and add an entry into the chart's legend, whereas prior to those
data points, there was no value on the chart or in the legend. If you are
investigating an issue and think an event might be uncounted, you can create
a grafana chart for the metric and look at it as a rate or absolute count
value to see how and when the values might be changing.

Similar to the above, sometimes when a service restarts and a counter is
reset from a huge number back to 0, it may interpret that as a huge drop
and throw the delta value negative briefly. This wont happen for rates.
Some of the graphs pin their y axis to not display negative or large negative
values in order to mitigate this.
