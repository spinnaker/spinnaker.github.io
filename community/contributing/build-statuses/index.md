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
  - igor
  - kayenta
  - kork
  - orca
  - rosco
  - spinnaker-monitoring
  supporting:
  - halyard
  - keel
  - keiko
  - spin
  - spinnaker.github.io
  - spinnaker-gradle-project
  - swabbie

branches:
- master
- release-1.26.x
- release-1.25.x
- release-1.24.x
---

[Build Cop Rotation History](https://github.com/spinnaker/spinnaker/issues?utf8=%E2%9C%93&q=is%3Aissue+label%3Abuild-cop-rotation)

[Build Cop List of Responsibilities](https://www.spinnaker.io/community/contributing/nightly-builds/#build-cop)

## Nightly and Release Integration Tests

> You must be a member of the `build-cops` GitHub Team to access nightly and release integration tests.

{% for branch in page.branches %}
  {%- capture subject -%}{{branch | capitalize}}{%- endcapture -%}
  {%- if branch == "master" -%}
    {%- capture job -%}Flow_BuildAndValidate{%- endcapture -%}
  {%- else -%}
    {%- capture job -%}Flow_BuildAndValidate_{{branch | remove: "release-" | replace: ".", "_"}}{%- endcapture -%}
  {%- endif -%}
* [![{{branch}} Build Status](https://builds.spinnaker.io/buildStatus/icon?job={{job}}&subject={{subject}}){:style="height: 25px"}](https://builds.spinnaker.io/job/{{job}}/){:target="\_blank"}
{% endfor %}


## Core Services

Service | Branch | Status
------- | ------ | ------
{% for svc in page.services.core %}
  {%- for branch in page.branches -%}
    {%- if branch == "master" -%}
      {%- capture svcCol -%}**{{ svc | capitalize }}**{%- endcapture -%}
    {%- else -%}
      {%- capture svcCol -%}{%- endcapture -%}
    {%- endif -%}
    {%- capture altTxt -%}{{ svc | capitalize }} Build Status{%- endcapture -%}
    {%- capture githubStatusImg -%}https://github.com/spinnaker/{{svc}}/workflows/Branch%20Build/badge.svg?branch={{branch}}{%- endcapture -%}
    {%- capture githubLink -%}https://github.com/spinnaker/{{svc}}/actions?query=workflow%3A%22Branch+Build%22+branch%3A{{branch}}{%- endcapture -%}

    {{svcCol}} | `{{branch}}` | [![{{altTxt}}]({{githubStatusImg}}){:style="height: 25px"}]({{githubLink}}){:target="\_blank"}
{% endfor %}{% endfor %}


## Optional and Supporting Services

{% for svc in page.services.supporting %}
  {% capture altTxt %}{{ svc | capitalize }} Build Status{% endcapture %}
  {% capture githubStatusImg %}https://github.com/spinnaker/{{svc}}/workflows/Branch%20Build/badge.svg{% endcapture %}
  {% capture githubLink %}https://github.com/spinnaker/{{svc}}/actions?query=workflow%3A%22Branch+Build%22+branch%3Amaster{% endcapture %}

  * {{svc | capitalize }} [![{{altTxt}}]({{githubStatusImg}}){:style="height: 25px"}]({{githubLink}}){:target="\_blank"}
{% endfor %}
