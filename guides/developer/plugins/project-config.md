---
layout: single
title: "Plugin Project Configuration"
sidebar:
  nav: guides
redirect-from:
  - /guides/developer/plugin-creators/project-config/
---


{% include toc %}

Plugins are an evolving feature.  The easiest way to set up a new plugin
project is to copy one of the
[spinnaker-plugin-examples](https://github.com/spinnaker-plugin-examples)
projects that most closely resembles what you want to do.

### Gradle configuration

Some important aspects of your project's gradle build:

#### gradle.properties

Organizing these values into gradle.properties is optional, but these versions are very much mandatory.

```properties
spinnakerGradleVersion=8.10.1
pf4jVersion=3.2.0
korkVersion=7.99.1
orcaVersion=2.19.0-20210209140018
kotlinVersion=1.3.50
```

Note that managing the version of your plugin here (`version=1.2.3`) requires
modifying this file for each release. There are fancier ways (the example
project uses a git tag strategy and additional gradle plugins) but those are
outside the scope of this documentation.

#### Top-level build.gradle

```gradle
// file: my-plugin/build.gradle

buildscript {
  repositories {
    mavenCentral()
  }
}

// (1):
plugins {
  id("com.moowork.node").version("1.3.1").apply(false)
  id("io.spinnaker.plugin.bundler").version("$spinnakerGradleVersion")
  id("com.palantir.git-version").version("0.12.2")
  //... other plugins you might be using
}

// (2):
apply plugin: "io.spinnaker.plugin.bundler"
spinnakerBundle {
  pluginId = "Armory.RandomWaitPlugin"
  description = "An example of a PF4J based plugin, that provides a new stage."
  provider = "https://github.com/spinnaker-plugin-examples"
  version = rootProject.version
}

// (3):
version = normalizedVersion()

subprojects {
  group = "io.armory.plugin.manifest"
  version = rootProject.version
}

String normalizedVersion() {
  String fullVersion = gitVersion()
  String normalized = fullVersion.split("-").first()
  if (fullVersion.contains("dirty")) {
    return "$normalized-SNAPSHOT"
  } else {
    return normalized
  }
}
```

**Notes:**
1. The `plugins` block imports the node plugin but does not apply it. This
   plugin is needed by the ui-extension to build assets. It also imports
   the spinnaker-extensions gradle tooling.
1. At the top level we apply the `io.spinnaker.plugin.bundler` to define the
   name of the plugin bundle this project is producing along with bundle
   metadata.
1. Utility methods for determining the latest version to use when building
   release distributions, derived from git tags.

#### UI-extension build.gradle

To build a UI extension with the base conventions, the only thing necessary is
applying the `io.spinnaker.plugin.ui-extension` plugin.

```gradle
// file: my-plugin/my-plugin-deck/build.gradle
apply plugin: "io.spinnaker.plugin.ui-extension"
```

This plugin will provide tasks for assembling and creating release distributions
that are automatically called from the parent Gradle file when creating
release builds.

#### Service extension build.gradle

Here are the basic things your service-extension gradle build needs. Note that
the example project includes a bunch of additional configuration to configure
kotlin for the plugin. The configuration below strips that out to just include
the basic gradle configuration necessary for a JVM plugin, if you wish to
develop plugins in kotlin refer to the gradle build from the example project.

```gradle
// file: my-plugin/my-plugin-orca/build.gradle

// (1):
apply plugin: "io.spinnaker.plugin.service-extension"
apply plugin: "maven-publish"

// (2):
sourceCompatibility = 1.8
targetCompatibility = 1.8

dependencies {
  // (3):
  annotationProcessor("org.pf4j:pf4j:$pf4jVersion")

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
4. The plugin APIs are marked as `compileOnly` so as to not include them in the resulting plugin jar. These dependencies are loaded from the service's classloader, not the plugin classloader.
5. You can include additional dependencies that your plugin requires. These dependencies will be bundled into the plugin and in a private classloader for the plugin.
6. The `spinnakerPlugin` block is used to generate plugin and bundle metadata. The `serviceName` is the spinnaker service this plugin extends (and should match the service api dependency brought in in `(4)` above).

### IntelliJ Configuration

With the gradle configuraton above, you should be able to import your plugin into IntelliJ as a project.

#### UI-extension IDE configuration

> Help us improve this section by submitting a pull request!

#### Service-extension IDE configuration

> Help us improve this section by submitting a pull request!

##### Plugin debugging in a local service

If you have a local instance of a host service (in the pf4jStagePlugin example this is `orca`) running, you can link your plugin into that service with a `plugin-ref` that points to your local development workspace.

There are two options, depending on how you run the host service:

###### Running the host service in the IDE

If you have the ability to run a service locally in IntelliJ (the configuration for that is outside the scope of this document), then you can add configure your IntelliJ project with both the host service and your plugin in the same workspace.

Open the IntelliJ project you have configured for the host service, click the `+` button on the Gradle tab, and navigate to your plugin project's build.gradle. This will include the plugin project in the workspace.

###### Attaching to a remote JVM process for the host service

You can debug a service extension in the IDE, provided you have an instance of
the host service to attach a debugger to, and that the host service shares a
filesystem with your plugin development workspace.

In your plugin project in IntelliJ, in the run configurations, add a configuration of type Remote.

Select "Attach to a remote JVM"

In use module classpath, select the main classpath from the service-extension plugin (helloworld-orca.main) in the example project.

Copy the command-line arguments for the JVM from this dialog, and ensure however you are launching the host service locally that it gets those JVM arguments.

##### Linking the plugin-ref to the host service

When you build your plugin project with gradle, it will produce a `.plugin-ref` file in the build/ directory for the plugin. You only need to do this once initially, and if your plugin dependencies are changed to regenerate it.

Once you have that file generated, navigate to the `plugins` directory for the host service, wherever you are running it. You can then create a symlink to the `.plugin-ref` file, and this will cause the host service to see your plugin and load the classes from your development workspace when the host service starts up.

For the example project:
```
$ cd /path/to/orca/plugins
$ ln -sf /path/to/dev/workspaces/spinnaker-plugin-helloworld/helloworld-orca/build/orca.plugin-ref
```

Now, when you attach your debugger to the host services, any breakpoints in your plugin code will be hit and you can step through them in your IDE, evaluate expressions, etc.
