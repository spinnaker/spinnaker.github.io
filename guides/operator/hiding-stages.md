---
layout: single
title:  "Hiding Stages"
sidebar:
  nav: guides
---

If you're using Spinnaker 1.20 or later, stages that are not provider-specific will be
available by default. To hide specific stages from end-users, set the
`hiddenStages` property in Deck's [custom profile](/reference/halyard/custom/#custom-profile-for-deck)
to a list of the keys of stages you wish to hide. For example, to hide the
Gremlin and Travis stages, include the following in `settings-local.js`:
                                             
```js
 window.spinnakerSettings.hiddenStages = ['gremlin', 'travis'];
```
