---
layout: single
title:  "pf4jStagePlugin Deployment Example"
sidebar:
  nav: guides
---

{% include alpha version="1.19.4" %}

{% include toc %}

# Requirements
* Spinnaker 1.19.4
* Halyard 1.33
* pf4jStagePlugin 1.0.16

# Caveats with Halyard 1.33

* Halyard does not update the plugin configuration when you run `hal plugins edit`. You must manually update the `.hal\config` entry.
* Halyard does not tell Orca where to look for the plugin. Navigate to `.hal/default/profiles` and create an `orca-local.yml` file with this content:

	```yaml
    spinnaker.extensibility.plugins-root-path: /opt/orca/plugins
	```

# Steps

1. Download  [`RandomWaitStageIndex.js`](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin/releases/download/v1.0.16/RandomWaitStageIndex.js) and move the file to a publicly accessible location that supports CORs, such as an AWS S3 bucket.

1. Create the `orca-local.yml` file (see above)

1. Configure the plugin repository and redeploy Spinnaker

	```shell
	hal plugins repository add spinnaker-plugin-examples \
	  --url=https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/repositories.json
	hal deploy apply
	```

1. Add the pf4jStagePlugin

	```shell
	hal plugins add Armory.RandomWaitPlugin \
	  --enabled=true \
	  --extensions=armory.randomWaitStage \
	  --version=1.0.17 \
	  --ui-resource-location=https://aimeeu-plugins.s3.us-east-2.amazonaws.com/RandomWaitStageIndex.js
	```

1. Configure the plugin by editing its entry in the `hal config`.

	Base configuration:

	```yaml
   spinnaker:
    extensibility:
      plugins:
        Armory.RandomWaitPlugin:
          id: Armory.RandomWaitPlugin
          enabled: true
          uiResourceLocation: https://aimeeu-plugins.s3.us-east-2.amazonaws.com/RandomWaitStageIndex.js
          version: 1.0.16
          extensions:
            armory.randomWaitStage:
              id: armory.randomWaitStage
              enabled: true
              config: {}
      repositories:
        spinnaker-plugin-examples:
          id: spinnaker-plugin-examples
          url: https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/repositories.json
	```

	Add the `defaultMaxWaitTime` to the `config` list.

	```yaml
    extensions:
      armory.randomWaitStage:
        id: armory.randomWaitStage
        enabled: true
        config:
          defaultMaxWaitTime: 60
	```


1. Redeploy Spinnaker

	```shell
	hal deploy apply
	```
