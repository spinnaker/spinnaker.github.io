---
layout: single
title:  "Configure Automated Rollbacks in the Kubernetes Provider V2"
sidebar:
  nav: guides
---

{% include toc %}

There are clear benefits to having your stored manifests (in Git, GCS, etc...)
match as closely as possible to what's running in your cluster: you have
auditability, versioned changes, and a high confidence in what code you have
running. However, in some cases, pushing changes from someplace like GitHub
through your build system all the way production can simply take too long, and
an escape hatch is needed when something has gone seriously wrong. Automated
rollback is that escape hatch.

When using a Deployment object, you can see the history of rollouts in the
"Clusters" tab:

{% include
   figure
   image_path="./revisions.png"
   caption="Version 4 is active, and version 3 has no pods running."
%}

Spinnaker exposes "Undo Rollout" functionality in two places, in the [Clusters
tab](#ad-hoc-rollbacks), and as a [pipeline stage](#automated-rollbacks).

## Ad-hoc rollbacks

In cases where you see something is immediately wrong and isolated to a
resource in the "Clusters" tab, you can select "Undo Rollout" from the
"Actions" dropdown:

{% include
   figure
   image_path="./dropdown.png"
%}

And select the healthy revision to make active again:

{% include
   figure
   image_path="./adhoc.png"
%}

Notice that the old configuration (version 3) will be rolled forward into a
new version (version 5):

{% include
   figure
   image_path="./v005.png"
%}

## Automated rollbacks

You can also configure automated rollbacks inside of Spinnaker pipelines. These
stages are best configured to run when other stages or branches fail,
indicating that something has gone wrong in your rollout.

{% include
   figure
   image_path="rollback-stage.png"
%}

One parameter to watch out for is __Revisions Back__, which counts how many
revisions the current active revision should be rolled back by. If you have the
following state:

```
nginx-deployment-2d8178b77 (Revision 5) # active
nginx-deployment-7bdd110f7 (Revision 4) 
nginx-deployment-0b13cc8c1 (Revision 1) 
```

And roll back by "1" revision, (Revision 4) will be active again. Roll back by
"2" revisions and (Revision 1) will be active again.

> Keep in mind that Kubernetes will implicitly rollforward the old
> configuration, creating (Revision 6) in both cases.

### Parameterized rollbacks

It's worth mentioning that you can parameterize the target resource to
roll back. It can point to something specified using pipeline parameters, and
upstream deploy stage, or another stage's outputs. See more details in the
[pipeline expressions guide](/guides/user/pipeline-expressions).

## Pitfalls

If the artifacts deployed in your manifest (Docker image, ConfigMap, Secret,
...) are not versioned, rolling back your manifest will likely not roll back
your code or config changes. See more details
[here](/guides/user/kubernetes-v2/best-practices#version-your-configmaps-and-secrets).
