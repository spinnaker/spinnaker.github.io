---
layout: single
title:  "Use Kustomize for Manifests"
sidebar:
  nav: guides
---

{% include toc %}

Kustomize is a tool that lets you create customized Kubernetes deployments without modifying underlying YAML configuration files. Since the files remain unchanged, others are able to reuse the same files to build their own customizations. Your customizations are stored in a file called `kustomization.yaml`. If configuration changes are needed, the underlying YAML files and `kustomization.yaml` can be updated independently of each other.

To learn more about Kustomize and how to define a `kustomization.yaml` file, see the following links:

* [Kubernetes SIG for Kustomize](https://github.com/kubernetes-sigs/kustomize)
* [Documentation for Kustomize](https://github.com/kubernetes-sigs/kustomize/tree/master/docs)
* [Example Kustomization](https://github.com/kubernetes-sigs/kustomize/tree/master/examples/wordpress)

In the context of Spinnaker, Kustomize lets you generate a custom manifest, which can be deployed in a downstream `Deploy (Manifest)` stage. This manifest is tailored to your requirements and built on existing configurations.

Note that Spinnaker uses the latest non-kubectl version of Kustomize.

## Enabling Kustomize in 1.16 and 1.17 (Beta)

Kustomize can be enabled by a feature flag in 1.16 and 1.17.

For Halyard, add the following line to `~/.hal/{DEPLOYMENT_NAME}/profiles/settings-local.js`:

```javascript
window.spinnakerSettings.feature.kustomizeEnabled = true;
```

## Overview

Kustomize works by running `kustomize build` against a `kustomization.yaml` file located in a Git repository. This file defines all of the other files needed by Kustomize to render a fully hydrated manifest.

Kustomize support was added to Spinnaker in 1.16. However, the instructions for using Kustomize vary between Spinnaker 1.16 and 1.17+.

## Configure the “Bake (Manifest)” stage

### Using Spinnaker 1.17+

**Note: Kustomize in 1.17+ requires the [git/repo](/reference/artifacts/types/git-repo/) artifact type.**
{: .notice--info}

Select `Kustomize` as the Render Engine and define the artifact for your `kustomization.yaml`.

You can specify the following:

* __The account__ (required)

  The `git/repo` account to use.

* __The URL__ (required)

  The location of the Git repository.

* __The branch__ (optional)

  The branch of the repository you want to use. _[Defaults to `master`]_

* __The subpath__ (optional)

  By clicking `Checkout subpath`, you can optionally pass in a
  relative subpath within the repository. This provides the option
  to checkout only a portion of the repository, thereby reducing the
  size of the generated artifact.

* __The Kustomize File__ (required)

  The relative path to the `kustomization.yaml` file residing in the
  Git repository.

{%
  include
  figure
  image_path="./render-engine-gitrepo.png"
%}

### Using Spinnaker 1.16

Select `Kustomize` as the Render Engine and define the artifact for your `kustomization.yaml`:

{%
  include
  figure
  image_path="./render-engine-github.png"
%}

## Configuring the Produced Artifact

With the `Bake (Manifest) Configuration` completed, configure a Produced Artifact to use the result in a stage downstream.
Add an artifact:

{%
  include
  figure
  image_path="./add-artifact.png"
%}

Define the artifact:

{%
  include
  figure
  image_path="./define-artifact.png"
%}

You can now run your pipeline and get a Kustomize rendered manifest!

## Other Templating Engines

In addition to Kustomize, Spinnaker also supports Helm as a templating engine. For more information, see [Deploy Helm Charts](/guides/user/kubernetes-v2/deploy-helm/).
