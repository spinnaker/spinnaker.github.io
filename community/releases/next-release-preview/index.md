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

## Coming Soon in Release 1.21

### End of Support for the legacy Kubernetes Provider

1.20 was the final release to include support for Spinnaker's legacy Kubernetes
(V1) provider. Please migrate all Kubernetes accounts to the standard (V2)
provider before upgrading to Spinnaker 1.21.

### Suspension of Support for Alicloud, DC/OS, and Oracle Cloud Providers

The Alicloud, DC/OS, and Oracle cloud providers are excluded from 1.21 because
they no longer meet Spinnaker's
[cloud provider requirements](https://github.com/spinnaker/governance/blob/master/cloud-provider-requirements.md),
which include the formation of a Spinnaker SIG. If you are interested in
forming a SIG for one of these cloud providers, please comment on the
appropriate GitHub issue:

* [Alicloud](https://github.com/spinnaker/governance/issues/122)
* [DC/OS](https://github.com/spinnaker/governance/issues/125)
* [Oracle](https://github.com/spinnaker/governance/issues/127)

### New release branch patch criteria

Previously, fixes were merged into release branches at the discretion of the
release manager. To increase the transparency of the release process and the
safety of the patch release upgrade process, we have documented more explicit
[patch criteria](https://www.spinnaker.io/community/contributing/releasing/#release-branch-patch-criteria)
to determine whether a change is appropriate to cherry-pick into a release
branch.
