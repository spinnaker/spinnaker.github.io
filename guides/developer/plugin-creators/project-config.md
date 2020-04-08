---
layout: single
title: "Plugin Project Configuration"
sidebar:
  nav: guides
---

{% include alpha version="1.19.4" %}
> This guide is a work in progress.

{% include toc %}


# Project Configuration

Keep the following recommendations and requirements in mind: - We recommend
making the project a Gradle project. There is Gradle tooling to support plugin
development. - You can add any dependencies you need to make your plugin
successful.. *TODO-CF* this is almost certainly a lie when it comes to things
that conflict with the dependencies in the compileOnly scope...

## Gradle configuration

Some important aspects of your project's gradle build:

### gradle.properties

This is optional, but externalizes the versions of tooling and API dependencies
from your build script.

```
spinnakerGradleVersion=7.5.2
pf4jVersion=3.2.0
korkVersion=7.30.0
orcaVersion=8.2.0
version=1.2.3
```

Note that managing the version of your plugin here (`version=1.2.3`) requires
modifying this file for each release. There are fancier ways (the example
project uses a git tag strategy and additional gradle plugins) but those are
outside the scope of this documentation.

### Top-level build.gradle

```
// (1):
buildscript {
  repositories {
    maven { url "https://dl.bintray.com/spinnaker/gradle/" }
  }
  dependencies {
    classpath("com.netflix.spinnaker.gradle:spinnaker-extensions:$spinnakerGradleVersion")
  }
}

// (2):
plugins {
  //... other plugins you might be using
  id("com.moowork.node").version("1.3.1").apply(false)
}

// (3):
apply plugin: "io.spinnaker.plugin.bundler"
spinnakerBundle {
  pluginId = "Armory.RandomWaitPlugin"
  description = "An example of a PF4J based plugin, that provides a new stage."
  provider = "https://github.com/spinnaker-plugin-examples"
  version = rootProject.version
}
```

**Notes:**
1. The `buildscript` block brings in the spinnaker-extensions gradle tooling, which includes plugins for creating a bundle, ui-extension, and service-extension.
2. The `plugins` block imports the node plugin but does not apply it. This plugin is needed by the ui-extension to build the us assets.
3. At the top level we apply the `io.spinnaker.plugin.bundler` to define the name of the plugin bundle this project is producing along with bundle metadata.

### UI-extension build.gradle

To build a UI extension with the base conventions, the only thing necessary is
applying the `io.spinnaker.plugin.ui-extension` plugin.

**TODO** document what the ui-extension plugin supplies / supports. Maybe some of that is below?

```
apply plugin: "io.spinnaker.plugin.ui-extension"
```

### Service extension build.gradle

Here are the basic things your service-extension gradle build needs. Note that
the example project includes a bunch of additional configuration to configure
kotlin for the plugin. The configuration below strips that out to just include
the basic gradle configuration necessary for a JVM plugin, if you wish to
develop plugins in kotlin refer to the gradle build from the example project.

```
// (1):
apply plugin: "io.spinnaker.plugin.service-extension"
apply plugin: "maven-publish"

// (2):
sourceCompatibility = 1.8
targetCompatibility = 1.8

dependencies {
  // (3):
  annotationProcessor("org.pf4j:pf4j:$pf4jVersion)

  // (4):
  compileOnly("com.netflix.spinnaker.kork:kork-plugins-api:$korkVersion")
  compileOnly("com.netflix.spinnaker.orca:orca-api:$orcaVersion")

  // (5):
  // implementation("com.something.my.plugin.needs:dependency:version")
}

// (6):
spinnakerPlugin {
  serviceName = "orca"
  pluginClass = "io.armory.plugin.stage.wait.random.RandomWaitPlugin"
}
```

**Notes:**
1. The `io.spinnaker.plugin.service-extension` and `maven-publish` are used for plugin bundling
   and metadata generation.
2. Spinnaker services require JDK 1.8 compatible bytecode.
3. Enable pf4j annotation processing to build plugin extension metadata
4. The plugin APIs are marked as `compileOnly` so as to not include them in the resulting plugin jar. These dependencies must be loaded from the service's classloader, not the plugin classloader.
5. You can include additional dependencies that your plugin requires. These dependencies will be bundled into the plugin and in a private classloader for the plugin.
6. The `spinnakerPlugin` block is used to generate plugin and bundle metadata. The `serviceName` is the spinnaker service this plugin extends (and should match the service api dependency brought in in `(4)` above).

## IntelliJ Configuration

With the gradle configuraton above, you should be able to import your plugin into IntelliJ as a project.

### UI-extension IDE configuration

**TODO**

### Service-extension IDE configuration

#### Plugin debugging in a local service

If you have a local instance of a host service (in the plugin example this is `orca`) running, you can link your plugin into that service with a `plugin-ref` that points to your local development workspace.

There are two options, depending on how you run the host service:

##### Running the host service in the IDE

If you have the ability to run a service locally in IntelliJ (the configuration for that is outside the scope of this document), then you can add configure your IntelliJ project with both the host service and your plugin in the same workspace.

Open the IntelliJ project you have configured for the host service, click the `+` button on the Gradle tab, and navigate to your plugin project's build.gradle. This will include the plugin project in the workspace.

##### Attaching to a remote JVM process for the host service

You can debug a service extension in the IDE, provided you have an instance of
the host service to attach a debugger to, and that the host service shares a
filesystem with your plugin development workspace.

In your plugin project in IntelliJ, in the run configurations, add a configuration of type Remote.

Select "Attach to a remote JVM"

In use module classpath, select the main classpath from the service-extension plugin (helloworld-orca.main) in the example project.

Copy the command-line arguments for the JVM from this dialog, and ensure however you are launching the host service locally that it gets those JVM arguments.

#### Linking the plugin-ref to the host service

When you build your plugin project with gradle, it will produce a `.plugin-ref` file in the build/ directory for the plugin. You only need to do this once initially, and if your plugin dependencies are changed to regenerate it.

Once you have that file generated, navigate to the `plugins` directory for the host service, wherever you are running it. You can then create a symlink to the `.plugin-ref` file, and this will cause the host service to see your plugin and load the classes from your development workspace when the host service starts up.

For the example project:
```
$ cd /path/to/orca/plugins
$ ln -sf /path/to/dev/workspaces/spinnaker-plugin-helloworld/helloworld-orca/build/orca.plugin-ref
```

Now, when you attach your debugger to the host services, any breakpoints in your plugin code will be hit and you can step through them in your IDE, evaluate expressions, etc.
