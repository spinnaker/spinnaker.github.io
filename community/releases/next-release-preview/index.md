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

## Coming Soon in Release 1.22

### (Breaking Change) Suffix no longer added to jobs created by Kubernetes _Run Job_ stage

Spinnaker no longer automatically appends a unique suffix to the name of jobs
created by the Kubernetes _Run Job_ stage. Prior to this release, if you
specified `metadata.name: my-job`, Spinnaker would update the name to
`my-job-[random-string]` before deploying the job to Kubernetes. As of this
release, the job's name will be passed through to Kubernetes exactly as
supplied.

To continue having a random suffix added to the job name, set the
`metadata.generateName` field instead of `metadata.name`, which causes the
[Kubernetes API](https://kubernetes.io/docs/reference/using-api/api-concepts/#generated-values)
to append a random suffix to the name.

This change is particularly important for users who are using the preconfigured
job stage for Kubernetes, or who are otherwise sharing job stages among
different pipelines. In these cases, jobs are often running concurrently, and it
is important that each job have a unique name. In order to retain the previous
behavior, these users will need to manually update their Kubernetes job
manifests to use the `generateName` field.

Users of Spinnaker >= 1.20.3 can opt in to this new behavior by setting
`kubernetes.jobs.append-suffix: false` in their `clouddriver-local.yml`.

As of Spinnaker 1.22, this new behavior is the default. Users can still opt out
of the new behavior by setting `kubernetes.jobs.append-suffix: true` in their
`clouddriver-local.yml`. This will cause Spinnaker to continue to append a
suffix to the name of jobs as in prior releases.

The ability to opt out of the new behavior will be removed in Spinnaker 1.23.
The above setting will have no effect, and Spinnaker will no longer append a
suffix to job names. It is thus strongly recommended that 1.22 users who opt out
update any necessary jobs and remove the setting before upgrading to Spinnaker
1.23.

### (Breaking Change) Spinnaker Dockerfile GID/UID changes

The Dockerfile of each Spinnaker microservice (except Halyard and Deck) now
specifies an explicit GID and UID of `10111` for the `spinnaker` user.

This is only a breaking change if you were relying on the previous
non-deterministically assigned GID and UID
(for example, in a custom Kubernetes [security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)).

### Navigation and Layout UI Update

Spinnaker's UI has changed! An application's nested menus are now represented as a flat list on the left side of the browser window. The menu can also be collapsed into a condensed view. This allows for better utilization of screen real-estate, and support for any number of additional application pages. As plugin support continues to improve, we hope this refresh to the navigation will give you more flexibility within the UI to make Spinnaker your own. This update also includes changes to the overall layout and design of some application pages to take better advantage of larger screen sizes.

This change should not introduce any interruptions to a vanilla install of `deck`. However, if you've already made navigational changes to your group's instance of `deck` or created custom banners/headers for your app, you may need to make updates. The pattern for creating new routes in the side nav can be observed in the feature's PR:

https://github.com/spinnaker/deck/pull/8239

### Issue Resolved: Clouddriver SQL Cache Data Too Long

We've fixed an issue that prevented data from being stored in Clouddriver's SQL 
Cache because the data was too long 
([Github issue](https://github.com/spinnaker/spinnaker/issues/5600)). As a part
of this fix we introduced a second version of the tables used by Clouddriver
for caching. You should see tables named `cats_v2_*` in your Clouddriver 
database moving forward.

Once you're comfortable with the Spinnaker release and don't expect to roll back 
to a previous version, then you can delete the first version of the tables used 
for caching. In order to easily facilitate deleting these tables we have exposed 
an admin endpoint that will handle the deletion process. The admin endpoint can 
be reached via a `curl PUT` request against 
`{your_clouddriver}/admin/db/drop_version/V1`.
