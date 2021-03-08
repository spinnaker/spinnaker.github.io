Frontend plugins provide a way to change the behavior of Deck, Spinnaker's UI
service. You can add configuration and validation for new stages provided by
Orca plugins, override existing components with your own implementation, or add
new Kubernetes Kind definitions for custom resources in your environment.

Plugins are written in any JavaScript compatible language (TypeScript included),
and are loaded at runtime through Gate. Note, however, that the tooling is
very JavaScript and TypeScript centric.

The following are examples of extension points that can be overriden:

  - [ApplicationIcon], replacing the icon used to represent applications in Deck
  - [ServerGroupHeader], replacing how pod status is reported in Deck
  - [SpinnakerHeader], allowing you to override replace the top navigation header

[ApplicationIcon]: https://github.com/spinnaker/deck/blob/master/app/scripts/modules/core/src/application/ApplicationIcon.tsx
[SpinnakerHeader]: https://github.com/spinnaker/deck/blob/master/app/scripts/modules/core/src/header/SpinnakerHeader.tsx
[ServerGroupHeader]: https://github.com/spinnaker/deck/blob/master/app/scripts/modules/core/src/serverGroup/ServerGroupHeader.tsx
