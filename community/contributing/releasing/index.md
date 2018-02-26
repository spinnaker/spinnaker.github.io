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

Any time we release `X+1.Y.0` or `X.Y+1.0`, we include all commits merged into
`master` for each service. We do this on a [regular
cadence](/community/releases/release-cadence).

# Merge into the release branch

If your patch fixes a bug, and doesn't introduce a feature or breaking change,
you can release your change even sooner by cherry-picking into a release
branch. Every release `X.Y.0` creates a `release-X.Y.x` branch in each
repository. If you cherry-pick your change into that branch, and open a PR
against that branch with your patch, it will make it into the next patch
release.

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
