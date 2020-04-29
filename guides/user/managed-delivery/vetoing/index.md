---
layout: single
title: "Vetoing a Version"
sidebar:
  nav: guides
---

{% include toc %}

You can veto a version in an environment to ensure that that version never gets deploy to the environment.
If you veto an artifact in the first in a series of environments (linked together by `depends-on` constraints) the vetoed artifact will never be promoted into the later environments.

### Vetoing via the API

To veto via the API you'll need the application name, the name of the environment, the reference for your artifact (defined in your delivery config, defaulted to the artifact name), and the version you'd like to veto.
The request needs to have a body that contains [this information](https://github.com/spinnaker/gate/blob/master/gate-core/src/main/groovy/com/netflix/spinnaker/gate/model/manageddelivery/EnvironmentArtifactVeto.java). 
Here's an example:

`POST /managed/application/{application}/veto`

with body: 
```json

{
  "targetEnvironment": "test",
  "reference" : "my-artifact",
  "version" : "master-h10.62bbbd6"
}
```
