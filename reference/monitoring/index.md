---
layout: single
title:  "Monitoring"
sidebar:
  nav: reference
---

{% include toc %}

This is the reference documentation for the metrics reported by Spinnaker
microservices. It is indented for operators who need to monitor the services
but cannot use the monitoring-daemon. If you're looking on instructions for
how to install or setup monitoring, checkout the
[setup instructions](/setup/monitoring/).


## Enabling Monitoring

The monitoring endpoint, `/spectator/metrics`, is not available unless
monitoring is enabled, which it is by default. Monitoring is enabled in
the microservices using the Halyard command **TBD**.


## Metrics Overview

Metrics are recorded with a set of tag bindings (e.g. `success=true`) describing
the context of the counter. Each of these bindings collections is a different
time-series. For example, the metric `controller.invocations` in Front50 may 
have a time series with the following tag bindings:
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
        "t": 1493930053715,
        "v": 6450.0
    }
]
```

The interpretation of this is that as of time `t=1493930053715` (milliseconds
since unix epoch), there were `v=6450` calls to the `listByApplication
method of the pipeline controller, where the application was `mysnazzyapp` and
resulted in a HTTP 200 status code. While there are some patterns to tags, there
are no actual standards suggesting how to interpret these. The point of this
example is that if the method or application were different, then the whole
time-series would be different. Likewise if the `statusCode` or any other were
different then this would also be a different time-series. Finally if another
tag were added, then that too would be a different time-series.

In practice, monitoring will typically aggregate many of these time-series together.
The level of granularity will depend on what you are interested in paying attention
to at any given point in time. Since the data is collected very granular, you can
go back in time and dig into the details should you need to diagnose or compare
them later.

Note that the values are for the lifetime of this particular process instance, and
only this instance. Each repilca has its own count, and the counts are reset each
time the process restarts. It is up to the backing monitoring service to aggregate
these counts across replicas.


## JSON Document Format

Metrics are returned in the following format:


### Top-Level Document

Key | Format | Description
----|--------|------------
applicationName | string | The name of the microservice.
applicationVersion | string | The version number of the microservice.
metrics | [See Metric Entry](#metric-entry) | The individual metric entries.
startTime | int | Unix epoch time *milliseconds* that process started.


### Metric Entry

The metrics dictionary contains an entry for each reported metric name.
The dictionary key is the name of the metric. The entry contains the data for the metric.

Key | Format | Description
----|--------|------------
kind|String  | The type of metric. `Counter` is a numeric monotonically increasing numeric counter. `Gauge` is an instantaneous numeric value. `Timer` is a nanosecond counter.
values| List of [Time-Series Data Point](#time-series-data-point) | A metric will have one or more time-series associated with it. The current value for each of these is in this list.


### Time-Series Data Point

Key | Format | Description
----|--------|------------
tags | List of Tag Bindings | A tag-binding is a `key`, `value` pair expressed as a dictionary with two entries; `key` and `value`. Each of these has a string value. The value of the `key` is the name of the tag. The value of the `value` is the value for the tag. For example,
`{"key": "success", "value": "true"}` is associating the tag `success=true` to the time-series.
In practice, each time-series usually has several different tags (i.e. the context used to
tag a metric, has multiple dimensions to it, each of which described by a different tag).
values | List of Timestamped Value | In practice this is a list of one element, which is only the most current value. The element is a dictionary with two keys. `v` for the value, which is a real, even for scalar values, and `t` for the timestamp as milliseconds since the Unix epoch.
