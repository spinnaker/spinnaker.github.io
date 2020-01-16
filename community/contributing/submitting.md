---
layout: single
title:  "Submitting A Patch"
sidebar:
  nav: community
redirect_from: /docs/how-to-submit-a-patch
---

{% include toc %}

## Before you begin

We prefer small, well tested pull requests. Note that we are unlikely to accept
pull requests that add features without prior discussion. The best way to
propose a feature is to first [open an
issue](https://github.com/spinnaker/spinnaker/issues/new), ping the [#dev
channel](https://spinnakerteam.slack.com/messages/C0DPVDMQE/) in slack and
discuss your ideas before implementing them.

It's possible that we'll encourage you to write a "design doc" if your change
is large or impactful enough. There are no formal requirements, but we
encourage you to discuss the following points:

* Why this change is necessary, and what problem(s) it solves.
* What alternatives you considered.
* How it will integrate with other Spinnaker features.
* A rough, technical plan of the work required.
* What integration testing you think is necessary.
* (Optional) Implementation milestones you plan to hit.

Once your design doc is ready, the community will review it and leave feedback.

## When you initiate a Pull Request from Github

* Provide a descriptive title for your changes.
* Add inline code comments to changes that might not be obvious.
* Squash your commits into logically reviewably chunks when you first submit
  your PR. Address feedback in follow-up (unsquashed) commits. It's much easier
  to review incremental changes to feedback when the commits are kept separate.
* Squash your commits when merging to the branch.

## Commit message conventions

Please follow the following conventions in your git commit messages.

Once you've implemented a bug fix or feature, it's time to submit a patch to Spinnaker. In order to track and summarize the changes happening in Spinnaker, we use a changelog automation tool called [clog](https://github.com/clog-tool/clog-cli) which scrapes information from commit messages. We follow the ['conventional'](https://github.com/conventional-changelog/conventional-changelog/blob/a5505865ff3dd710cf757f50530e73ef0ca641da/conventions/angular.md) commit message format.

As a summary, messages should be formatted like:

```
<type>(<scope>): <subject>
<empty line>
<body>
<empty line>
<footer>
```

#### Type

Type | Purpose
--------|------------
feat | A new feature. Please also link to the issue (in the body) if applicable. Causes a minor version bump.
fix | A bug fix. Please also link to the issue (in the body) if applicable.
docs | A documentation change.
style | A code change that does not affect the meaning of the code, (e.g. indentation).
refactor | A code change that neither fixes a bug or add a feature.
perf | A code change that improves performance.
test | Adding missing tests.
chore | Changes to build process or auxiliary tools or libraries such as documentation generation.
config | Changes to configurations that have tangible effects on users, (e.g. renaming properties, changing defaults, etc).

The type of keyword affects the next semantic version bump. The `feat` keyword causes a minor version bump, while the rest of the keywords cause a patch version bump. Major version bumps are triggered by the presence of the words `BREAKING CHANGE` in the _commit message body_. This is covered more in [Body](#body).

If you _don't_ use one of the previous types (or don't follow the convention), your commit will not be included in the generated changelog. Your change will still affect the next semantic version bump, but it will be considered a patch change, not a major or minor change (even if the change is a breaking change or a feature).

If you submit a pull request with multiple commits and choose to _Squash and Merge_ the pull request, the individual commit message **are not** added to the changelog, **only the pull request message is**. To include each commit in your pull request in the changelog and next version calculation, _merge the changes without squashing_.

#### Scope

The `scope` of the commit message indicates the area or feature of Spinnaker the commit applies to. For instance, if you were to submit a patch to the Google provider in Clouddriver, your commit message might look something like:

```
feat(provider/google): Updated forwarding rule schema.
```

or if you submit a fix pertaining to authentication in Gate:

```
fix(authN): Fixed session authentication coherence.
```

The `scope` is purposefully left open-ended, but try to group similar changes using the same value. Changes that have the same `scope` will be grouped together during changelog generation:

**Features**
* Some_scope
  - First feature goes here.
  - Second feature goes here.

#### Subject

The `subject` should be a short summary of the patch.

#### Body

The `body` should include any detailed information about the patch; however, these can also go in the pull request body.

#### Footer

Any information about breaking changes should be present in the footer. To signify a breaking change, add one line at the end of the commit message with 'BREAKING CHANGE' in the line:

```
feat(provider/google): Added a very important and breaking feature.

BREAKING CHANGE: More detail here if necessary.
```

Note that at minimum, 'BREAKING CHANGE' must be specified on the last line. The extra detail is not mandatory.
