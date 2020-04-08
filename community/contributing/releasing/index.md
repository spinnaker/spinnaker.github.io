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

# Merge into the release branch

If your patch is a relatively small localized change that fixes a bug, and
doesn't introduce a feature or breaking change, you can request that your patch
be merged into a release branch. Every minor release of Spinnaker has its own
release branch. For example, all Spinnaker 1.16 releases (1.16.0, 1.16.1, etc.)
are built from the `release-1.16.x` release branch. To get your patch into 1.16,
it must be cherry-picked onto that release branch.

There are two ways to create a pull request for a cherry-pick:

* [Using Mergify](#cherry-pick-using-mergify)
* [Manually via the command-line](#cherry-pick-using-the-command-line)

After creating a cherry-pick pull request, you should assign the review to the
current release manager. The release manager rotation calendar is currently only
available inside Google, but it only rotates every eight weeks. The release
manager will be the person posting about the releases in [the
`#spinnaker-releases` Slack
channel](https://app.slack.com/client/T091CRSGH/CHD4ATAMV/). They will evaluate
the patch, make sure it's appropriate and safe, and merge it if so.

Please make sure your pull request references a GitHub issue with enough details
to allow the release manager to evaluate your request. It should detail exactly
what the impact of the bug is to users, how long it's been around, whether or
not there are workarounds, etc. If there isn't an issue already open, you can
either (preferably) file a new one, or else include these details in your
cherrypick pull request.

## Cherry-pick using Mergify

To cherry-pick into the `1.18` release branch (for example), add the following
comment to the _merged_ PR for your change:

> @Mergifyio backport release-1.18.x

## Cherry-pick using the command line

For example: say you've fixed a bug and had the fix merged into master. You're
running Spinnaker 1.5.1, and want the fix in Spinnaker 1.5.2. First, find the
commit's hash. This is easy to do in the "Commits" tab in your repository:

{% include figure image_path="./commit.png" caption="The hash is `a090bf3` in
this example" %}

Now, in your cloned repository run:

```bash
# the branch depends on your target release
git fetch upstream release-1.5.x

git checkout upstream/release-1.5.x

# the commit depends on what you found in the "Commits" tab above
git cherry-pick a090bf3

git checkout -b patch-broken-creds

git push origin patch-broken-creds
```

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
