---
layout: single
title:  "Travis CI"
sidebar:
  nav: setup
---

{% include toc %}

You can configure Spinnaker to use [Travis
CI](https://travis-ci.org/){:target="\_blank"} as your Continuous Integration
system, trigger pipelines with Travis, or add a Travis stage to a pipeline.

## Prerequisites

* You need a Travis user with an [API access
token](https://docs.travis-ci.com/api/#authentication) so that you get only the
repos you should see.

* That user needs adequate access in GitHub to trigger builds.

## Add your Travis CI master

1. Enable Travis CI:

   `hal config ci travis enable`

1. Turn on the Travis stage feature:

   `hal config features edit --travis true`

1. Add a Travis CI master named my-travis-master (or any arbitrary human-readable
name):

   ```
   hal config ci travis master add my-travis-master \
   --address https://api.travis-ci.org \
   --base-url https://travis-ci.org \
   --github-token <token> \ # The GitHub token to authenticate to Travis
   --number-of-jobs # How many jobs the integration should fetch each
                    # time the poller runs. Set this higher than the max
                    # you expect during polling interval.
                    # Defaults to 100.
   ```
