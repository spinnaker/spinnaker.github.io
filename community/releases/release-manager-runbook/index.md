---
layout: single
title:  "Release Manager Runbook"
sidebar:
  nav: community
---

{% include toc %}

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

1. Reach out to anyone who has previously contacted you to ensure their
last-minute release PRs have been merged.

1. If there are any [outstanding autobump PRs](https://github.com/pulls?q=is%3Apr+author%3Aspinnakerbot+is%3Aopen),
make the required fixes to allow them to merge.

1. Start with a [green build on master](https://builds.spinnaker.io/job/Flow_BuildAndValidate/).

1. Create the release branches by running the [**Admin_StartReleaseBranch**](https://builds.spinnaker.io/job/Admin_StartReleaseBranch/build?delay=0sec)
job:
    
    1. Set **NEW_BRANCH_NAME** to `${RELEASE_BRANCH}` (e.g., `release-1.20.x`).
    
    1. Set **BASE_BRANCH** to `master`.

1. Deactivate the now-oldest Flow_BuildAndValidate_* flow:

    1. Select the oldest flow.

    1. Click **Configure** from the left hand side of the menu.

    1. Scroll to the **Build Triggers** section.

    1. Cut text out of **Schedule** box (you will need to paste this in the
    following step).
    
    1. Save.

1. Create a new Flow_BuildAndValidate_* flow for the release branch.

    1. Click **New Item** on the left hand side of the main menu.

    1. Set **Name** to Flow_BuildAndValidate_${RELEASE} (e.g., `1_18_x`). Note
    that the newer versions of Jenkins seem to disallow the `.` character in the
    job name, so will want to `s/./_`.
    
    1. Set **Copy from** to Flow_BuildAndValidate.

    1. In the **Build Triggers** section, paste cut text from the oldest flow.
    
    1. Set **GITHUB_REPO BRANCH** to `${RELEASE_BRANCH}`.
    
    1. Set **PROCESS_GITHUB_REPO_BRANCH** TO `${RELEASE_BRANCH}`.
    
1. At this point, the following Flow_BuildAndValidate_* jobs should exist:

    - Flow_BuildAndValidate_${RELEASE-3} (DEACTIVATED)
    
    - Flow_BuildAndValidate_${RELEASE-2} (BUILDING NIGHTLY)
    
    - Flow_BuildAndValidate_${RELEASE-1} (BUILDING NIGHTLY)
    
    - Flow_BuildAndValidate_${RELEASE} (BUILDING NIGHTLY)
    
    - Flow_BuildAndValidate (master, BUILDING SEVERAL TIMES DAILY)

1. Run the Flow_BuildAndValidate_${RELEASE} job.

    1. Select `stable` for **HALYARD_RELEASE_TRACK**.
    
    1. This will automatically update the [changelog gist](https://gist.github.com/spinnaker-release/4f8cd09490870ae9ebf78be3be1763ee)
    on GitHub.
    
1. Add the new Flow_BuildAndValidate_${RELEASE} job to the public
[Build Statuses page](https://www.spinnaker.io/community/contributing/build-statuses/#nightly-and-release-integration-tests).
Remove the oldest job. For each service under Core Services, add a row for the
newest release branch, and remove the row for the oldest release branch.

1. Ping [#dev](https://spinnakerteam.slack.com/messages/dev/) with some version of
this message, including a link to the correct section of the changelog gist:

    > The release branches for Spinnaker $VERSION have been cut from master!
    > Those branches are only accepting fixes for existing features.  Please
    > contact $YOUR_NAME (slack: $YOUR_SLACK_ID, github: $YOUR_GITHUB_ID, or
    > email: $YOUR_EMAIL) if you would like a fix cherry-picked into the
    > release. If you would like to highlight a specific fix or feature in the
    > release’s changelog, please make a pull request against the
    > [curated changelog](/community/releases/next-release-preview)
    > by Friday. If you’d like to jog your memory of everything to be released
    > with Spinnaker $VERSION, see the raw changelog here: $LINK_TO_CHANGELOG.

1. When the Flow_BuildAndValidate_${RELEASE} job passes, ping
[#dev](https://spinnakerteam.slack.com/messages/dev/) with a message that the
release candidate is now validated and can be tested by running:

    ```
    hal config version edit --version ${RELEASE_BRANCH}-latest-validated
    ```

## One week after branches are cut (Monday)

1. Check for any PRs waiting to be [cherry-picked](https://github.com/pulls?utf8=%E2%9C%93&q=org%3Aspinnaker+is%3Apr+is%3Aopen+-base%3Amaster).
(You can further restrict the query by adding a constraint like +base:release-1.18.x to the URL.)

1. Rerun the Flow_BuildAndValidate_${RELEASE} job and get a green build.

1. Create a new gist for this release.

    1. Log into GitHub as spinnaker-release. If this is your first release
    manager rotation, ask a member of the TOC or SC to add you to the
    release-manager@spinnaker.io group, which has access to the
    [spinnaker-release GitHub account credentials](https://docs.google.com/document/d/1CFPP-QXV8lu9QR76B9V0W8TEtObOBv52UqohQ-ztH58/edit?usp=sharing).
    
    1. Create a new gist to hold the
    release notes for this release branch.
    
    1. The description should be “Spinnaker 1.nn.x Release Notes” (e.g.,
    Spinnaker 1.18.x Release Notes). The gist will eventually have a separate
    file with the release notes for each patch release on this branch.

    1. Add a file 1.nn.0.md (e.g., `1.18.0.md`) to hold the release notes for
    the new release.
    
    1. Copy the changes for this release from the raw build changelog to the new
    1.nn.0.md file.

    1. Add the notes from the [curated changelog](/community/releases/next-release-preview)
    to the top of the gist ([sample 1.nn.0 release notes](https://gist.github.com/spinnaker-release/cc4410d674679c5765246a40f28e3cad)).
    
    1. Reset the [curated changelog](/community/releases/next-release-preview)
    for the next release by removing all added notes and incrementing the version
    number in the heading.

1. Run Publish_SpinnakerRelease:

    1. **Spinnaker Version** is "1.nn.0" (replacing nn with the version number).
    
    1. **Spinnaker Release Alias** should be the name of a Netflix original TV
    show converted to an alphanumeric string
    (e.g., "Gilmore Girls A Year in the Life").
    
    1. **BOM version** should be "release-1.nn.x-latest-validated" (replacing nn
    with the version number).
    
    1. The **Gist URL** is the URL to the gist you just created.
    
    1. **Minimum Halyard version** should remain unchanged unless you know of a
    reason to change it (in which case, please also change the default for new
    builds).
    
1. Approve the spinnaker-announce email (link will come in email). If this is
your first release manager rotation, please ask a Google team member to add
you as a manager to the spinnaker-announce Google group.

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
   
1. At this point, the following Flow_BuildAndValidate_* jobs should exist:

    - Flow_BuildAndValidate_${RELEASE-2} (BUILDING NIGHTLY)
    
    - Flow_BuildAndValidate_${RELEASE-1} (BUILDING NIGHTLY)
    
    - Flow_BuildAndValidate_${RELEASE} (BUILDING NIGHTLY)
    
    - Flow_BuildAndValidate (master, BUILDING NIGHTLY)
    
1. Ping the [#spinnaker-releases](https://spinnakerteam.slack.com/messages/spinnaker-releases/)
channel to let them know that the new version is available.

1. Publish a Spin CLI minor version.
    
    1. Each Spin CLI release is tied to a version of Gate. To ensure
    compatibility, regenerate the Gate Client API.
    
    1. From the Gate repository, check out the release branch and follow the
    [instructions](https://github.com/spinnaker/spin/blob/master/CONTRIBUTING.md#updating-the-gate-api)
    for updating the generated Gate Client API. Cherry-pick the Gate Client API
    changes onto the Spin CLI release branch. As of writing, the Swagger
    Codegen CLI uses 2.3.1; you can get that JAR [here](https://repo1.maven.org/maven2/io/swagger/swagger-codegen-cli/2.3.1/swagger-codegen-cli-2.3.1.jar).
    If using a different version, you can try modifying the version parameters
    in the URL.
    
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

1. Publish a Sponnet minor version. Run the [publish.sh](https://github.com/spinnaker/sponnet/blob/master/publish.sh)
script while passing in the version number of the new release.
Example: VERSION="1.17.2" ./publish.sh

## Every subsequent Monday: Patch a previous Spinnaker version

Repeat weeklyish for each supported version.

1. Check for any PRs waiting to be [cherry-picked](https://github.com/search?q=org%3Aspinnaker+label%3Acherry-pick+state%3Aopen+type%3Apr).

1. Rerun the Flow_BuildAndValidate_${RELEASE} job and get a green build.

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
   
   1. The version you just released is listed.
   
   1. The changelog for the new version looks correct.  It should start with the
   changelog for the specific patch release, then list the changelog for each
   patch release of the minor version in reverse order.
   
   1. The prior patch release for the minor version has been moved to the
   “Deprecated Versions” section.
    
1. Approve the spinnaker-announce email (link will come in email).

1. Ping the [#spinnaker-releases](https://spinnakerteam.slack.com/messages/spinnaker-releases/)
channel to let them know that the new patch is available.

## Release minor-version Halyard

Repeat every 2-4 weeks as needed.

1. Check for outstanding PRs.

1. Run Flow_BuildAndValidate, selecting `nightly` Halyard. This will
automatically check the “build Halyard” checkbox in the downstream 
Build_PrimaryArtifacts flow.

1. After that passes, navigate to:
https://builds.spinnaker.io/job/Build_PrimaryArtifacts/${JOB_NUMBER}/artifact/build_output/build_halyard/last_version_commit.yml/*view*/
(insert correct JOB_NUMBER) and copy the version (it will be the entire string prior to the colon).

1. Run Publish_HalyardRelease:

    1. Set `HALYARD_BUILD_VERSION_TO_RELEASE` to the version copied from the
    prior step.

## Release patch-version Halyard

Repeat as needed.

1. Run Build_Halyard:

    1. Set **GITHUB_REPO_BRANCH** to the release branch of Halyard
    (e.g., release-1.20.x).
    
    1. Set **OVERRIDE_PROCESS_GITHUB_REPO_BRANCH** to `master`.

1. Run Publish_HalyardRelease:

    1. Set **HALYARD_BUILD_VERSION_TO_RELEASE** to pre-colon output from
    `last_version_commit.yml` of the prior job.

## Publish a new version of deck-kayenta

Repeat as needed.

Follow the instructions in deck-kayenta’s
[README](https://github.com/spinnaker/deck-kayenta#publishing-spinnakerkayenta).
