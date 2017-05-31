---
layout: single
title:  "Life of a Bake"
sidebar:
  nav: reference
---

<div class="mermaid">
sequenceDiagram

Title: Life of a Bake

participant Igor
participant Jenkins
participant ArtifactRepo
participant Echo
participant Front50
participant Orca
participant Rosco
participant Packer
participant Redis
participant Cloud

Echo->>Front50: Build cache of pipeline triggers

Jenkins->>ArtifactRepo: Publish newly-produced deployable asset (e.g. .deb/.rpm/.jar)
Note right of Jenkins: Archive artifacts

Igor->>Jenkins: Poll Jenkins for completed builds
Igor->>Echo: Publish completed build info to eventing bus

Echo->>+Orca: Initiate pipeline execution based on matched trigger
Orca->>Redis: Persist new execution
Note right of Orca: Orca uses the artifact details from the trigger to decorate the package name with version information
Orca->>-Rosco: Request bake, passing package with exact version to install

Rosco->>Redis: Persist new bake
Rosco->>Packer: Initiate bake job, passing repo address (from config) and package/version

Packer->>ArtifactRepo: Pull deployable asset from repo
Packer->>Cloud: Publish machine image

Loop In background thread
  Rosco->>Packer: Poll until job completion
  Rosco->>Redis: Mark bake completed
end

Loop In worker thread
  Orca->>Rosco: Poll until task completion
  Rosco->>Redis: Query bake status
  Orca->>Redis: Update execution state
end

</div>

{% include mermaid %}
