---
layout: single
title:  "pf4jStagePlugin Deployment Example"
published: true
sidebar:
  nav: guides
---

_Note: Spinnaker 1.20.6 and 1.21+ support plugins with both server and frontend components. Spinnaker 1.19.x does not support frontend plugins due to a bug in Deck._

{% include toc %}

In this guide, you deploy the `pf4jStagePlugin` plugin from the [spinnaker-plugin-examples](https://github.com/spinnaker-plugin-examples/examplePluginRepository) repository.

 By implementing Orca's SimpleStage PF4J extension point, the `pf4jStagePlugin` creates a custom pipeline stage that waits a random number of seconds before signaling success. This plugin consists of a `random-wait-orca` Kotlin server component and a `random-wait-deck` React UI component that uses the rollup.js plugin library.

## Requirements

This guide was tested with the following software versions:

* Spinnaker 1.20.6 and 1.21+
* Halyard 1.36
* pf4jStagePlugin 1.1.14

## Add the plugin repository

```bash
hal plugins repository add examplePluginsRepo \
  --url=https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/plugins.json
```

This adds the following YAML to your Halconfig:

```yaml
spinnaker:
  extensibility:
    plugins: {}
    repositories:
      examplePluginsRepo:
        id: examplePluginsRepo
        url: https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/plugins.json
```

## Add the plugin

```bash
 hal plugins add Armory.RandomWaitPlugin --version=1.1.14 \
   --enabled=true --extensions=armory.randomWaitStage
 ```

Next, configure the plugin. Edit your Halconfig to add the `defaultMaxWaitTime` in the `config` section:

```yaml
spinnaker:
  extensibility:
    plugins:
      Armory.RandomWaitPlugin:
        id: Armory.RandomWaitPlugin
        enabled: true
        version: 1.1.14
        extensions:
          armory.randomWaitStage:
            id: armory.randomWaitStage
            enabled: true
            config:
              defaultMaxWaitTime: 60
    repositories:
      examplePluginsRepo:
        id: examplePluginsRepo
        url: https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/plugins.json
```


## Add `deck-proxy` to gate-local.yml

Beginning in Spinnaker 1.20, Gate needs to know where to get any plugin that has a Deck component. If your plugin is backend only, you do not need to modify `gate-local.yml`.

You can create or find `gate-local.yml` in the directory where Halyard stores local config files. This is usually `~\.hal\default\profiles` on the machine where Halyard is running. Add the following snippet:

```yaml
spinnaker:
   extensibility:
     deck-proxy:
       enabled: true
       plugins:
         Armory.RandomWaitPlugin:
           enabled: true
           version: 1.1.14
       repositories:
         examplePluginsRepo:
           url: https://raw.githubusercontent.com/spinnaker-plugin-examples/examplePluginRepository/master/plugins.json
```

The plugin and repository information is a subset of the entries in your Halconfig.

## Redeploy Spinnaker

```bash
hal deploy apply
```

## Access the RandomWait plugin in the UI

The RandomWait stage appears in the **Type** select list when you create a new Pipeline stage.

{% include image-caption.html url="/assets/images/guides/user/plugins/deploy-example/randomWaitTypeUI.png" caption="Random Wait stage in Type select list" %}

{% include image-caption.html url="/assets/images/guides/user/plugins/deploy-example/randomWaitStageUI.png" caption="Random Wait stage after it has been selected and the configuration panel is visible." %}


## Troubleshooting

If the plugin doesn't appear in the **Type** select list, check the following logs:

* Orca, for the plugin backend

  You should see output similar to this when the plugin has been successfully loaded:

  ```bash
  2020-07-02 16:12:43.284  INFO 1 --- [           main] com.netflix.spinnaker.orca.Main          : [] Starting Main v1.0.0 on spin-orca-7466444f64-cg5gd with PID 1 (/opt/orca/lib/orca-web.jar started by spinnaker in /)
  2020-07-02 16:12:54.691  INFO 1 --- [           main] org.pf4j.DefaultPluginManager            : [] PF4J version 3.2.0 in 'deployment' mode
  2020-07-02 16:12:59.088  INFO 1 --- [           main] .k.p.u.r.s.LatestPluginInfoReleaseSource : [] Latest release version '1.1.14' for plugin 'Armory.RandomWaitPlugin'
  2020-07-02 16:12:59.091  INFO 1 --- [           main] .k.p.u.r.s.SpringPluginInfoReleaseSource : [] Spring configured release version '1.1.14' for plugin 'Armory.RandomWaitPlugin'
  2020-07-02 16:12:59.103  INFO 1 --- [           main] p.u.r.s.PreferredPluginInfoReleaseSource : [] No preferred release version found for 'Armory.RandomWaitPlugin'
  2020-07-02 16:12:59.620  INFO 1 --- [           main] org.pf4j.util.FileUtils                  : [] Expanded plugin zip 'orca.zip' in 'orca'
  2020-07-02 16:12:59.643  INFO 1 --- [           main] org.pf4j.util.FileUtils                  : [] Expanded plugin zip 'Armory.RandomWaitPlugin-pf4jStagePlugin-v1.1.14.zip' in 'Armory.RandomWaitPlugin-pf4jStagePlugin-v1.1.14'
  2020-07-02 16:12:59.652  INFO 1 --- [           main] org.pf4j.util.FileUtils                  : [] Expanded plugin zip 'orca.zip' in 'orca'
  2020-07-02 16:12:59.653  INFO 1 --- [           main] org.pf4j.AbstractPluginManager           : [] Plugin 'Armory.RandomWaitPlugin@unspecified' resolved
  2020-07-02 16:12:59.658  INFO 1 --- [           main] org.pf4j.AbstractPluginManager           : [] Start plugin 'Armory.RandomWaitPlugin@unspecified'
  2020-07-02 16:12:59.659  INFO 1 --- [           main] i.a.p.s.wait.random.RandomWaitPlugin     : [] RandomWaitPlugin.start()
  ```

  If you see log output similar to

  ```bash
  Plugin 'Armory.RandomWaitPlugin@unspecified' requires a minimum system version of orca>=8.0.0, and you have 1.0.0
  2020-07-01 16:52:13.170  WARN 1 --- [           main] org.pf4j.AbstractPluginManager           : [] Plugin '/opt/orca/plugins/Armory.RandomWaitPlugin-pf4jStagePlugin-v1.1.13/orca' is invalid and it will be disabled
  ```

  ...your plugin doesn't work with the version of Spinnaker you are using. Contact the plugin's developer.

  If you see `this.pluginId must not be null`, the plugin manifest file is missing values. Contact the plugin's developer.

* Gate, for the plugin frontend

  You should see output similar to this when the plugin has been successfully loaded:

  ```bash
  2020-07-02 16:12:51.994  INFO 1 --- [           main] .k.p.u.r.s.LatestPluginInfoReleaseSource : Latest release version not found for plugin 'Armory.RandomWaitPlugin'
  2020-07-02 16:12:51.997  INFO 1 --- [           main] .k.p.u.r.s.SpringPluginInfoReleaseSource : Spring configured release version '1.1.14' for plugin 'Armory.RandomWaitPlugin'
  2020-07-02 16:12:52.002  INFO 1 --- [           main] p.u.r.s.PreferredPluginInfoReleaseSource : No preferred release version found for 'Armory.RandomWaitPlugin'
  2020-07-02 16:12:52.644  INFO 1 --- [           main] org.pf4j.util.FileUtils                  : Expanded plugin zip 'Armory.RandomWaitPlugin-pf4jStagePlugin-v1.1.14.zip' in 'Armory.RandomWaitPlugin-pf4jStagePlugin-v1.1.14'
  2020-07-02 16:12:52.645  WARN 1 --- [           main] c.n.s.k.p.bundle.PluginBundleExtractor   : Downloaded plugin bundle 'Armory.RandomWaitPlugin-pf4jStagePlugin-v1.1.14.zip' does not have plugin for service: gate
  ```

  If Gate can't find your frontend plugin, make sure the entries in `gate-local.yml` are correct.
