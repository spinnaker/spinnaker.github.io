---
layout: single
title:  "Managed Pipeline Templates"
sidebar:
  nav: guides
---

{% include toc %}

This codelab provides an introduction to the Managed Pipeline Templates feature
of Spinnaker. We'll be creating a basic template that can be used to bake an AMI
and deploy to AWS and explore how to use the template within Spinnaker.

# Prerequisites

- Have [Pipeline Templates enabled][enable-pipeline-templates] in Orca
- (Optional) Familiarize yourself with the [Pipeline Templates Spec][spec]
- Download the latest release of [Tiller][tiller-repo]

If you have not already enabled pipeline templates, you can do so by enabling it
in `orca.yml`:

```yaml
pipelineTemplate:
  enabled: true
```

# Writing the Template

First, here's the template, we'll break it down below.

{% raw %}
```yaml
schema: "1"
id: defaultDeploy                                                            (1)
protect: false
metadata:                                                                    (2)
  name: Default Deploy
  description: The default deployment pipeline for Acme Corp applications.
  owner: example@example.com
  scopes: [global]
variables:
- name: regions
  description: The AWS regions to deploy into
  type: list
- name: clusters
  description: |
    A key-value map of cluster-specific configurations to deploy, where
    the key is the stack name, the value being a sub-map of its configuration.
  type: object
  example: |                                                                 (3)
    test:
      region: us-west-2
      availabilityZones:
      - us-west-2a
      - us-west-2b
      - us-west-2c
      instanceType: t2.micro
configuration: {}
stages:                                                                      (4)
- id: bake
  type: bake
  config:
    baseLabel: candidate
    baseOs: xenial
    cloudProviderType: aws
    enhancedNetworking: false
    extendedAttributes: {}
    overrideTimeout: true
    package: acmedemo
    regions: |                                                               (5)
      {% for region in regions %}
      - "{{ region }}"
      {% endfor %}
    sendNotifications: false
    showAdvancedOptions: false
    stageTimeoutMs: 900000
    storeType: ebs
    user: example@example.com
    vmType: hvm
- id: deploy
  type: deploy
  dependsOn:
  - bake
  config:
    clusters: |
      {% for stack, cc in clusters.items() %}
      - {% module awsDeployCluster stack=stack, config=cc %}                 (6)
      {% endfor %}

modules:
- id: awsDeployCluster
  variables:
  - name: stack
  - name: config
  definition:
    account: "{{ config.account|default('test') }}"
    application: "{{ application }}"
    availabilityZones: |
      {{ region }}:
      {% for az in config.availabilityZones %}
      - {{ az }}
      {% endfor %}
    cloudProvider: aws
    cooldown: 10
    ebsOptimized: false
    freeFormDetails: null
    healthCheckGracePeriod: 600
    healthCheckType: EC2
    iamRole: "{{ config.iamRole|default('BaseIAMRole') }}"
    instanceMonitoring: false
    instanceType: "{{ config.instanceType }}"
    interestingHealthProviderNames:
    - Amazon
    keyPair: "{{ config.keyPair|default('acme-master-keypair') }}"
    provider: aws
    securityGroups: []
    stack: "{{ stack }}"
    strategy: redblack
    maxRemainingAsgs: 2
    useSourceCapacity: true
    scaleDown: true
    capacity:
      desired: "{{ config.desiredCapacity|default(1) }}"
      max: "{{ config.maxCapacity|default(1) }}"
      min: "{{ config.minCapacity|default(1) }}"
    loadBalancers:
    - "{{ application }}-frontend"
    subnetType: acmeInternal
    suspendProcesses: []
    tags: {}
    targetHealthyDeployPercentage: 100
    terminationPolicies:
    - Default
    useAmiBlockDeviceMappings: false
```
{% endraw %}

It's a lot of configuration: It's actually a close representation to the data
stored in a normal pipeline, but expressed as YAML instead of JSON. Let's review
the note tags:

