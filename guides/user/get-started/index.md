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

* If Spinnaker is not installed in your organization yet, and you just want to
test-drive it, here are some [quickstarts](/setup/quickstart/).

* If Spinnaker is not installed yet in your org and you want to install it,
[here you go](/setup/install/).

* If Spinnaker *is* installed in your org, and you want to practice it using
some guided tutorials, [here are some codelabs](/guides/tutorials/codelabs/).

If you want a very basic overview of to use Spinnaker, read on...

## Using Spinnaker: the high-level process

1. [Create an application](/guides/user/applications/)

   In fact, create as many applications as you want. Typically, you'll have one
   application per microservice.

   Note that your application configuration affects what you can do with
   Spinnaker; you can enable or disable Spinnaker features.

1. Define the [infrastructure](/concepts/) the service will run on

   Your pipelines will deploy services to the server groups you define for each
   application.

1. [Create a pipeline](/guides/pipeline/managing-pipelines/)

   In fact, create all the pipelines you need to deploy the service or services
   covered by the application, in whatever ways you want to deploy.

   Find out more [here](/guides/user/pipelin/managing-pipelines/).  

1. Run your pipeline to deploy your service.

   You can run a pipeline manually, but most pipelines are [automatically
   triggered](/guides/user/pipeline/triggers/).


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
