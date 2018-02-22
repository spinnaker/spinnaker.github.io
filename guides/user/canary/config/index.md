---
layout: single
title:  "Configuring Canary for an application"
sidebar:
  nav: guides
---

{% include toc %}


Words words Words

## Prerequisites

Canary configuration is done per application. To enable the canary configuration
UI, you must enable __Canary__ in the configuration for the application.

{% include figure
   image_path="./canary_config.png"
   caption="Enabling __Canary__ lets you configure it globally for all pipelines
   in this application."
%}

## Create a configuration

## Choose the Metrics that will Guide the canary

The metrics are the basis for passing or failing a canary. Later on, you'll
specify default thresholds to use against these metrics.


## Group metrics

Scoring thresholds are applied to metrics groups, rather than to individual
metrics.
