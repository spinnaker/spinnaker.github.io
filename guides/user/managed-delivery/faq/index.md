---
layout: single
title:  "FAQ"
sidebar:
  nav: guides
---

{% include toc %}

This is a quick reference for Managed Delivery. 

### What is happening?

Spinnaker is managing this resource. 
That means that the state of this resource is controlled using a declarative config submitted to Spinnaker.


### Can I make changes in the UI to this resource?

Nope. 
Well, you can, but they will be almost immediately stomped to return to the declared state.


### Who is the source of truth for that declared state?

Spinnaker is. 


### Then why do I have code checked into a repo?

To help you keep your resources in a known good state.
You must publish these resource configs to Spinnaker every time they change in order for that change to be reflected in Spinnaker.

### What if I want to stop managing this resource declaratively?

Send us a `DELETE` for the config of this resource. 
We will stop managing the resource, and you can make changes like normal.
The infrastructure will not be deleted.

### Where are the getting started docs?

They're at [/reference/managed-delivery/getting-started](/guides/user/managed-delivery/getting-started).
