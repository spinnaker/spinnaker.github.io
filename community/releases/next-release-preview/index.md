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

## Coming Soon in Release 1.24

### Official Docker Registry Has Changed

Official Spinnaker Kubernetes containers have moved from
`gcr.io/spinnaker-marketplace` to
`us-docker.pkg.dev/spinnaker-community/docker`.

If you use Halyard to deploy your containers, this shouldn't affect you. Halyard
will automatically use the new location, since it's written in the BOM files
that Halyard uses to get release information.

All releases are available in the new location. Only releases prior to 1.23 are
available in the old location, and the old location will be disabled in 2021.

### Bake helm charts using git/repo artifacts

The Bake (manifest) stage now accepts git/repo artifacts when baking a helm
chart.  See [this issue](https://github.com/spinnaker/spinnaker/issues/5249) for
background.
