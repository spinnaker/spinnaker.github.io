---
layout: single
title: "Plugin Compatibility Testing"
sidebar:
  nav: guides
---

{% include toc %}

A plugin can be executed inside of a Spinnaker version that is
different than the version it was compiled against. For example, a plugin
compiled against Spinnaker `1.20` might be compatible with Spinnaker versions up
to `1.23`. 

This range is important for plugin developers so that they can support users
across Spinnaker versions; it's important for plugin consumers so that they can
safely install and upgrade plugins. Fortunately, testing can resolve this compatibility range automatically.

## Integration testing

To start, you should write Spring Boot-style integration tests using 
[service test fixtures](https://github.com/spinnaker/orca/blob/master/orca-api-tck/src/main/kotlin/com/netflix/spinnaker/orca/api/test/OrcaFixture.kt).

The [Spinnaker plugin example
repositories](https://github.com/spinnaker-plugin-examples/pf4jStagePlugin/blob/master/random-wait-orca/src/test/kotlin/io/armory/plugin/stage/wait/random/RandomWaitStageIntegrationTest.kt) have examples of these kinds of tests.

These integration tests have good properties. They execute a service's `main` and 
demonstrate that a plugin can be loaded into the service at runtime. You can inject
Spring's `ApplicationContext` into your test class and attempt to retrieve the beans defined by your
plugin.

You can also use these tests to verify the end-to-end behavior of your plugin. For example, if you're writing a new stage as
a plugin, you can ask Orca's `/orchestrate` endpoint to execute a pipeline that
includes your new stage type.

## Automated compatibility testing

These integration tests demonstrate that a compiled plugin can execute inside
of a service at runtime. By executing a test multiple times but changing the
underlying service version, we can resolve which versions of Spinnaker
a plugin is compatible with.

Spinnaker's Gradle `compatibility-test-runner` plugin does exactly this: you
provide a list of Spinnaker versions; it runs your integration tests
against those versions.

Before using this Gradle plugin, check that your integration tests
depend on Spinnaker's exported Gradle platforms, which take the form `<service>-bom`. 
For example, if your test relies on `orca-api-tck`, your plugin's subproject build file should look something like this:

```groovy 
dependencies {
  // ...
  testImplementation("com.netflix.spinnaker.orca:orca-bom:<orca-version>")
  testImplementation("com.netflix.spinnaker.orca:orca-api-tck") // Don't specify a version here - it will be resolved by `orca-bom` above.
}
```

To use the test runner, configure your plugin's build files:

```groovy
// Inside root project
plugins {
  id("io.spinnaker.plugin.bundler").version("8.6.0") // Must be 8.6.0 or later.
}

spinnakerBundle {
  // ...
  compatibility {
    spinnaker = ["1.21.1", "1.22.0"] // Set of Spinnaker versions to test against.
  }
}

// Inside service extension subproject
apply plugin: "io.spinnaker.plugin.compatibility-test-runner"
```

The plugin will create a set of tasks: a set of `compatibilityTest-<subproject-name>-<spinnaker-version>` tasks, and a top-level `compatibilityTest` task that will run all of the compatibility test subtasks.

### How does it work?

The test runner dynamically creates Gradle source sets for each top-level Spinnaker version you declare 
and re-writes your test dependencies to depend on the service Gradle platform version (e.g., `com.spinnaker.netflix.orca:orca-bom`) 
that corresponds to those Spinnaker versions. It does not alter your plugin's compile or runtime classpaths. 
Your plugin compiles against version `X`; the test runner runs your plugin inside Spinnaker `Y` and `Z`.
