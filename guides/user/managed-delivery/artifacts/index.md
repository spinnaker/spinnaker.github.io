---
layout: single
title:  "Artifacts"
sidebar:
  nav: guides
redirect_from: /reference/managed-delivery/artifacts/
---

{% include toc %}


Managed Delivery supports two types of delivery artifacts: **debians** and **docker images**.

Delivery artifacts are meant to provide Spinnaker information about:
1. Where to locate the *available versions* of an artifact you care about
2. How to choose the *latest version* from a list of versions

Spinnaker needs this information to make decisions about when and how to roll out new versions as they become available. Artifacts are defined with name, type, and version strategy information.

## Debians

** Warning: this is Netflix specific. Interested in contributing? Reach out to us in the #sig-spinnaker-as-code slack channel. **

All debians at Neflix are named and compared in the same way. 
For example, a debian might look like this:

```
# package name is keel
keel_0.353.0-h290.ae13adb_all.deb
```

We compare the semantic version located after the `packagename_` (`keel_` in this example) and before the `-h`.

Debians have status information on them. A debian can have any of these statuses: 

- snapshot
- candidate
- release

which are parsed from the semantic version of the debian.


To define a debian artifact for use with your delivery config, you'll do something like this:

```yaml
artifacts:
- name: keeldemo
  type: deb
  statuses: ["RELEASE"] # This is optional
  reference: my-debian-artifact # optional human-readable reference to be used elsewhere in the config, defaults to artifact name
```

If you provide status information, you limit the possible artifacts that can be deployed to your environment. 
This is useful if you have a test environment that only snapshots should be deployed to, or a prod environment that only release artifacts should be deployed to.

Status information is optional. If you leave it out, versions with *any* status will be considered eligible for deployment into your environment.

## Docker Images

Docker versioning is denoted by the tag value.
At Netflix, there are two main ways versions are structured:

```
# branch-jenkinsJob.commitSha
master-h5.5a52206

# semver-jenkinsJob.commitSha
v1.12.1-h1159.b839a00
``` 


### Basic Configuration

In order to support the different ways of doing versioning, docker artifacts have some more config options. 
The basic structure is like this:

```yaml
artifacts:
- name: emburns/spin-titus-demo
  type: docker
  reference: my-docker-artifact # optional human-readable reference to be used elsewhere in the config, defaults to artifact name
  tagVersionStrategy: branch-job-commit-by-job
```

**Note that just like with pipelines, we don't support using a constantly updated `latest` tag.**

The key difference here is the `tagVersionStrategy` field, which indicates how we should sort a list of tags to choose the most recent software version.

The `tagVersionStrategy` Options:

- `increasing-tag`: your tags are all integers, and we should choose the highest integer as the latest

- `semver-tag`: your tags are a single semantic version (with or without a `v` prefix), and we should choose the largest semantic version

- `branch-job-commit-by-job`: your tags are of the format "branch-jenkinsJob.commitSha" (like `master-h5.5a52206`), and we should choose the latest based on the highest jenkins job number (`h5` in this example)

- `semver-job-commit-by-job`: your tags are of the format "semver-jenkinsJob.commitSha" (like `v1.12.1-h1159.b839a00`), and we should choose the latest based on the highest jenkins job number (`h1159` in this example)

- `semver-job-commit-by-semver`: your tags are of the format "semver-jenkinsJob.commitSha" (like `v1.12.1-h1159.b839a00`), and we should choose the latest based on the largest semver (`v1.12.1` in this example)


### Advanced Configuration

If none of these work for you, you can provide your own regex to capture something to compare (using a [capture group](https://www.regular-expressions.info/refcapture.html)).
You must create a regex that parses valid tags and captures a string from them which can be compared _either_ as an increasing number or a semantic version.
The capture group must only capture one thing (you can't have multiple capture groups).

For example, let's say your tags look like `master-h5.5a52206` and we didn't have a built in strategy for this style. 
You'd define an artifact like this:

```yaml
artifacts:
- name: emburns/spin-titus-demo
  type: docker
  reference: my-docker-artifact # optional human-readable reference to be used elsewhere in the config, defaults to artifact name
  tagVersionStrategy: increasing-tag
  captureGroupRegex: ^master-h(\d+).*$
```

The regex capture group (the parens in the regex expression) indicates that out of the string tag we should grab any numbers after the `h` and before the `.`.
The version strategy indicates that we will take the result of the capture group and compare it as an increasing number.
