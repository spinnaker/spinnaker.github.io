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
spin pipeline-templates plan --file <path to pipeline config>

{
  "application": "my-spinnaker-app"
  "stages": [...] # Evaluated pipeline config based on template config values.
}
```

...where `<path to pipeline config>` points to the [file you
created](/guides/user/pipeline/pipeline-templates/create/) when you
instantiated a pipeline based on the template.


## Now what do I do with it?

Use the output JSON to visualize what your resulting pipeline config will look
like after you instantiate it. When you're ready, you can save it as a pipeline
in Spinnaker:

```bash
spin pipeline save --file <path to pipeline config>
```

## Next steps

* [Create a pipeline from the template](/guides/user/pipeline/pipeline-templates/instantiate/)

