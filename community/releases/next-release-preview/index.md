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

## Coming Soon in Release 1.23

### (Breaking Change) Spinnaker Kubernetes manifest image overwriting with a bound artifact

Spinnaker will now overwrite images in a manifest with a bound artifact if the
input manifest's image has a tag on it. The previous behavior was that Spinnaker
would only overwrite images in a manifest if the image did not have a tag.

https://github.com/spinnaker/spinnaker/issues/5948