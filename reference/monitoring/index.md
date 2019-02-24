---
layout: single
title:  "Monitoring"
sidebar:
  nav: reference
---

{% include toc %}

This is the reference documentation for the metrics reported by Spinnaker
microservices. It is intended for operators who need to monitor the services
but cannot use the monitoring-daemon. If you're looking on instructions for
how to install or setup monitoring, checkout the
[Enable Monitoring](/setup/monitoring/) section in the
[Spinnaker Setup Guide](/setup/).


## Metrics overview

A Spinnaker metric is a named collection of measurements used to track
a type of activity over time. There are two basic types of metrics: counters
and gauges. A counter measures how many times the activity occured over the
lifetime of the process (e.g. how many actions have ever occurred) whereas
a gauge measures an instantaneous value (e.g. how many actions are active now).

Each recorded measurement has a set of tags and a timestamped value.
The tags are used to capture the context or aspect of the value.
For example, each Spinnaker microservice uses a single counter metric
("controller.invocations") to monitor how many HTTP calls it handled.
Since the microservices have many different HTTP endpoints, they add
a tag ("method") to the measurement indicating which was called.
Internally the endpoints are grouped together for different types that
are managed by a particular controller, so the measurements are also tagged
with a "controller" tag.

Operationally, you want to be able to distinguish successful calls from
failures in order to detect problems that might come up. Rather than
creating different metrics for each type of failure or success (or failure
vs success), the measurements are tagged with a "success" tag as well
as a "statusCode" tag. The end result is that there is just a single metric
"controller.invocations", but the measurements within it are richly decorated
with details so that individual metrics can be filtered to view a much finer
granularity.

In essence, the sequence of timestamped measurements for a Spinnaker metric
can be partitioned by their tag bindings so that all the measurements for the
same set of tag bindings form their own sequence (e.g. all the successful
calls to the "list" method vs all the failed calls to the "list" method vs
all the failed calls to the "get" method). The monitoring systems will
typically treat each of these as their own time-series and allow you to
filter by some tags, then aggregate by or break out by each of the others
so that you can view the measurements at the abstraction and granularity
that makes sense for what your interest is (e.g. global failures,
attempted modifications to a particular resource type, etc).


Here is an example of the metric `controller.invocations` in Front50.

```
"tags": [
    {
        "key": "application",
        "value": "mysnazzyapp"
    },
    {
        "key": "controller",
        "value": "PipelineController"
    },
    {
        "key": "method",
        "value": "listByApplication"
    },
    {
        "key": "statistic",
        "value": "count"
    },
    {
        "key": "status",
        "value": "2xx"
    },
    {
        "key": "statusCode",
        "value": "200"
    },
    {
        "key": "success",
        "value": "true"
    }
],
"values": [
    {
        "t": 1500000000000,
        "v": 100.0
    }
]
```

The interpretation of this is that as of time `t=1500000000000` (milliseconds
since unix epoch), there were `v=100` calls to the `listByApplication`
method of the pipeline controller, where the application was `mysnazzyapp` and
resulted in a HTTP 200 status code. While there are some patterns to tags, there
are no actual standards suggesting how to interpret these.

As noted above, monitoring will typically aggregate many of these time-series
together in practice allowing you to choose the level of granularity depending
on what you are interested in paying attention to at any given point in time.
Since the data is collected very granular, you can go back in time and dig into
the details should you need to diagnose or compare them later.

Note that the values are for the lifetime of this particular process instance,
and only this instance. Each repilca has its own count, and the counts are
reset each time the process restarts. It is up to the backing monitoring
service to aggregate these counts across replicas.


## JSON document format

Metrics are returned in the following format:


### Top-level document

Key | Format | Description
----|--------|------------
applicationName | string | The name of the microservice.
applicationVersion | string | The version number of the microservice.
metrics | [See Metric Entry](#metric-entry) | The individual metric entries.
startTime | int | Unix epoch time *milliseconds* that process started.


### Metric entry

The metrics dictionary contains an entry for each reported metric name.
The dictionary key is the name of the metric. The entry contains the data for the metric.

Key | Format | Description
----|--------|------------
kind|String  | The type of metric. `Counter` is a numeric monotonically increasing numeric counter. `Gauge` is an instantaneous numeric value. `Timer` is a nanosecond counter.
values| List of [Time-Series Data Point](#time-series-data-point) | A metric will have one or more time-series associated with it. The current value for each of these is in this list.


### Time-series data point

Key | Format | Description
----|--------|------------
tags | List of Tag Bindings | A tag-binding is a `key`, `value` pair expressed as a dictionary with two entries; `key` and `value`. Each of these has a string value. The value of the `key` is the name of the tag. The value of the `value` is the value for the tag. For example, `{"key": "success", "value": "true"}` is associating the tag `success=true` to the time-series. <br>In practice, each time-series usually has several different tags (i.e. the context used to tag a metric, has multiple dimensions to it, each of which described by a different tag).
values | List of Timestamped Value | In practice this is a list of one element, which is only the most current value. The element is a dictionary with two keys. `v` for the value, which is a real, even for scalar values, and `t` for the timestamp as milliseconds since the Unix epoch.
