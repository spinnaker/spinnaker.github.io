---
layout: single
title:  "Managed Delivery"
sidebar:
  nav: reference
---

{% include toc %}

This is a quick reference for Managed Delivery. 
More detailed docs are under construction.

_This doc will remain undiscoverable from the side navigation until we start alpha adoption._


### Where am I?

You probably arrived here from a tooltip on a declaratively manged resource.
This page has some helpful information to get oriented, as well as some other links (coming...).


### What is happening?

Spinnaker is managing this resource. 
That means that the state of this resource is conrolled using a declarative config submitted to Spinnaker.


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

They're at [/reference/managed-delivery/getting-started](/reference/managed-delivery/getting-started).