1. The template `id` is a (globally unique) way to reference a template while
   creating a pipeline. We'll later create a pipeline that references this.
2. The Spinnaker UI supports creating a Pipeline from a Template, which will
   pull this information to give better context about its purpose. The `scopes`
   list is used to determine what apps can see the template. Global will be
   available to any app, but if you defined `foo`, it'd be explicitly available
   to the `foo` Spinnaker application.
3. Template variables can be used throughout a template (or its children) and
   support a variety of types, an object (map) is especially useful while
   invoking modules, but isn't self-documenting. It's best practice to provide
   an example so you can lead usage of the variables correctly.
4. Template stages are defined as a list, but can produce any stage graph that
   you normally could through the UI. Stages can fork, join and even inject
   themselves into parent template graphs.
5. Many parts of the Pipeline Template syntax supports Jinja, in this specific
   case, we're looping over a list of regions to determine what AWS regions to
   bake AMIs in.
6. Another example of Jinja, one that is invoking a module, a reusable block of
   configuration, with the object variable defined in `(3)`. You'll notice in

# Publishing into Spinnaker

Once a template has been written, it needs to be published somewhere before it
can be used. Spinnaker supports a few different options out of the box for
Template Loaders:

* `file`: Load a pipeline template off the machine running Orca.
* `http`: Load a pipeline template from an unauthenticated HTTP resource.
* `spinnaker`: Load a pipeline template from Spinnaker itself.

In this section, we'll focus on the recommended loader, `spinnaker`, as it
provides the greatest gamut of features and flexibility. To publish into 
Spinnaker, we'll use [Roer][roer-repo], a CLI app for Spinnaker that has
commands for interacting with Pipeline Templates.

```
$ export SPINNAKER_API=https://api.spinnaker.example
$ roer pipeline-template publish deployRoot.yml
```

Once published into Spinnaker, you will be able to create Pipelines extending
this template. 

# Creating & Running a Pipeline from a Template

While you can create Pipelines extending from Templates via the UI, this guide 
will use a file-based configuration, so you can store your Pipelines alongside 
your application, to be updated via the build process.

First, the configuration:

```yaml
schema: "1"
id: myAppConfig
pipeline:
  application: myapp                                                         (1)
  name: Bake & Deploy to Test
  template:
    source: spinnaker://defaultDeploy                                        (2)
  variables:                                                                 (3)
    regions:
    - us-west-2
    clusters:
      test:
        region: us-west-2
        availabilityZones:
        - us-west-2a
        - us-west-2b
        - us-west-2c
        instanceType: t2.micro
```

1. The name of the application within Spinnaker, as well as the name of the 
   Pipeline itself, directly below.
2. The template, using the `spinnaker` loader, and targeting the `defaultDeploy`
   template ID we defined earlier.
3. An enumeration of the variable bindings that the Pipeline will need to compile
   the template.

Let's say we save this into the app's repository as `spinnaker-test-deploy.yml`,
we'll need to make sure any time we build the project, its configuration is
updated in Spinnaker. Again, we'll turn to [Roer][roer-repo].

```
$ export SPINNAKER_API=https://api.spinnaker.example
$ roer pipeline-configuration save spinnaker-test-deploy.yml
```

Now, if you were to go into the UI, you'd able to run your templatized Pipeline!

# Next Steps

This was a very basic introduction into Pipeline Templates. There's a lot more
features that weren't covered, such as inheritance, stage injections, template
partials, inheritance control, etc. You can learn more via the [Pipeline Template Spec][spec].

From here, it might be best to take a look at some real-world template examples.
The Spinnaker project has a public GitHub [repository for sharing templates][templates-repo].

[enable-pipeline-templates]: [/setup/features/managed-pipeline-templates/]
[spec]: [https://github.com/spinnaker/dcd-spec/blob/master/PIPELINE_TEMPLATES.md]
[roer-repo]: [github.com/spinnaker/roer]
[templates-repo]: [https://github.com/spinnaker/pipeline-templates]
