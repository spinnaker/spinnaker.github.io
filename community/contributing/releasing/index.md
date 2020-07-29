---
layout: single
title:  "Releasing A Patch"
sidebar:
  nav: community
---

{% include toc %}

Say you've written a patch, and it's been merged into Spinnaker. First off,
thanks for helping the project! Odds are, you want to deploy this patch to the
Spinnaker you manage. You have a few options available:

# Wait for the non-patch release

Any time we release a new minor version of Spinnaker (e.g. 1.16.0 or 1.17.0), we
include all commits merged into `master` for each service. We do this on a
[regular cadence](/community/releases/release-cadence).

# Release branch patch criteria

In order to be considered safe to merge into a release branch, your patch must:

* Fix a documented regression in a
  [supported version of Spinnaker](https://spinnaker.io/community/releases/versions/#latest-stable).
  This means that the currently broken functionality must have worked as
  expected in a previous version of Spinnaker. If the regression is not already
  documented in a GitHub issue, please create one. Describe the difference
  between the expected and observed behavior, and include links to the commit
  that introduced the regression. Indicate to which releases you would like
  your fix to be backported.
* Include tests validating the regression and the fix. The first commit of your
  patch pull request should add test coverage that demonstrates the existence
  of the bug and exercises all code paths potentially impacted by your fix.
  Subsequent commits should fix the bug and update the tests you just added. If
  your fix is so complex as to make complete tests coverage impossible, it is
  not a good candidate for merging into a release branch.

These criteria do not apply to security vulnerability patches, which may be
merged into release branches at the discretion of the Security SIG and release
manager.

# Merge into the release branch

If your patch meets the [cherry-pick criteria](#release-branch-patch-criteria), you can request that your patch
be merged into a release branch. Every minor release of Spinnaker has its own
release branch. For example, all Spinnaker 1.16 releases (1.16.0, 1.16.1, etc.)
are built from the `release-1.16.x` release branch. To get your patch into 1.16,
it must be cherry-picked onto that release branch.

After you've created a pull request for a fix that you want backported to a release
branch, add a comment that includes the following:

> @spinnakerbot add-label backport-candidate

Release managers will audit all PRs with the `backport-candidate` label weekly.
Please make sure your pull request description makes it easy for the release
manager to evaluate whether your patch meets the release branch patch criteria.

Navigate to GitHub, and create a PR as you would normally, but make sure that
your "base" is set to the release branch in the upstream repository as shown
below:

{% include figure image_path="./patch.png" %}

Once this PR is merged, your patch should be released in the next few days.

# Run the nightly builds (not recommended)

If you urgently need the change, you can always rely on the
`master-latest-unvalidated` release version. Keep in mind these changes have
not necessarily passed our integration test suite. You can pick this release
with the following command:

```bash
hal config version edit --version master-latest-unvalidated
```

This release is built nightly at around 2:00am every day. As a result, each
time you run `hal deploy apply`, you will be running the latest code for each
service.
