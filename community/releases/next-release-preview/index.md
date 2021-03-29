---
layout: single
title:  "Next Release Preview"
sidebar:
  nav: community
---

{% include toc %}

Please make a pull request to describe any changes you wish to highlight
in the next release of Spinnaker. These notes will be prepended to the release
changelog.

## Coming Soon in Release 1.26

### Clouddriver account sharding for caching improvements

Clouddriver account sharding is an opt-in feature, disabled by default, and is enabled by setting a new 
configuration property `caching.sharding-enabled` to `true`.  
It works for the clouddriver that uses SQL agent scheduler. 
The feature works for all cloud providers. Accounts are split among the available pods based on their name.  
All the caching agents for the same account are run by the same pod but not all pods cache all accounts.

https://github.com/spinnaker/clouddriver/pull/5295