---
layout: single
title:  "Get started using Spinnaker"
sidebar:
  nav: guides
---

{% include toc %}

> This article assumes you are new to Spinnaker. It contains basic information
> about what to do after [installing Spinnaker](/setup/install/).

## Before you get going...

* If you just want to test-drive Spinnaker, here are some
[quickstarts](/setup/quickstart/).

* If you want to install Spinnaker, [here you go](/setup/install/).

* If Spinnaker is alrady installed in your org, and you want to practice it
using some guided tutorials, [here are some
codelabs](/guides/tutorials/codelabs/).

If you want a very basic overview of to use Spinnaker, read on...

## Using Spinnaker: the high-level process

<!--
Notes:
* For step 2, this isn't quite right: many people are going to want to use
pipelines to create infrastructure. Creating infrastructure manually, using the
ui, is optional, and I can go straight to creating a pipeline.

So, it' more like

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

   In fact, create as many applications as you want. Typically, you'll have one
   application per microservice.

   Note that your application configuration affects what you can do with
   Spinnaker; you can enable or disable Spinnaker features.

1. Define the [infrastructure](/concepts/) the service will run on

   Your pipelines will deploy services to the server groups you define for each
   application.

1. [Create a pipeline](/guides/user/pipeline/managing-pipelines/)

   In fact, create all the pipelines you need to deploy the service or services
   covered by the application, in whatever ways you want to deploy.

   Find out more [here](/guides/user/pipeline/managing-pipelines/).  

1. [Run your pipeline](/guides/user/pipeline/triggers/) to deploy your service.

   You can run a pipeline manually, but most pipelines are [automatically
   triggered](/guides/user/pipeline/triggers/).

## The advanced stuff

You've got the basics down, but there's a lot more you can do with Spinnaker.

* [Configure and execute automated canary analysis]() for your deployments

* [Use a deployment strategy]()


<!--

* generalized statement of the fact that what you're gonna use Spinnaker for:
  - configuring (identifying?) infrastructure for the services you're going to deploy
  - make pipelines to deploy those services
  - something about how there are other things you can do too, like ACA, but
     that this guides is only about the first, fundamental, things you're going
     to need to do.

* Note about inferred applications

  Because our context here is "I've just installed spinnaker, and now I don't
  know what I'm looking at (or what to do), we've got to mention that there
  might be some applications there already.

  - How did they get there if I didn't create anything?
  - What do I do with them?

* Create an application
And obviously link to the new applications guide

* Configure the application

* Configure your infrastructure for the application
Be  sure to note that this is done per application

* Create your first pipeline
Write a synopsis, then link to
* Best practices for...things?





Other things to do:

* Add link to here from the end of setup process, or links to all possible ends:
"Next step: "get started with Spinnaker," and of course link to this guide.

*
-->
