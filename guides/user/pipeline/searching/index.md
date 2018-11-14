---
layout: single
title:  "Searching for Triggered Pipeline Executions"
sidebar:
  nav: guides
redirect_from: /guides/user/triggers/searching
---

{% include toc %}

This guide describes how to use the `searchForPipelineExecutionsByTrigger` API to search for pipeline executions triggered by Pub/Sub messages or webhooks.

## Pub/Sub

### Structure your trigger

When you create the Pub/Sub message, add a field that can be used to identify the message. For example, you can add an `id` field with a randomly generated GUID string as its value.

```json
{
  "id": "9c3036f6-3791-47eb-bb69-30983acb00be"
}
```

This `id` field can be used later to search for all pipelines executed by this trigger.

### Query your triggered pipelines

To query for pipeline triggered by a specific Pub/Sub message, you can structure your API call with the following information:

```bash
APPLICATION=<application-name>  # This will narrow down results to only contain pipeline executions within a given application. You may supply '*' here to search across all applications.
TRIGGER_TYPE=pubsub  # This will narrow down results to only contain pipelines executions triggered by a Pub/Sub message
TRIGGER=$(echo '{ "id": "9c3036f6-3791-47eb-bb69-30983acb00be" }' | base64)  # This will narrow down results to only contain pipeline executions triggered with a payload that includes this key/value. We base64-encode this so that it can be passed as a query parameter to the API.

# Example call to Gate
curl localhost:8084/applications/$APPLICATION/executions/search?triggerTypes=$TRIGGER_TYPE&trigger=$TRIGGER
```

This call will return a list of pipeline executions triggered by a trigger with the given information, sorted by trigger time in reverse order so that newer executions are first in the list.

##  Query your webhook-triggered pipeline

Triggering a pipeline via a webhook returns a unique ID that can later be used to search for all pipelines executed by this trigger. The response body will contain an `eventId` field with a unique value.

```json
{
  "eventId": "c581dc8c-af6d-4ef0-8d84-27a64764b2f3"
}
```

To query for pipeline executions triggered by a specific webhook call, you can structure your API call with the following information:

```bash
APPLICATION=<application-name>  # This will narrow down results to only contain pipeline executions within a given application. You may supply '*' here to search across all applications.
TRIGGER_TYPE=webhook  # This will narrow down results to only contain pipelines executions triggered by a webhook call
EVENT_ID=c581dc8c-af6d-4ef0-8d84-27a64764b2f3  # eventId value returned by webhook call

# Example call to Gate
curl localhost:8084/applications/$APPLICATION/executions/search?triggerTypes=$TRIGGER_TYPE&eventId=$EVENT_ID
```

This call will return a list of pipeline executions triggered by a trigger with the given information, sorted by trigger time in reverse order so that newer executions are first in the list.
