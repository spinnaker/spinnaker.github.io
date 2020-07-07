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
