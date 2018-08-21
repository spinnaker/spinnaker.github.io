---
layout: single
title:  "Get started using Spinnaker"
sidebar:
  nav: guides
---

{% include toc %}

This article is for Spinnaker *users*. *Operators* of Spinnaker can start with
[Set up Spinnaker](/setup/).

This article assumes you are new to Spinnaker. It contains basic information
about what Spinnaker does and what you do to get Spinnaker to do it.

Spinnaker deploys services to one or more cloud providers. It


<!--move this -->
## A note about inferred applications

If you've deployed Spinnaker on a Kubernetes cluster, you might several
application already available


## Using Spinnaker&mdash;the high-level process

1. Create an application

   In fact, create as many applications as you want. Typically, you'll have one
   application per microservice. [Find out more about applications
   here](/guides/user/applications/).

   Note that your application configuration affects what you can do with
   Spinnaker. You can enable or disable Spinnaker features.

1. Open an application and start defining the infrastructure the service will
run on.

   Your pipelines will deploy your services to

1. Create a pipeline

   In fact, create all the pipelines you need, to deploy the service or services
   covered by the application, in whatever ways you want to deploy.

   Find out more [here](/guides/user/pipeline/managing-pipelines/).  





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
