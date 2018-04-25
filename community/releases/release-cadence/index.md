---
title:  "Release Cadence"
sidebar:
  nav: community
---

{% include toc %}

As of the 1.6 release, the Spinnaker team is committed to providing a more
regular release cadence in order to help users understand when new features
will be available, as well help non-core developers plan to get their features
released in the next stable version of Spinnaker.

## Release Window

Every eight weeks we open the Release Window, meaning that we cut release
branches for the upcoming release. If the version we intend to release is
`M.N`, a branch with the name `release-M.N.x` is cut in each component
repository. For example, see the state of the
[Clouddriver](https://github.com/spinnaker/clouddriver/) repository leading up
to the 1.6 release:

{% include
   figure
   image_path="./branches.png"
%}

We call this snapshot of all the Spinnaker repositories the "Release
Candidate".

### Running the Release Candidate

> If you're brave enough to run the Release Candidate, please [file
> bugs](https://github.com/spinnaker/spinnaker/issues) or alert us 
> on [slack](http://join.spinnaker.io) if you find any problems!

Once these release branches are cut, anyone can run the release candidate using
version `release-M.N.x-latest-unvalidated`:

```bash
# this would be version 'release-1.6.x-latest-unvalidated' for 1.6
hal config version edit --version release-M.N.x-latest-unvalidated

hal deploy apply
```

### Patching the Release Candidate

{% include
   warning
   content="Do not merge feature code into a release branch, only fixes are
   accepted."
%}

If you've found a fix for a bug in the Release Candidate, follow the [patching
procedure described
here](/community/contributing/releasing/#merge-into-the-release-branch). If
your patch is merged before the [Release Window is
closed](#closing-the-release-window), it will be included in this release.

### Closing the Release Window

Once the community has deemed that the Candidate is "stable" (meaning all
[integration
tests](https://github.com/spinnaker/spinnaker/tree/master/testing/citest) are
passing, and no known issues or regressions remain), we will release Spinnaker
at version `M.N.0`. Further patches can be merged into the release branch for
future patch releases (e.g. `M.N.1`).

## Upcoming Release Windows

| Version | Window Opens |
|-|-|
| `1.8.0`  | 2018-06-11 |
| `1.9.0`  | 2018-08-06 |
| `1.10.0` | 2018-10-01 |
