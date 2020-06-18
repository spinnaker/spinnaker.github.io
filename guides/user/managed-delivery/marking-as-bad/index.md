---
layout: single
title: "Marking an Artifact as Bad"
sidebar:
  nav: guides
---

{% include toc %}

You can mark a version of an artifact in an environment as bad to ensure that that version never gets deployed to the environment.
If you mark an artifact as bad in the first in a series of environments (linked together by `depends-on` constraints) that version of the artifact will never be promoted into the later environments.

### Marking via the API

To mark the artifact via the API you'll need the application name, the name of the environment, the reference for your artifact (defined in your delivery config, defaulted to the artifact name), and the version that is bad.
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
