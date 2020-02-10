---
title: Build Statuses
sidebar:
  nav: community

services:
  core:
  - clouddriver
  - deck
  # - deck-kayenta
  - echo
  - fiat
  - front50
  - gate
  - halyard
  - igor
  - kayenta
  - kork
  - orca
  - rosco
  supporting:
  - keel
  - keiko
  - spin
  - spinnaker.github.io
  - spinnaker-gradle-project
  - spinnaker-monitoring
  - swabbie
---

[Build Cop Rotation History](https://github.com/spinnaker/spinnaker/issues?utf8=%E2%9C%93&q=is%3Aissue+label%3Abuild-cop-rotation)

[Build Cop List of Responsibilities](https://www.spinnaker.io/community/contributing/nightly-builds/#build-cop)

## Nightly and Release Integration Tests

> You must be a member of the `build-cops` GitHub Team to access nightly and release integration tests.

* [![Master Build Status](https://builds.spinnaker.io/buildStatus/icon?job=Flow_BuildAndValidate&subject=All%20at%20HEAD){:style="height: 30px"}](https://builds.spinnaker.io/job/Flow_BuildAndValidate/){:target="\_blank"}
* [![1.18.x Build Status](https://builds.spinnaker.io/buildStatus/icon?job=Flow_BuildAndValidate_1_18_x&subject=Release%201.18.x){:style="height: 30px"}](https://builds.spinnaker.io/job/Flow_BuildAndValidate_1_18_x/){:target="\_blank"}
* [![1.17.x Build Status](https://builds.spinnaker.io/buildStatus/icon?job=Flow_BuildAndValidate_1.17.x&subject=Release%201.17.x){:style="height: 30px"}](https://builds.spinnaker.io/job/Flow_BuildAndValidate_1.17.x/){:target="\_blank"}
* [![1.16.x Build Status](https://builds.spinnaker.io/buildStatus/icon?job=Flow_BuildAndValidate_1.16.x&subject=Release%201.16.x){:style="height: 30px"}](https://builds.spinnaker.io/job/Flow_BuildAndValidate_1.16.x/){:target="\_blank"}

## Core Services

{% for svc in page.services.core %}
  {% capture altTxt%}{{svc | captialize }} Build Status{% endcapture %}
  {% capture travisStatusImg%}https://api.travis-ci.org/spinnaker/{{svc}}.svg?branch=master{% endcapture %}
  {% capture travisLink%}https://travis-ci.org/spinnaker/{{svc}}{% endcapture%}
  {% capture githubStatusImg%}https://github.com/spinnaker/{{svc}}/workflows/{{svc | capitalize}}%20CI/badge.svg{% endcapture %}
  {% capture githubLink%}https://github.com/spinnaker/{{svc}}/actions?query=workflow%3A%22{{svc | capitalize}}+CI%22+branch%3Amaster{% endcapture%}

  * [![{{altTxt}}]({{travisStatusImg}}){:style="height: 30px"}]({{travisLink}}){:target="\_blank"} [![{{altTxt}}]({{githubStatusImg}}){:style="height: 30px"}]({{githubLink}}){:target="\_blank"}
{% endfor %}


## Optional and Supporting Services

{% for svc in page.services.supporting %}
  {% capture altTxt%}{{svc | captialize }} Build Status{% endcapture %}
  {% capture travisStatusImg%}https://api.travis-ci.org/spinnaker/{{svc}}.svg?branch=master{% endcapture %}
  {% capture travisLink%}https://travis-ci.org/spinnaker/{{svc}}{% endcapture%}
  {% capture githubStatusImg%}https://github.com/spinnaker/{{svc}}/workflows/{{svc | capitalize}}%20CI/badge.svg{% endcapture %}
  {% capture githubLink%}https://github.com/spinnaker/{{svc}}/actions?query=workflow%3A%22{{svc | capitalize}}+CI%22+branch%3Amaster{% endcapture%}

  * [![{{altTxt}}]({{travisStatusImg}}){:style="height: 30px"}]({{travisLink}}){:target="\_blank"} [![{{altTxt}}]({{githubStatusImg}}){:style="height: 30px"}]({{githubLink}}){:target="\_blank"}
{% endfor %}
