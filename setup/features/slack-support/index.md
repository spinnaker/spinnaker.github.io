---
layout: single
title:  "Enable Slack Support Channels"
sidebar:
  nav: setup
---

Users can [create an application](/guides/user/applications/create/) and configure the application with relevant data. Spinnaker refers to this data as *application attributes*. Including a Slack Support Channel for an application is a configurable application attribute. This feature communicates with Slack's [conversations API](https://api.slack.com/docs/conversations-api) to expose a list of available Slack channels in your workspace. The Slack support channel feature is supported by all providers.

# Configuration

## Gate
An API token associated with your Slack workspace is needed for gate to receive a list of channels from Slack's API. Please refer to the [Slack documentation](https://slack.com/help/articles/215770388-Create-and-regenerate-API-tokens) if you need to create a Slack token. Add this token in the config for gate's **encrypted** secrets.

```yml
slack:
  token: YOUR_TOKEN_HERE
```
The base url for the Slack API is also needed in `gate.yml`. This does not need to be encrypted.  

```yml
slack:
  baseUrl: https://slack.com/api
```

## Deck
The UI components in deck are protected with a feature flag in the application settings, `settings.netflix.ts`. To activate this feature you need to enable this flag to `true`.

```js
feature: {
  slack: true,
  ...otherFeatures
}
```

If your workspace's base url is anything other than https://slack.com, then you need to configure this as well. This base url is used to construct the link for accessing a Slack support channel.

```js
  slack: {
    baseUrl: 'https://my-cool-workspace.slack.com',
  }
```



