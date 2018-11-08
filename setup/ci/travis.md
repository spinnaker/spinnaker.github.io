---
layout: single
title:  "Travis CI"
sidebar:
  nav: setup
---

{% include toc %}

You can configure Spinnaker to use [Travis
CI](https://travis-ci.org/){:target="\_blank"} as your Continuous Integration
system, trigger pipelines with Jenkins, or add a Jenkins stage to a pipeline.

## Prerequisites

* You need a Travis user with an [API access token]() so that you get only the repos you should see.

* That user needs adequate access in GitHub to trigger builds.

## Add your Travis CI master

1. Enable Travis CI:

   `hal config ci travis enable`

1. Add a Travis CI master named my-travis-master (an arbitrary human-readable
name):

   a. Set the following environment variables:

      ```
      $ADDRESS: https://api.travis-ci.org
      $BASE_URL: https://travis-ci.org
      $GITHUB_TOKEN
      $NUM_REPOS
      ```

```
   hal config ci travis master add my-travis-master \
   --address $ADDRESS \
   --base-url $BASE_URL \
   --github-token $GITHUB_TOKEN \
   --number-of-repositories $NUM_REPOS
   ```









Documentation for this feature is coming soon! 
