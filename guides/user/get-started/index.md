---
layout: single
title:  "Get Started Using Spinnaker"
sidebar:
  nav: guides
---

{% include toc %}

> This article assumes you are new to Spinnaker. It contains basic information
> about what to do after [installing Spinnaker](/setup/install/).

## Before you get going...

Whether you're an operator creating or managing a Spinnaker deployment, or an
end user getting started with Spinnaker, here are some pointers to get you
started.

### Operators

* If you want to install Spinnaker, [here you go](/setup/install/)

* If you want to find out more about tuning and maintaining Spinnaker, here are
some things to check out:

  - [Advanced configuration](/setup/other_config/)
  - [Productionize Spinnaker](/setup/productionize/)

### Users

* If you just want to try out Spinnaker, here are some
[quickstarts](/setup/quickstart/)

* If Spinnaker is already installed in your org, and you want to practice it
using some guided tutorials, [here are some
codelabs](/guides/tutorials/codelabs/)

* If you want a very basic overview of how to use Spinnaker, read on...

## Using Spinnaker: the high-level process

<!--
Notes:
* For step 2, this isn't quite right: many people are going to want to use
pipelines to create infrastructure. Creating infrastructure manually, using the
ui, is optional, and I can go straight to creating a pipeline.

So, it's more like

1. Create an application
2. Do all of this other stuff
(unordered list...)
* pipelines
* create infrastructure, which can be done inside the pipeline
* deploy


Further, examine who is reading this.
Right now I'm, possibly erroneously, jumping here from the end of install. But
this page is for *users*, not operators. In most cases it's the operators who
will install, and the devs who will use. There can be devops overlap, but we
need to keep the roles distinct.
This can be more fully solved when I create a separate ops guide*
Mean time, I need to somehow make this delineation clearer.



* some of the things lw mentioned that operators will/might be doing, post
install...
  - setting up pipeline templates
  -

-->



1. [Create an application](/guides/user/applications/)

   Typically, you'll have one application per microservice.

   Note that your application configuration affects what you can do with
   Spinnaker&mdash;you can enable or disable some Spinnaker features.

1. Define the [infrastructure](/concepts/) the service will run on

   You define infrastructure for each application. Your pipelines deploy
   services to the server groups you define.

   > Note: this step is not a prerequisite for creating pipelines. In fact, you
   > can use pipelines to create infrastructure.

1. [Create a pipeline](/guides/user/pipeline/managing-pipelines/)

   In fact, create all the pipelines you need to deploy the service or services
   covered by the application, in whatever ways you want to deploy.

   Find out more [here in the Managing pipelines
   guide](/guides/user/pipeline/managing-pipelines/).  

1. [Run your pipeline](/guides/user/pipeline/triggers/) to deploy your service

   You can run a pipeline manually, but most pipelines are [triggered
   automatically](/guides/user/pipeline/triggers/).

1. For practice, and to see some sample deployment schenarios, check out our
[codelabs](/guides/tutorials/codelabs/).

## The advanced stuff

You've got the basics down, but there's a lot more you can do with Spinnaker.

* [Configure and execute automated canary analysis](/guides/user/canary/)
for your deployments

* [Choose a deployment strategy](/concepts/#deployment-strategies)

* Get to know the [`spin` command-line interface](/guides/spin/cli/)
