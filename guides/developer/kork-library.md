---
layout: single
title:  "Kork Library"
sidebar:
  nav: guides
redirect_from: /docs/kork-library-dev
---

{% include toc %}

## Introduction

[Kork](https://github.com/spinnaker/kork) is a common library used across multiple Spinnaker components. A component uses a specific version of Kork depending on the last time that component's [spinnaker-dependencies](https://github.com/spinnaker/spinnaker-dependencies) version was updated. This guide is meant for developers who need to make changes to Kork, test those changes locally in the component that relies on those changes, and deploy those changes once they've been submitted.

## Local Development Cycle
### Kork

1. Make desired changes to `kork` module locally.
2. Invoke `$ ./gradlew publishToMavenLocal`.
3. Make note of the version printed:

```
$ ./gradlew publishToMavenLocal
Inferred project: kork, version: 0.1.0-SNAPSHOT
```

### Component (Gate, Orca, Clouddriver, etc.)

With Kork now in your local maven repository (`~/.m2/` by default), we must make the component pickup this new version.

1.  In the component's `build.gradle` file, add the following inside the `allprojects` block:

```
repositories {
  mavenLocal()
}
```

2. Inside the `allprojects.configurations.all.resolutionStrategy` block, add this, replacing the version with the version printed from the `publishToMavenLocal` task:

    ```
    eachDependency {
      if (it.requested.group == 'com.netflix.spinnaker.kork') it.useVersion '0.1.0-SNAPSHOT'
    }
    ```

3. Voila! The component now uses your locally source, hand-crafted, artisan Kork library!

## Release Process

### Kork
1. Create and submit a PR for your Kork changes.
2. Create a new Kork [release](https://github.com/spinnaker/kork/releases) that follows the version naming convention. Make note of this version number.
3. Monitor the Travis CI [build](https://travis-ci.org/spinnaker/kork) and confirm the new packages have been deployed to [Bintray](https://bintray.com/spinnaker/spinnaker/kork/view).

### Spinnaker-Dependencies
1. Create and submit a new PR to the [spinnaker-dependencies.yml](https://github.com/spinnaker/spinnaker-dependencies/blob/master/src/spinnaker-dependencies.yml) file that updates the Kork library to your new version.
2. Create a new spinnaker-dependencies [release](https://github.com/spinnaker/spinnaker-dependencies/releases) that follows the version naming convention. Again, make note of this version number.
3. Monitor the Travis CI [build](https://travis-ci.org/spinnaker/spinnaker-dependencies) and confirm the new packages have been deployed to [Bintray](https://bintray.com/spinnaker/spinnaker/spinnaker-dependencies/view).

### Component
1. Edit your component's `build.gradle` file to update the `allprojects.spinnaker.depenciesVersion` to the newly released `spinnaker-dependencies` version.

    ```
    spinnaker {
      dependenciesVersion = "0.34.0"
    }
    ```
2. Build and test locally to ensure all of the new library versions pulled in haven't broken anything

    ```
    $ ./gradlew test
    ```

3. Create a submit a PR to the component that includes bumping this version number and any build/test fixes.
4. Create and submit a PR for the feature that relied on the Kork changes.

