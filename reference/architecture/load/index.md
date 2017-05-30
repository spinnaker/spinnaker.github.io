---
layout: single
title:  "Life of a Deployment"
sidebar:
  nav: reference
---

<div class="mermaid">
sequenceDiagram

Title: Life of a Deployment

participant Deck
participant Gate
participant Orca
participant Clouddriver
participant Redis
participant Cloud

Deck->>+Gate: Initiate Deploy orchestration
Gate->>+Orca: Initiate Deploy orchestration
Orca->>Redis: Persist new execution
Orca-->>-Gate: Reply with orchestration id
Gate-->>-Deck: Reply with orchestration id

Note right of Orca: In worker thread
Orca->>+Clouddriver: Initiate Deploy operation
Clouddriver->>Redis: Persist new task
Clouddriver-->>-Orca: Reply with task id

Clouddriver-xCloud: Mutating calls
activate Clouddriver
Clouddriver->>Redis: Mark task completed
deactivate Clouddriver

Loop In worker thread
  Orca->>Clouddriver: Poll until task completion
  Clouddriver->>Redis: Query task status
  Orca->>Redis: Update execution state
end

Loop In worker thread
  Orca->>Clouddriver: Poll until instances are up
  Clouddriver->>Redis: Query server group/instance state from cache
  Orca->>Redis: Mark execution completed
end

Loop In background thread
  Deck->>Gate: Poll until orchestration completion
  Gate->>Orca: Query orchestration status
  Orca->>Redis: Query execution status
end

</div>

{% include mermaid %}
