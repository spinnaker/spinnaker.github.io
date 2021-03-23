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

## Coming Soon in Release 1.26

### (Breaking Change) Suffix no longer added to jobs created by Kubernetes Run Job stage

As a followup to [this change in Spinnaker version 1.22](https://spinnaker.io/community/releases/versions/1-22-0-changelog#breaking-change-suffix-no-longer-added-to-jobs-created-by-kuber), Spinnaker 1.26 removes the `kubernetes.jobs.append-suffix` flag.  Note that the default value of this flag was false in Spinnaker version >= 1.22.  To continue having a random suffix added to the job name, set the `metadata.generateName` field instead of `metadata.name`, which causes the [Kubernetes API](https://kubernetes.io/docs/reference/using-api/api-concepts/#generated-values) to append a random suffix to the name.
