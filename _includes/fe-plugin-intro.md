Frontend plugins provide a way to change the behavior of Deck, Spinnaker's UI
service. You can add configuration and validation for new stages provided by
Orca plugins, override existing components with your own implementation, or add
new Kubernetes `kind` definitions for custom resources in your environment. Spinnaker loads plugins at runtime through Gate.

You can write plugins in any JavaScript-compatible language, but the development tooling is designed for JavaScript and TypeScript.

The following are examples of Deck features that you can override:

  - [ApplicationIcon], replace the icon used to represent applications in Deck.
  - [ServerGroupHeader], replace how pod status is reported in Deck.
  - [SpinnakerHeader], replace the top navigation header.

The following projects demonstrate adding new stages to Spinnaker:

  - [nomadPlugin], adding a Nomad provider to Spinnaker
  - [pf4jStagePlugin], adding a sample random wait stage to Spinnaker

[ApplicationIcon]: https://github.com/spinnaker/deck/blob/master/app/scripts/modules/core/src/application/ApplicationIcon.tsx
[SpinnakerHeader]: https://github.com/spinnaker/deck/blob/master/app/scripts/modules/core/src/header/SpinnakerHeader.tsx
[ServerGroupHeader]: https://github.com/spinnaker/deck/blob/master/app/scripts/modules/core/src/serverGroup/ServerGroupHeader.tsx
[nomadPlugin]: https://github.com/spinnaker-plugin-examples/nomadPlugin
[pf4jStagePlugin]: https://github.com/spinnaker-plugin-examples/pf4jStagePlugin
