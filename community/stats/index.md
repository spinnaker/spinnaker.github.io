---
layout: single
title:  "Usage Statistics"
sidebar:
  nav: community
---

{% include toc %}

[If enabled](#how-is-the-data-collected), Spinnaker collects data about how the tool is being used. This data is anonymized (before being sent across the internet) and aggregated.

## Why is data being collected?

The project maintainers have few signals about how the product is actually being used in the real world.

  _Is new feature X having any traction with users?_
  _Can we remove feature Y because it's hard to maintain?_

Questions like these are difficult to answer without at least some automated data collection, and ultimately that leads to a product that becomes slow, bloated, and littered with failed experimental code that nobody is confident about deleting.

## What data is being collected?

Spinnaker's telemetry module collects the following bits of data:

* Spinnaker top-level version
* A unique instance ID (a randomly generated ULID), SHA-256 hashed when sent over the wire
* Application name, SHA-256 hashed and salted with the instance ID
* Each execution's:
  * ID, SHA-256 hashed
  * Final status
  * Type
  * Trigger
  * Each stage's:
    * Final status
    * Type
    * Cloud Provider

Spinnaker's telemetry project has been reviewed and approved as compliant with the [Linux Foundation's Telemetry Data Collection and Usage Policy](https://www.linuxfoundation.org/telemetry-data-collection-and-usage-policy/).

## How is the data collected?

The above payload is sent to `https://stats.spinnaker.io/log` upon the completion of any pipeline or ad-hoc UI operation.

For release 1.18.x, telemetry is opt-in, as we test and scale the system and fine-tune the dashboards. Spinnaker administrators can help by turning **on** data collection by executing

```
hal config stats enable
```
and redeploying.

As of 1.19.0+, telemetry will be enabled by default. Spinnaker administrators can turn **off** data collection by executing

```
hal config stats disable
```
and redeploying.


## What are we doing with this data?

We're crunching the numbers and giving them back to the community in the form of dashboards (below) and access to the raw data by requesting access [here](https://groups.google.com/a/spinnaker.io/forum/#!forum/telemetry-readers) (a Google Account is required in order to access the data via Big Query).


# Dashboards

<iframe width="100%" height="1068" src="https://datastudio.google.com/embed/reporting/123CtgjFMBZF2qrwAAt7mAss50Nuh5ruh/page/ZwADB" frameborder="0" style="border:0" allowfullscreen></iframe>
