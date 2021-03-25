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

The sql backed clouddriver caching pods are now capable of sharding the accounts of any provider 
by setting a new configuration property `caching.sharding-enabled` to `true`. A hashing logic is applied to determine which pod can run the caching agents of an account.
