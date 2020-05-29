---
layout: single
title: "Managing Deprecations"
sidebar:
  nav: community
---

Deprecating old functionality is key to making Spinnaker easier to maintain, but it needs to be done in a way that is as non-disruptive as possible.

## Before you begin

The best way to propose a deprecation is to first [open an issue](https://github.com/spinnaker/spinnaker/issues/new), ping the [#dev channel](https://spinnakerteam.slack.com/messages/C0DPVDMQE/) in Slack, and discuss your deprecation before taking action.

Often times, you will need the following information:

1. An overview of what the functionality does or intended to do.
1. A description of why this functionality should be deprecated and, eventually, removed.
1. A description of the replacement functionality, if any, or information about why this functionality will not need a replacement.
1. The scope of impact on the codebase: What services will be affected?
1. How will users migrate off this functionality?[^1]

## Deprecation approval

Before a deprecation cycle starts, it must be approved by either the SIG owning the functionality, or by the Technical Oversight Committee.
This approval is noted by labeling the issue as "approved" or "rejected", depending on the decision.

## Deprecation cycles

A deprecation must be announced at least 1 release cycle in advance of when the functionality will be removed; however, a less aggressive window should generally be used.
Deprecation announcements should be added to the [Next Release Preview page](/community/releases/next-release-preview) with a link to the relevant GitHub issue as well as links to any other supporting documentation, such as configuration or migration docs.

Once the Spinnaker version with the deprecation announcement gets released, you are encouraged to remove the deprecated code from the codebase as soon as possible. This gives you and others sufficient time to fix edge cases that may arise from the removal before the next Spinnaker release.

[1^]: Automated migrations are not always possible. In lieu of a migration, documentation must be provided on how to migrate installations.
