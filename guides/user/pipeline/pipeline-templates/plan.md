---
layout: single
title:  "Visualize a Hydrated Pipeline"
sidebar:
  nav: guides
---

{% include toc %}

You can use `spin` CLI to visualize a pipeline created from a pipeline template
without actually instantiating one.

When you do this, you are creating JSON output that looks like regular pipeline
JSON (plus the template reference and hydrated variables), but you're not
creating the actual pipeline in Spinnaker.

## Using `spin pt plan`

```bash
spin pipeline-templates plan --config <path to pipeline config>

{
  "application": "my-spinnaker-app"
  "stages": [...] # Evaluated pipeline config based on template config values.
}
```

...where `<path to pipeline config` points to the [file you
created](/guides/user/pipeline/pipeline-templates/create/) when you
instantiated a pipeline based on the template.


## Now what do I do with it?