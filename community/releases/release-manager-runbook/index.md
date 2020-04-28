---
layout: single
title:  "Release Manager Runbook"
sidebar:
  nav: community
---

{% include toc %}

## Friday before the release window opens

1. Ping #dev reminding everyone to merge outstanding changes
by Monday:

> I'll be cutting the $VERSION release branches on Tuesday,
> so if there are any outstanding PRs that you'd like to get into $VERSION,
> please make sure they are merged by EOD Monday. Once the branch is cut, only
> fixes will be accepted into the release branches.

## First Monday of the release window

1. Ping #dev reminding everyone to merge outstanding changes ASAP:

> I'll be cutting the $VERSION release branches tomorrow morning, so if
> there are any outstanding PRs that you'd like to get into $VERSION, please make
> sure they are merged ASAP. Once the branch is cut, only fixes will be accepted
> into the release branches.

## First Tuesday of the release window

1. Reach out to anyone who has previously contacted you to ensure their
last-minute release PRs have been merged.

2. Merge all [kork version autobump PRs](https://github.com/issues?q=is%3Aopen+is%3Apr+org%3Aspinnaker+archived%3Afalse+-repo%3Aspinnaker%2Fspinnaker.github.io+-repo%3Aspinnaker%2Froer+-repo%3Aspinnaker%2Fkeel+-repo%3Aspinnaker%2Fdeck-customized+-repo%3Aspinnaker%2Fswabbie+-repo%3Aspinnaker%2Fstyleguide+-repo%3Aspinnaker%2Fdcd-spec+label%3Aautobump-kork)
opened by Spinnakerbot.

3. Start with a [green build on master](https://builds.spinnaker.io/job/Flow_BuildAndValidate/).

4. Create the release branches by running the [**Admin_StartReleaseBranch**](https://builds.spinnaker.io/job/Admin_StartReleaseBranch/build?delay=0sec)
job:
    
    a. Set **NEW_BRANCH_NAME** to `${RELEASE_BRANCH}` (e.g., `release-1.20.x`).
    
    b. Set **BASE_BRANCH** to `master`.

5. Deactivate the now-oldest Flow_BuildAndValidate_* flow:

    a. Select the oldest flow.

    b. Click **Configure** from the left hand side of the menu.

    c. Scroll to the **Build Triggers** section.

    d. Cut text out of **Schedule** box (you will need to paste this soon).
    
    e. Save.

6. Create a new Flow_BuildAndValidate_* flow for the release branch.

    a. Click **New Item** on the left hand side of the main menu.

    b. Set **Name** to Flow_BuildAndValidate_${RELEASE} (e.g., `1_18_x`). Note
    that the newer versions of Jenkins seem to disallow the `.` character in the
    job name, so will want to `s/./_`.
    
    c. Set **Copy from** to Flow_BuildAndValidate.

    d. In the **Build Triggers** section, paste cut text from the second-oldest
    flow.
    
    e. Set **GITHUB_REPO BRANCH** to `${RELEASE_BRANCH}`.
    
    f. Set **PROCESS_GITHUB_REPO_BRANCH** TO `${RELEASE_BRANCH}`.
    
7. At this point, there should exist the following Flow_BuildAndValidate_* jobs:

    a. Flow_BuildAndValidate_${RELEASE-3} (DEACTIVATED)
    
    b. Flow_BuildAndValidate_${RELEASE-2} (BUILDING NIGHTLY)
    
    c. Flow_BuildAndValidate_${RELEASE-1} (BUILDING NIGHTLY)
    
    d. Flow_BuildAndValidate_${RELEASE} (BUILDING NIGHTLY)
    
    e. Flow_BuildAndValidate (master, BUILDING NIGHTLY)
    
8. Run the Flow_BuildAndValidate_${RELEASE} job.

    a. Select `stable` for **HALYARD_RELEASE_TRACK**.
    
    b. This will automatically update the [changelog gist](https://gist.github.com/spinnaker-release/4f8cd09490870ae9ebf78be3be1763ee)
    on GitHub.
    
9. Add the new Flow_BuildAndValidate_${RELEASE} job to the public
[Build Statuses page](https://www.spinnaker.io/community/contributing/build-statuses/#nightly-and-release-integration-tests).
Ping #dev with some version of this message, including a link to the correct
section of the changelog gist:

> The release window for Spinnaker $VERSION is now open!  This means that
> release branches have been cut from master and those branches are only
> accepting fixes for existing features.  Please contact $YOUR_NAME
> (slack: $YOUR_SLACK_ID, github: $YOUR_GITHUB_ID, or email: $YOUR_EMAIL) if you
> would like a fix cherry-picked into the release or you would like to highlight
> a specific fix or feature in the release’s changelog. If you’d like to jog
> your memory of everything to be released with Spinnaker $VERSION, see the raw
> changelog here: $LINK_TO_CHANGELOG.

10. Share a curated changelog with any partners from the community who wants to
add notes.

11. When the Flow_BuildAndValidate_${RELEASE} job passes, ping #dev with a
message that release candidate is now validated and can be tested by running:

```
hal config version edit --version ${RELEASE_BRANCH}-latest-validated
```

## Second Monday of the release window

1. Check for any PRs waiting to be [cherry-picked](https://github.com/search?q=org%3Aspinnaker+label%3Acherry-pick+state%3Aopen+type%3Apr).
(You can further restrict the query by adding a constraint like +base:release-1.18.x to the URL.)

2. Rerun the Flow_BuildAndValidate_${RELEASE} job and get a green build.

3. Create a new gist for this release.

    a. Log into GitHub as spinnaker-release and create a new gist to hold the
    release notes for this release branch.
    
    b. The description should be “Spinnaker 1.nn.x Release Notes” (e.g.,
    Spinnaker 1.18.x Release Notes). The gist will eventually have a separate
    file with the release notes for each patch release on this branch.

    c. Add a file 1.nn.0.md (e.g., `1.18.0.md`) to hold the release notes for
    the new release.
    
    d. Copy the changes for this release from the raw build changelog to the new
    1.nn.0.md file.

    e. Add the notes from the curated changelog to the top of the gist,
    formatting them for Markdown ([sample 1.nn.0 release notes](https://gist.github.com/spinnaker-release/cc4410d674679c5765246a40f28e3cad)).

4. Run Publish_SpinnakerRelease:

    a. **Spinnaker Version** is "1.nn.0" (replacing nn with the version number).
    
    b. **Spinnaker Release Alias** should be the name of a Netflix original TV
    show converted to a camel-case alphanumeric string
    (e.g., "MichaelBoltonsBigSexyValentinesDaySpecial").
    
    c. **BOM version** should be "release-1.nn.x-latest-validated" (replacing nn
    with the version number).
    
    d. The **Gist URL** is the URL to the gist you just created.
    
    e. **Minimum Halyard version** should remain unchanged unless you know of a
    reason to change it (in which case, please also change the default for new
    builds).
    
5. Approve the spinnaker-announce email (link will come in email). Currently,
only members of the Google Spinnaker OSS team can approve the email.

6. Deprecate the n-3 release (i.e. when releasing 1.18, deprecate 1.15).

    a. From the Jenkins machine, run:

```
hal admin deprecate version --version ${VERSION_TO_DEPRECATE}
```

   b. Make a PR against correct changelog
   [here](https://github.com/spinnaker/spinnaker.github.io/tree/master/_changelogs),
   adding `deprecated` to the list of tags.
   
   c. Delete the associated Jenkins project (e.g., Flow_BuildAndValidate_${RELEASE-3}).
   
   d. Remove the changelog from the [master gist](https://gist.github.com/spinnaker-release/4f8cd09490870ae9ebf78be3be1763ee).
   (While logged in as spinnaker-release, click "Edit", scroll to the file, and
   click "Delete".)
   
7. At this point, there should exist the following Flow_BuildAndValidate_* jobs:

    a. Flow_BuildAndValidate_${RELEASE-2} (BUILDING NIGHTLY)
    
    b. Flow_BuildAndValidate_${RELEASE-1} (BUILDING NIGHTLY)
    
    c. Flow_BuildAndValidate_${RELEASE} (BUILDING NIGHTLY)
    
    d. Flow_BuildAndValidate (master, BUILDING NIGHTLY)
    
8. Ping the #spinnaker-releases channel to let them know that the new version is
available.

9. Publish a Spin CLI minor version.
    
    a. Each Spin CLI release is tied to a version of Gate. To ensure
    compatibility, regenerate the Gate Client API.
    
    b. From the Gate repository, check out the release branch and follow the
    [instructions](https://github.com/spinnaker/spin/blob/master/CONTRIBUTING.md#updating-the-gate-api)
    for updating the generated Gate Client API. Cherry-pick the Gate Client API
    changes onto the Spin CLI release branch. As of writing, the Swagger
    Codegen CLI uses 2.3.1; you can get that JAR [here](https://repo1.maven.org/maven2/io/swagger/swagger-codegen-cli/2.3.1/swagger-codegen-cli-2.3.1.jar).
    If using a different version, you can try modifying the version parameters
    in the URL.
    
    c. If regenerating the Gate Client API produced any changes, kick off the
    Flow_BuildAndValidate_1.xx.x for the release branch and wait for a successful
    completion. This will trigger a downstream Build_PrimaryArtifacts job that
    we rely on later.
    
    d. Run Publish_SpinRelease with the following parameters:
    
    - SPIN_BUILD_VERSION_TO_RELEASE: This can be found in the build_spin files
    written by the Build_PrimaryArtifacts job. Use the version found in the most
    recent run of the Build_PrimaryArtifacts for the release branch. Note: The
    major minor part of this version number should match the Gate version for
    the release branch. If it does not, double check that a tag for the previous
    minor version of Spin CLI exists. The build auto increments new tags based
    on the highest pre-existing minor tag.
    
    - BOM_VERSION: This is the BOM to associate the Spin CLI release with. It is
    the latest Spinnaker release number, 1.xx.x.

10. Publish a Sponnet minor version. Run the [publish.sh](https://github.com/spinnaker/spinnaker/blob/master/sponnet/publish.sh)
script while passing in the version number of the new release.
Example: VERSION="1.17.2" ./publish.sh

## Every subsequent Monday: Patch a previous Spinnaker version (repeat weeklyish
for each supported version)

1. Check for any PRs waiting to be [cherry-picked](https://github.com/search?q=org%3Aspinnaker+label%3Acherry-pick+state%3Aopen+type%3Apr).

2. Rerun the Flow_BuildAndValidate_${RELEASE} job and get a green build.

3. Run Publish_SpinnakerPatchRelease:

    a. Enter the major and minor version of the release you’re patching
    (ex: 1.18) in MAJOR_MINOR_VERSION.
    b. All other fields can be left as defaults/blank.
   
   This looks for a currently active release with this major and minor version.
   It copies all parameters from that release (name, changelog gist, minimum
   Halyard version), increments the patch version, and triggers
   Publish_SpinnakerRelease with these parameters. In general, this is exactly
   the behavior we want, but if you need to override this behavior (such as to
   increment the minimum Halyard version in a patch release), you can call
   Publish_SpinnakerRelease directly and pass the exact parameters that you’d
   like the new release to have.

4. After the job has completed, run ```hal version list``` and verify that the
version you just released is listed, and the prior patch release for the minor
version is no longer listed.

5. Go to to [spinnaker.io](https://www.spinnaker.io/community/releases/versions/)
and verify the following (leaving time for the site to rebuild):
   
   a. The version you just released is listed.
   
   b. The changelog for the new version looks correct.  It should start with the
   changelog for the specific patch release, then list the changelog for each
   patch release of the minor version in reverse order.
   
   c. The prior patch release for the minor version has been moved to the
   “Deprecated Versions” section.
    
6. Approve the spinnaker-announce email (link will come in email).

7. Ping the #spinnaker-releases channel to let them know that the new patch is
available.

## Release minor-version Halyard (repeat every 2-4 weeks as needed)

1. Check for outstanding PRs.

2. Run Flow_BuildAndValidate, selecting `nightly` Halyard. This will
automatically check the “build Halyard” checkbox in the downstream 
Build_PrimaryArtifacts flow.

3. After that passes, navigate to:
https://builds.spinnaker.io/job/Build_PrimaryArtifacts/${JOB_NUMBER}/artifact/build_output/build_halyard/last_version_commit.yml/*view*/
(insert correct JOB_NUMBER) and copy the version (it will be the entire string prior to the colon).

4. Run Publish_HalyardRelease:

    a. Set `HALYARD_BUILD_VERSION_TO_RELEASE` to the version copied from the
    prior step.

## Release patch-version Halyard (repeat as needed)

1. Run Build_Halyard:

    a. Set **GITHUB_REPO_BRANCH** to the release branch of Halyard
    (e.g., release-1.20.x).
    
    b. Set **OVERRIDE_PROCESS_GITHUB_REPO_BRANCH** to `master`.

2. Run Publish_HalyardRelease:

    a. Set **HALYARD_BUILD_VERSION_TO_RELEASE** to pre-colon output from
    `last_version_commit.yml` of the prior job.
    
## Publish a new version of Spinbot (repeat as needed)

1. Ensure no build is currently in progress.

2. From your machine, run:
   
    ```
   git clone https://github.com/spinnaker/spinnakerbot \
   && cd spinnakerbot
   ```
   
   Ensure you’re on the `master` branch:
   
   ```
   git checkout master && git pull origin master
   ```
   
   Publish Spinbot:
   
   ```
    make docker
   ```

## Publish a new version of deck-kayenta (repeat as needed)

1. Follow the instructions in deck-kayenta’s
[README](https://github.com/spinnaker/deck-kayenta#publishing-spinnakerkayenta).
