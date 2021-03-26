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

### Git pull support for git/repo artifacts

In Spinnaker < 1.26 every time a `git/repo` artifact was needed during a pipeline execution, clouddriver cloned the repository, returned the files and deleted the clone immediately.

Now in Spinnaker 1.26 we added support for "caching" git repositories, so only the first time the repository is needed it will be cloned, and subsequent times clouddriver will do a `git pull` to only download updates. It is expected that this dramatically improves execution times and reliability when working with big repositories.

This is an opt-in feature that is disabled by default, to use it you need to add to clouddriver profile configuration the following options:

```yaml
artifacts:
  gitrepo:
    clone-retention-minutes: 0           # (Default: 0). How much time to keep clones. 0: no retention, -1: retain forever
    clone-retention-max-bytes: 104857600 # (Default: 100 MB). Maximum amount of disk space to use for clones.
```

When the maximum amount of space configured for clone retention is reached, clones will be deleted after returning from the download request, just as if retention was disabled.