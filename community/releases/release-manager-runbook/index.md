---
layout: single
title:  "Release Manager Runbook"
sidebar:
  nav: community
---

{% include toc %}


## A Quick Review of Release Process
Here's a quick review of what the release process looks like from the community perspective:
- [This is the expected release cadence](/community/releases/release-cadence/).
- The [release calendar](/community/releases/release-cadence/#upcoming-releases) is awesome. It gives you an agenda with the expected duties.
- Here's what the project expects all contributors to do for [backports/patches](/community/contributing/releasing/#release-branch-patch-criteria).

If the builds break, you can take a look at [some common issues](https://spinnaker.io/community/contributing/nightly-builds/#common-build-failures)
to see if we've encountered them before.


## Verify You Have Access To The Following

If you don't have access to any of the following, contact a member of the TOC or SC.

- You're a member of the [release-managers@spinnaker.io](https://groups.google.com/a/spinnaker.io/forum/#!forum/release-managers)
group and a *manager* of the [spinnaker-announce@googlegroups.com](https://groups.google.com/forum/#!forum/spinnaker-announce)
group. (You'll get a permissions error on those pages if you don't have access.
- You've been invited to the [Bintray's spinnaker-releases](https://bintray.com/spinnaker-releases) org.
- You're a member of the [release-managers GitHub team](https://github.com/orgs/spinnaker/teams/release-managers).
- You can access the [Jenkins UI](https://builds.spinnaker.io/) and you're able
to run a job. Access is controlled by the `release-managers` GitHub team, but it
may take some time for the permissions to propagate from GitHub to Jenkins.
- You can [SSH into Jenkins](https://spinnaker.io/community/contributing/nightly-builds/#connecting-to-the-jenkins-vm).
- You're able to view our [GCP spinnaker-community cloudbuilds](https://console.cloud.google.com/cloud-build/builds?project=spinnaker-community). You should see a lot of builds.


## One week before the branches are cut (Monday)

Ping [#dev](https://spinnakerteam.slack.com/messages/dev/) reminding everyone
to merge outstanding changes by Monday:

> The release manager will be cutting the $VERSION release branches next Tuesday,
> so if there are any outstanding PRs that you'd like to get into $VERSION,
> please make sure they are merged by EOD next Monday. Once the branch is cut,
> only fixes will be accepted into the release branches.


## One day before the branches are cut (Monday)

Ping [#dev](https://spinnakerteam.slack.com/messages/dev/) reminding everyone
to merge outstanding changes ASAP:

> The release manager will be cutting the $VERSION release branches tomorrow
> morning, so if there are any outstanding PRs that you'd like to get into
> $VERSION, please make sure they are merged ASAP. Once the branch is cut, only
> fixes will be accepted into the release branches.


## The day the branches are cut (Tuesday)

1. If there are any [outstanding autobump PRs](https://github.com/pulls?q=is%3Apr+author%3Aspinnakerbot+is%3Aopen),
make the required fixes to allow them to merge. (You can ignore `keel` and
`swabbie`; those repositories aren't part of a Spinnaker release.)

1. Start with a [blue build on master](https://builds.spinnaker.io/job/Flow_BuildAndValidate/).

1. Create the release branches by running the [**Admin_StartReleaseBranch**](https://builds.spinnaker.io/job/Admin_StartReleaseBranch/build?delay=0sec)
job, which creates `latest-unvalidated` when it passes:

    1. Set **NEW_BRANCH_NAME** to `${RELEASE_BRANCH}` (e.g., `release-1.20.x`).

    1. Set **BASE_BRANCH** to `master`.

    - If the builds fail, [Google Cloud Build](https://console.cloud.google.com/cloud-build/builds?project=spinnaker-community) is a helpful UI. 
    Make sure to enable tags to the service name.
        <details>
        <summary>Click to expand a GIF of how to view the tags</summary>

        <img src="/assets/images/releases/gcp-cloudbuild-tags.gif" />

        </details>

1. Deactivate the now-oldest `Flow_BuildAndValidate_*` flow by removing the schedule:

    1. Select the oldest flow.

    1. Click **Configure** from the left hand side of the menu.

    1. Scroll to the **Build Triggers** section.

    1. Cut text out of **Schedule** box (you will need to paste this in the
    following step).

    1. Save.

1. Create a new `Flow_BuildAndValidate_*` flow for the release branch.

    1. Click **New Item** on the left hand side of the main menu.

    1. Set **Name** to `Flow_BuildAndValidate_${RELEASE}` (e.g., `1_18_x`). Note
    that the newer versions of Jenkins seem to disallow the `.` character in the
    job name, so will want to `s/./_`.

    1. Set **Copy from** to Flow_BuildAndValidate.

    1. Click **OK**.

    1. In the **Build Triggers** section, paste cut text from the oldest flow.

    1. Set **GITHUB_REPO BRANCH** to `${RELEASE_BRANCH}`.

    1. Set **PROCESS_GITHUB_REPO_BRANCH** TO `${RELEASE_BRANCH}`.

    1. Save.

1. At this point, the following `Flow_BuildAndValidate_*` jobs should exist:

    - `Flow_BuildAndValidate_${RELEASE-3}` (DEACTIVATED)

    - `Flow_BuildAndValidate_${RELEASE-2}` (BUILDING NIGHTLY)

    - `Flow_BuildAndValidate_${RELEASE-1}` (BUILDING NIGHTLY)

    - `Flow_BuildAndValidate_${RELEASE}` (BUILDING NIGHTLY)

    - `Flow_BuildAndValidate` (master, BUILDING SEVERAL TIMES DAILY)

1. Run the `Flow_BuildAndValidate_${RELEASE}` job.

    1. Select `stable` for **HALYARD_RELEASE_TRACK**.

    1. This will automatically update the [changelog gist](https://gist.github.com/spinnaker-release/4f8cd09490870ae9ebf78be3be1763ee)
    on GitHub.

    1. Copy the direct link to the changelog for this version by searching for the release branch. For example: `release-1.21.x`.

1. Add the new `Flow_BuildAndValidate_${RELEASE}` job to the public
[Build Statuses page](https://www.spinnaker.io/community/contributing/build-statuses/#nightly-and-release-integration-tests).
Remove the oldest job.

1. Ping [#dev](https://spinnakerteam.slack.com/messages/dev/) with some version of
this message, including a link to the correct section of the changelog gist found above.

    > The release branches for Spinnaker $VERSION have been cut from master!
    > Those branches are only accepting fixes for existing features.  Please
    > contact $YOUR_NAME (slack: $YOUR_SLACK_ID, github: $YOUR_GITHUB_ID, or
    > email: $YOUR_EMAIL) if you would like a fix cherry-picked into the
    > release. If you would like to highlight a specific fix or feature in the
    > release’s changelog, please make a pull request against the
    > [curated changelog](/community/releases/next-release-preview)
    > by Friday. If you’d like to jog your memory of everything to be released
    > with Spinnaker $VERSION, see the raw changelog here: $LINK_TO_CHANGELOG.

1. When the `Flow_BuildAndValidate_${RELEASE}` job passes, ping
[#dev](https://spinnakerteam.slack.com/messages/dev/) with a message that the
release candidate is now validated and can be tested.

    > You are now welcome to test out the new release candidate for ${RELEASE} by running
    > ```
    > hal config version edit --version ${RELEASE_BRANCH}-latest-unvalidated
    > ```
    >
    > If you'd like to see the BOM for this release, you can run
    > ```
    > hal version bom
    > ```


## One week after branches are cut (Monday)

1. Audit [backport candidates](#audit-backport-candidates).

1. Rerun the `Flow_BuildAndValidate_${RELEASE}` job and get a blue build.

1. Create a new gist for this release.

    1. Log into GitHub as spinnaker-release.
    The release-manager@spinnaker.io group has access to the
    [spinnaker-release GitHub account credentials](https://docs.google.com/document/d/1CFPP-QXV8lu9QR76B9V0W8TEtObOBv52UqohQ-ztH58/edit?usp=sharing).

    1. Create a new public gist to hold the
    release notes for this release branch.

    1. The description should be “Spinnaker 1.nn.x Release Notes” (e.g.,
    Spinnaker 1.18.x Release Notes). The gist will eventually have a separate
    file with the release notes for each patch release on this branch.

    1. Add a file 1.nn.0.md (e.g., `1.18.0.md`) to hold the release notes for
    the new release.

        Use this template to build the file:
        ```md
        # Spinnaker Release ${nn.nn.nn}
        **_Note: This release requires Halyard version ${nn.nn.nn} or later._**

        This release includes fixes, features, and performance improvements across a wide feature set in Spinnaker. This section provides a summary of notable improvements followed by the comprehensive changelog.

        ${CURATED_CHANGE_LOG}

        # Changelog

        ${RAW_CHANGE_LOG}
        ```

        a. Copy the changes for this release from the [raw build changelog](https://gist.github.com/spinnaker-release/4f8cd09490870ae9ebf78be3be1763ee#file-release-1-21-x-raw-changelog-md) to the new 1.nn.0.md file. Change the anchor tag in the link for your release version.

        b. Add the notes from the [curated changelog](/community/releases/next-release-preview)
        to the top of the gist ([sample 1.nn.0 release notes](https://gist.github.com/spinnaker-release/cc4410d674679c5765246a40f28e3cad)).

    1. Reset the [curated changelog](/community/releases/next-release-preview)
    for the next release by removing all added notes and incrementing the version
    number in the heading.

1. Run Publish_SpinnakerRelease:

    1. **Spinnaker Version** is "1.nn.0" (replacing nn with the version number).

    1. **Spinnaker Release Alias** should be the name of a Netflix original TV
    show converted to an alphanumeric string
    (e.g., "Gilmore Girls A Year in the Life").
    The name must be unique among current active releases (releases returned by `hal version list`).

    1. **BOM version** is `release-1.nn.x-latest-unvalidated` (replace nn
    with the version number).

    1. The **Gist URL** is the URL to the gist you just created.

    1. **Minimum Halyard version** should remain unchanged unless you know of a
    reason to change it (in which case, please also change the default for new
    builds).

1. Approve the spinnaker-announce email (link will come in email).
You can approve the message in the [spinnaker-announce group](https://groups.google.com/forum/#!pendingmsg/spinnaker-announce).

1. Deprecate the n-3 release (i.e. when releasing 1.18, deprecate 1.15).

    1. From the Jenkins machine, run
    `hal admin deprecate version --version ${VERSION_TO_DEPRECATE}`.

    1. Make a PR against the deprecated changelog
   [here](https://github.com/spinnaker/spinnaker.github.io/tree/master/_changelogs),
   adding `deprecated` to the list of tags.

    1. Delete the associated Jenkins project (e.g., Flow_BuildAndValidate_${RELEASE-3}).

    1. Remove the changelog from the [master gist](https://gist.github.com/spinnaker-release/4f8cd09490870ae9ebf78be3be1763ee).
   (While logged in as spinnaker-release, click "Edit", scroll to the file, and
   click "Delete".)

1. At this point, the following `Flow_BuildAndValidate_*` jobs should exist:

    - `Flow_BuildAndValidate_${RELEASE-2}` (BUILDING NIGHTLY)

    - `Flow_BuildAndValidate_${RELEASE-1}` (BUILDING NIGHTLY)

    - `Flow_BuildAndValidate_${RELEASE}` (BUILDING NIGHTLY)

    - `Flow_BuildAndValidate` (master, BUILDING NIGHTLY)

1. Ping the [#spinnaker-releases](https://spinnakerteam.slack.com/messages/spinnaker-releases/)
channel to let them know that a new patch is available.

    > Hot Tip! You can use giphy to tell everyone it's released!
    >
    > `/giphy #caption "Spinnaker {VERSION} has been released!" gif search query`

1. Publish a Spin CLI minor version.

    1. Each Spin CLI release is tied to a version of Gate. To ensure
    compatibility, regenerate the Gate Client API.

    1. From the `gate` repository, check out the release branch and generate the `swagger/swagger.json` file (it's not under source control):
    ```
    ./swagger/generate_swagger.sh
    ```
    
    1. From the `spin` repository, check out the release branch (release branches from `gate` and `spin` must match) and follow the [instructions](https://github.com/spinnaker/spin/blob/master/CONTRIBUTING.md#updating-the-gate-api) in that repo to update the gate client. This involves creating and merging a PR to `spin` release branch with the updated Gate Client API.

    1. If regenerating the Gate Client API produced any changes, kick off the
    Flow_BuildAndValidate_1.xx.x for the release branch and wait for a successful
    completion. This will trigger a downstream Build_PrimaryArtifacts job that
    we rely on later.

    1. Run Publish_SpinRelease with the following parameters:

        - SPIN_BUILD_VERSION_TO_RELEASE: This can be found in the build_spin files
        written by the Build_PrimaryArtifacts job. Use the version found in the most
        recent run of the Build_PrimaryArtifacts for the release branch. Note: The
        major-minor part of this version number should match the Gate version for
        the release branch. If it does not, double check that a tag for the previous
        minor version of Spin CLI exists. The build auto increments new tags based
        on the highest pre-existing minor tag.

        - BOM_VERSION: This is the BOM to associate the Spin CLI release with. It is
        the latest Spinnaker release number, 1.xx.x.

1. Make a Sponnet [GitHub release](https://github.com/spinnaker/sponnet/releases/new). Give it the same version as the newly released Spinnaker, with the tag prefixed with "v" (for example, v${RELEASE}).


## Every subsequent Monday: Patch a previous Spinnaker version

Repeat weeklyish for each supported version.

1. Audit [backport candidates](#audit-backport-candidates).
To view what's been merged into each release branch since the last release,
see the [changelog gist](https://gist.github.com/spinnaker-release/4f8cd09490870ae9ebf78be3be1763ee)
on Github.

1. Rerun the `Flow_BuildAndValidate_${RELEASE}` job and get a blue build.

1. Run Publish_SpinnakerPatchRelease:

    1. Enter the major and minor version of the release you’re patching
    (ex: 1.18) in MAJOR_MINOR_VERSION.

    1. All other fields can be left as defaults/blank.

   This looks for a currently active release with this major and minor version.
   It copies all parameters from that release (name, changelog gist, minimum
   Halyard version), increments the patch version, and triggers
   Publish_SpinnakerRelease with these parameters. In general, this is exactly
   the behavior we want, but if you need to override this behavior (such as to
   increment the minimum Halyard version in a patch release), you can call
   Publish_SpinnakerRelease directly and pass the exact parameters that you’d
   like the new release to have.

1. After the job has completed, run `hal version list` and verify that the
version you just released is listed, and the prior patch release for the minor
version is no longer listed.

1. Go to to [spinnaker.io](https://www.spinnaker.io/community/releases/versions/)
and verify the following (leaving time for the site to rebuild):

   1. Verify the version you just released is listed.

   1. Verify the prior patch release for the minor version has been moved to the
   “Deprecated Versions” section.

   1. Verify the changelog for the new version looks correct.  It should start with the
   changelog for the specific patch release, then list the changelog for each
   patch release of the minor version in reverse order.

1. Ping the [#spinnaker-releases](https://spinnakerteam.slack.com/messages/spinnaker-releases/)
channel to let them know that the new patch is available.

    > Hot Tip! You can use giphy to tell everyone it's released!
    >
    > `/giphy #caption "Spinnaker {VERSION} has been released!" gif search query`

1. Approve the spinnaker-announce email (link will come in email).
You can approve the message in the [spinnaker-announce group](https://groups.google.com/forum/#!pendingmsg/spinnaker-announce).


## Release minor-version Halyard

Repeat every 2-4 weeks as needed.

1. Check for outstanding PRs.

1. Run Flow_BuildAndValidate, selecting `nightly` Halyard. This will
automatically check the “build Halyard” checkbox in the downstream
Build_PrimaryArtifacts flow.

1. After that passes, navigate to:
```
https://builds.spinnaker.io/job/Build_PrimaryArtifacts/${JOB_NUMBER}/artifact/build_output/build_halyard/last_version_commit.yml/*view*/
```
(insert correct JOB_NUMBER) and copy the version (it will be the entire string prior to the colon).

1. Run Publish_HalyardRelease:

    1. Set `HALYARD_BUILD_VERSION_TO_RELEASE` to the version copied from the
    prior step.

1. Post in [#halyard](https://spinnakerteam.slack.com/messages/halyard/) that a
   new version of Halyard has been released.

    > Hot Tip! You can use giphy to tell everyone it's released!
    >
    > `/giphy #caption "Halyard {VERSION} has been released!" gif search query`


## Release patch-version Halyard

Repeat as needed.

1. Ensure you have [audited](#audit-backport-candidates) all
[Halyard backport candidates](https://github.com/spinnaker/halyard/pulls?q=is%3Apr+sort%3Aupdated-desc+label%3Abackport-candidate).

1. Run Build_Halyard:

    1. Set **GITHUB_REPO_BRANCH** to the release branch of Halyard
    (e.g., release-1.20.x).

    1. Set **OVERRIDE_PROCESS_GITHUB_REPO_BRANCH** to `master`.

1. Run Publish_HalyardRelease:

    1. Set **HALYARD_BUILD_VERSION_TO_RELEASE** to pre-colon output from
    `last_version_commit.yml` of the prior job.

1. Post in [#halyard](https://spinnakerteam.slack.com/messages/halyard/) that a
   new version of Halyard has been released.

    > Hot Tip! You can use giphy to tell everyone it's released!
    >
    > `/giphy #caption "Halyard {VERSION} has been released!" gif search query`


## Publish a new version of deck-kayenta

Repeat as needed.

Follow the instructions in deck-kayenta’s
[README](https://github.com/spinnaker/deck-kayenta#publishing-spinnakerkayenta).

## Audit backport candidates

Repeat weekly.

1. Audit each PR that has been labelled a
[backport candidate](https://github.com/pulls?q=org%3Aspinnaker+is%3Apr+sort%3Aupdated-desc+label%3Abackport-candidate).

1. If a candidate meets the
[release branch patch criteria](/community/contributing/releasing#release-branch-patch-criteria):

    1. Remove the `backport-candidate` label from the PR.

    1. Determine which versions the PR needs to be backported to. If it gets backported to an older version, all new versions should get the backport as well. Go only as far back as the supported [stable versions](https://spinnaker.io/community/releases/versions/#latest-stable).
    
    1. Add a comment instructing
       [Mergify](https://doc.mergify.io/commands.html#backport) to create
       backport PRs against one or more release branches. For example, to
       create backport PRs against the 1.19, 1.20 and 1.21 release branches, comment:
       
       > @Mergifyio backport release-1.19.x release-1.20.x release-1.21.x

    1. Approve and merge the backport PRs.

    1. If Mergify cannot create a backport because there are merge conflicts,
       ask the contributor to open a PR against the target release branches with
       their commits manually
       [cherry-picked](https://git-scm.com/docs/git-cherry-pick).

1. If a candidate does not meet the
[release branch patch criteria](/community/contributing/releasing#release-branch-patch-criteria),
add an explanation to the contributor as a comment.

    1. If it's impossible for the candidate to meet the criteria (for example, it doesn't
       fix a regression), remove the `backport-candidate` label.
       
    1. If the contributor can amend the candidate to meet the criteria (for example,
       add test coverage), don't remove the `backport-candidate` label.
