---
layout: single
title:  "Front50: Cassandra to Redis"
sidebar:
  nav: guides
redirect_from: /docs/front50-cassandra-to-redis
---

{% include toc %}

## 1. Install Redis 

## 2. Disable Cassandra in front50.yml

```
cassandra:
  enabled: false
```

## 3. Enable Redis in front50.yml

```
spinnaker:
  redis:
    enabled: true
```

## 4. Export existing applications, pipelines, strategies, notifications and projects

```
#!/bin/sh

rm applications.json
curl http://FRONT50_HOSTNAME:FRONT50_PORT/global/applications | json_pp > applications.json

rm pipelines.json
curl http://FRONT50_HOSTNAME:FRONT50_PORT/pipelines | json_pp > pipelines.json

rm strategies.json
curl http://FRONT50_HOSTNAME:FRONT50_PORT/strategies | json_pp > strategies.json

rm notifications.json
curl http://FRONT50_HOSTNAME:FRONT50_PORT/notifications | json_pp > notifications.json

rm projects.json
curl http://FRONT50_HOSTNAME:FRONT50_PORT/v2/projects | json_pp | jq '._embedded.projects' > projects.json
```

## 5. Deploy new Front50

## 6. Import applications, pipelines, strategies, notifications and projects

```
#!/bin/sh

curl -X POST -H "Content-type: application/json" --data-binary @"notifications.json" http://FRONT50_HOSTNAME:FRONT50_PORT/notifications/batchUpdate
curl -X POST -H "Content-type: application/json" --data-binary @"strategies.json" http://FRONT50_HOSTNAME:FRONT50_PORT/strategies/batchUpdate
curl -X POST -H "Content-type: application/json" --data-binary @"pipelines.json" http://FRONT50_HOSTNAME:FRONT50_PORT/pipelines/batchUpdate
curl -X POST -H "Content-type: application/json" --data-binary @"applications.json" http://FRONT50_HOSTNAME:FRONT50_PORT/global/applications/batchUpdate
curl -X POST -H "Content-type: application/json" --data-binary @"projects.json" http://FRONT50_HOSTNAME:FRONT50_PORT/v2/projects/batchUpdate
```
