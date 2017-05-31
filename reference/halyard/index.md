---
layout: single
title:  "Halyard"
sidebar:
  nav: reference
---

{% include toc %}

This is the reference documentation for Halyard, and will go into more detail
than is needed to deploy most Spinnaker environemnts. If you're a new user
looking for instructions for how to use Halyard to deploy Spinnaker, checkout
the [setup instructions](/setup/install/) first.

## Terminology

### Halconfig

The Halconfig is the source of all configuration for your Deployment of
Spinnaker. It typically lives in `~/.hal/config`, but its directory can be
changed with the `halyard.halconfig.directory` Spring config property.

### Deployments

A Deployment within Halyard is a single, deployed/installed & configured
Spinnaker. Each deployment has its own set of configuration and running
services, and is logically separated from any other Deployment of Spinnaker
that Halyard is managing. The deployments are referenced by name, and the
default name for your first Deployment is `"default"`.

The intended use-case for Deployments is managing multiple, isolated Spinnakers
that need to be kept separate for one reason or another (compliance, network
configuration, etc...).

You can switch to/create a new deployment named `$DEPLOYMENT` by running the
following command.

```bash
hal config --set-current-deployment $DEPLOYMENT
```

### Artifacts

Artifacts are unconfigured, versioned, prebuilt deployables consumed by
Halyard. 

For example, the Clouddriver Docker container
`gcr.io/spinnaker-marketplace/clouddriver:0.2.0-348` is an Artifact, or the
Debian Echo package `spinnaker-releases/debians/spinnaker-echo=0.2.0-214` is
another Artifact.

### Profiles

Profiles are configuration files applied to Artifacts to make them run in some
desired fashion. 

For example, `clouddriver-bootstrap.yml` and `clouddriver.yml` are both
profiles that are consumed by the Clouddriver Artifact above.

During the deployment process Halyard will stage all generated profiles in
`~/.hal-staging/` (configurable via `spinnaker.config.staging.directory`)
before either uploading them to your deployment environment's secret store, or
copying them to the necessary local directories. 

A Profile's name is derived from its path relative to `~/.hal-staging/`. For
example, the Profile found under `~/.hal-staging/clouddriver.yml` has name
`clouddriver.yml`, and the Profile found under
`~/.hal-staging/registry/echo.yml` has name `registry/echo.yml`.

### Services

Services are the combination of an Artifact, with a set of Profiles
that apply to that Artifact. For example, the Artifact

- `gcr.io/spinnaker-marketplace/clouddriver:0.2.0-348` 

combined with the Profiles

- `clouddriver.yml`
- `clouddriver-bootstrap.yml`

constructs the `spin-clouddriver-bootstrap` service.

The associations between Profiles and Services is recorded in 
`~/.hal/$DEPLOYMENT/history/service-profiles.yml`.

### Service Settings

Service Settings are runtime properties of Services, such as which address they
bind to, or what port they should listen on. Service Settings are ultimately
baked into Profiles, but are kept separate since they need to be collectively
distributed to each Service, since they describe how each Service discovers the
others. 

You can see what global Service Settings Halyard has generated for your current 
Deployment of Spinnaker by reading
`~/.hal/$DEPLOYMENT/history/service-settings.yml`.

### Bill of Materials

Since Spinnaker is composed of several microservices, we need some way to
express which versions of each service have been validated together, and
provide that set of service versions a top-level version that can be referenced
by users installing/deploying Spinnaker. This set of versions is referred to as
the __Bill of Materials__ (BOM). Below is an example BOM:

```yaml
dependencies:
  consul:
    version: 0.7.5
  redis:
    version: 2:2.8.4-2
  vault:
    version: 0.7.0
services:
  clouddriver:
    version: 0.4.0-393
  deck:
    version: 1.2.0-393
  echo:
    version: 0.2.1-393
  fiat:
    version: 0.2.0-393
  front50:
    version: 0.3.1-393
  gate:
    version: 0.4.0-393
  igor:
    version: 0.3.0-393
  monitoring-daemon:
    version: 0.1.0-393
  monitoring-third-party:
    version: 0.1.0-393
  orca:
    version: 0.4.0-393
  rosco:
    version: 0.3.0-393
  spinnaker:
    version: 0.4.0-393
timestamp: '2017-05-26 11:30:46'
version: master-2017-05-26-393
```

If you're curious how to deploy Spinnaker yourself using a validated BOM, read
more in the [deployments](/reference/halyard/#deployments) section.
