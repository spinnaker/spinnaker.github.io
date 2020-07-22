---
layout: single
title:  "Artifacts from Build Triggers"
sidebar:
  nav: reference
---

## Overview

When an external CI system triggers a pipeline, Spinnaker can use the CI build information to
inject relevant artifacts into the pipeline. The instructions here assume that you have
[set up a CI system](/setup/ci/) and are familiar with using
[property files](/guides/user/pipeline/expressions/#property-files) to pass variables from
CI builds to Spinnaker pipelines.

The extraction of artifacts from the build information is done via a Jinja template; the
template uses the trigger as context and outputs a list of artifacts to inject into the
pipeline. Spinnaker provides a set of [standard templates](#supplied-templates) to use for
artifact extraction, which users can augment with custom templates.

## Select a template

To configure Spinnaker to use a Jinja template for artifact extraction, export the
following properties from your CI build:
* `messageFormat`: the name of the Jinja template to use
* `customFormat`: `true` if `messageFormat` refers to a user-configured template;
`false` or omitted if it refers to a Spinnaker-supplied template

For example, to use the Spinnaker-provided `JAR` template, you would export the following
properties from your CI job:
```sh
messageFormat=JAR
```

The recommended way to configure artifact templates is by using the `hal config artifact templates`
 [Halyard command](/reference/halyard/commands/#hal-config-artifact-templates):
```
hal config artifact templates add <name of template> --template-path <path to the template> 
```

As an alternative, you can manually configure templates by adding the following to `igor-local.yml`:
```yaml
artifacts:
  templates:
  - name: <name of template>
    templatePath: <path to the template>
```
(Before Spinnaker 1.13, this manual configuration went into `echo-local.yml`. As of 1.13, it goes
in `igor-local.yml`.)

You can then use the configured custom template by exporting the following as properties from your
CI build:
```sh
messageFormat=<name of template>
customFormat=true
```

## Bind variables into templates

In general, artifact-extracting templates will read other properties that are exported
by the CI job. The general pattern is to export any build-specific information in the
property file and to have the Jinja template construct the artifact by looking in
`trigger.properties`.

For example, consider a Jenkins job uploads a `.jar` file to a maven repository. We might define
a custom Jinja template `custom-jar.jinja` as follows:

{% raw %}
```sh
  {
    "reference": "{{ properties.group }}-{{ properties.artifact }}-{{ properties.version }}",
    "name": "{{ properties.artifact }}-{{ properties.version }}",
    "version": "{{ properties.version }}",
    "type": "maven/file"
  }
```
{% endraw %}

We could then generate a useful artifact by having the CI job export the following:
```sh
group=test.group
artifact=test-artifact
version=123
messageFormat=custom-jar
customFormat=true
```

## Supplied templates

The templates that are supplied with Spinnaker can be found in the
[following folder](https://github.com/spinnaker/echo/tree/master/echo-pipelinetriggers/src/main/resources).

### JAR

The JAR template creates an artifact representing a JAR archive in a Maven or Ivy repository. This
template expects the following properties to be exported:
* group
* artifact
* version
* *(optional)* classifier

By default, the artifact represents an archive in a Maven repository; to create an artifact for an
archive in an Ivy repository, export the property `repotype=ivy`.
