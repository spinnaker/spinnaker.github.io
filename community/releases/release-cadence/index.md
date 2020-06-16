---
title:  "Release Cadence"
sidebar:
  nav: community
---

{% include toc %}

The Spinnaker team is committed to providing a regular release cadence in order
to help users understand when new features will be available, as well as help
non-core developers plan to get their features released in the next stable
version of Spinnaker.

## Cutting the Release Branches

Every eight weeks, we cut release branches for the upcoming release. If the
version we intend to release is `M.N`, a branch with the name `release-M.N.x` is
cut in each component repository. For example, see the state of the
[Clouddriver](https://github.com/spinnaker/clouddriver/) repository leading up
to the 1.6 release:

{% include
   figure
   image_path="./branches.png"
%}

We call this snapshot of all the Spinnaker repositories the "Release
Candidate".

### Running the Release Candidate

> If you're brave enough to run the Release Candidate, please [file
> bugs](https://github.com/spinnaker/spinnaker/issues) or alert us 
> on [slack](http://join.spinnaker.io) if you find any problems!

Once these release branches are cut, anyone can run the release candidate using
version `release-M.N.x-latest-unvalidated`:

```bash
# this would be version 'release-1.6.x-latest-unvalidated' for 1.6
hal config version edit --version release-M.N.x-latest-unvalidated

hal deploy apply
```

### Patching the Release Candidate

{% include
   warning
   content="Do not merge feature code into a release branch, only fixes are
   accepted."
%}

If you've found a fix for a bug in the Release Candidate, follow the [patching
procedure described
here](/community/contributing/releasing/#merge-into-the-release-branch). If
your patch is merged before the [release candidate is marked
stable](#marking-the-release-candidate-stable), it will be included in this
release.

Unless a severe error (e.g. security vulnerability, large-scale breakage) has a
pending patch, patch releases are published at a weekly cadence on a
best-effort basis.

### Marking the Release Candidate Stable

Once the community has deemed that the Candidate is "stable" (meaning all
[integration
tests](https://github.com/spinnaker/spinnaker/tree/master/testing/citest) are
passing, and no known issues or regressions remain), we will release Spinnaker
at version `M.N.0`. Further patches can be merged into the release branch for
future patch releases (e.g. `M.N.1`).

## Upcoming Releases

There's a public calendar you can subscribe to which includes important release dates.

* If you use Google Calendar, [click here to subscribe](https://calendar.google.com/calendar?cid=c3Bpbm5ha2VyLmlvX3AybjhzZWd2bG5lbDRjYm83NzdlbTM1YjBjQGdyb3VwLmNhbGVuZGFyLmdvb2dsZS5jb20).
* If you don't use Google Calendar or have trouble with the first link, you can copy this iCal URL to subscribe using your calendar app of choice (instructions for [Google](https://support.google.com/calendar/answer/37100), [Apple Calendar](https://support.apple.com/guide/calendar/subscribe-to-calendars-icl1022/mac)):
   ```
   https://calendar.google.com/calendar/ical/spinnaker.io_p2n8segvlnel4cbo777em35b0c%40group.calendar.google.com/public/basic.ics
   ```
* If you don't want to subscribe directly, you can check the calendar below:

<iframe src="https://calendar.google.com/calendar/embed?src=spinnaker.io_p2n8segvlnel4cbo777em35b0c%40group.calendar.google.com&ctz=America%2FNew_York" style="border: 0" width="800" height="600" frameborder="0" scrolling="no"></iframe>
