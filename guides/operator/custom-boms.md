---
layout: single
title:  "Deploy Custom Spinnaker Builds"
sidebar:
  nav: guides
---

## The Bill of Materials (BOM)

Spinnaker is composed of many microservices, each of which has their own
version. When Spinnaker is built, the microservices are tested together to
ensure that they interoperate correctly, and then their versions are recorded
in a [BOM](/reference/halyard/#bill-of-materials). The BOM also includes
information on what commits for each service were built, what repositories they
can be downloaded from, and where additional configuration lives. All together,
a BOM describes a specific release of Spinnaker.

A BOM has the following structure:

```yaml
version:                  # the version this corresponds to
timestamp:                # when this version was assembled
services:
  ${SUBCOMPONENT}:        # for each subcomponent
    version:              # the subcomponent version
    commit:               # the commit the version corresponds to
    artifactSources:      # (optional) overrides for where the artifacts are stored
      debianRepository:   # (optional) debian repository storing the built deb
      dockerRegistry:     # (optional) docker registry storing the build image
      gitPrefix:          # (optional) git repository this is stored in
dependencies:
  ${DEPENDENCY}:          # for each required 3rd party service
    version:              # dependency version
artifactSources:
  debianRepository:       # debian repository storing all built debs
  dockerRegistry:         # docker registry storing all built images
  gitPrefix:              # git org all repos are in
```

For example, here is the BOM for Spinnaker 1.10.1:

> You can capture this yourself by running `hal version bom 1.10.1 -q -o yaml`

```yaml
version: 1.10.1
timestamp: '2018-10-24 15:31:30'
services:
  echo:
    version: 2.1.0-20181003100130
    commit: d20259cd47acd432670dcbddd8191eabbdbf7a4e
  clouddriver:
    version: 4.0.1-20181024113115
    commit: ad521d622193bd36b90f7c8b3fb453044222cd72
  deck:
    version: 2.5.1-20181018042808
    commit: 9a096f216be8bf36da14f2f5faa15e94e0a407c5
  fiat:
    version: 1.1.0-20181012042808
    commit: b1fd0b386534dd170f61c845ee8cda9a5865de82
  front50:
    version: 0.13.0-20181005212906
    commit: 62da4dc86c663230d897dc8da5ffbbb2c7793bbe
  gate:
    version: 1.2.0-20181016042808
    commit: 0b204b7b4e36819b2f469dd3850dc89b45a50bf8
  igor:
    version: 0.13.0-20181003100130
    commit: a4fd89756144d4b0722dc43ee679b9ae51a75171
  kayenta:
    version: 0.4.0-20180928152808
    commit: 788433f454505e7848d185868ed78d73ac0ef4cd
  orca:
    version: 1.1.0-20181003100130
    commit: bde9d946c68b8305e7ecd48c045a52eaa9b63cbc
  rosco:
    version: 0.8.0-20181003100130
    commit: 2f1a4f856b04971fe0fa04c7d402ee8f03827f61
  defaultArtifact: {}
  monitoring-third-party:
    version: 0.9.0-20180913172809
    commit: 1559f0a03c2c1d88bf07a164e1c9c21a7c5e6af4
  monitoring-daemon:
    version: 0.9.0-20180913172809
    commit: 1559f0a03c2c1d88bf07a164e1c9c21a7c5e6af4
dependencies:
  redis:
    version: 2:2.8.4-2
  consul:
    version: 0.7.5
  vault:
    version: 0.7.0
artifactSources:
  debianRepository: https://dl.bintray.com/spinnaker-releases/debians
  dockerRegistry: gcr.io/spinnaker-marketplace
  gitPrefix: https://github.com/spinnaker
```

Along with a service's version, we record canonical configuration for each
service at each release. This allows us to ensure that changes in the required
configuration of a service are captured with a release, and don't require user
intervention when installing Spinnaker with Halyard (or any other tooling that
takes advantage of this configuration). This canonical configuration is
captured from each service's `./halconfig` directory in each repository during
a build. [Here are Clouddriver's latest default configuration files, as an
example](https://github.com/spinnaker/clouddriver/tree/master/halconfig).

BOMs can be stored in a number of places, but regardless of the location or
storage solution, the required configuration files all share the same
directory/naming conventions relative to a `${CONFIG_INPUT_ROOT}`.

The conventions are as follows:

```
${CONFIG_INPUT_ROOT}/
├── bom/
│   └── ${VERSION}.yml            # for each top-level spinnaker version
└── ${SUBCOMPONENT}
    ├── ${DEFAULT_PROFILE}        # when a given version isn't found
    └── ${SUBCOMPONENT_VERSION}/  # for each subcomponent version
        └── ${PROFILE}            # for each profile at this version
```

Take for example the public `gs://halconfig` bucket, where all releases are
published, looks like (with a lot of omissions):

```
gs://halconfig/
├── bom/
│   ├── 1.10.1.yml
│   ├── 1.10.0.yml
│   ├── 1.9.5.yml
│   ├── 1.9.4.yml
│   ├── master-latest-unvalidated.yml
│   └── ...
├── clouddriver/
│   ├── clouddriver.yml
│   ├── 4.0.1-20181024113115/
│   │   ├── clouddriver.yml
│   │   ├── clouddriver-caching.yml
│   │   └── clouddriver-ro.yml
│   ├── 4.0.0-20181005152808/
│   │   ├── clouddriver.yml
│   │   ├── clouddriver-caching.yml
│   │   └── clouddriver-ro.yml
│   └── ...
├── deck/
│   ├── 2.5.1-20181018042808/
│   │   └── settings.js
│   ├── 2.5.1-20181018042808/
│   │   └── settings.js
│   └── ...
└── ...
```

### BOMS and Configuration in GCS

By default, all BOMs are stored in a publicly readable GCS bucket,
`gs://halconfig` that Halyard reads from when doing a deployment. This bucket
location can be changed by setting the `spinnaker.config.input.bucket` property
in `/opt/spinnaker/config/halyard-local.yml`. If you supply a private bucket,
Halyard will use your [application default
credentials](https://cloud.google.com/docs/authentication/production) to
authenticate.

Given any GCS bucket, `gs://${BUCKET}`, the `${CONFIG_INPUT_ROOT}` is
`gs://${BUCKET}`. 

As a result, a BOM at version `${VERSION}` can be found at
`gs://${BUCKET}/bom/${VERSION}.yml`, and a configuration file `${PROFILE}` for
subcomponent `${SUBCOMPONENT}` at version `${SUBCOMPONENT_VERSION}` can be
found at `gs://${BUCKET}/${SUBCOMPONENT}/${SUBCOMPONENT_VERSION}/${PROFILE}`.

If Halyard can't read from the GCS bucket, please see the [troubleshooting
instructions](https://www.spinnaker.io/setup/quickstart/faq/#halyard-times-out-during-a-config-change).

#### Disabling GCS reads

You can also completely disable reads from GCS by setting
`spinnaker.config.input.gcs.enabled: false` in
`/opt/spinnaker/config/halyard-local.yml`. Be sure to restart the Halyard
daemon for this configuration to take effect: `hal shutdown && hal`.

### BOMs and Configuration on your Filesystem

BOMs can also be read from your filesystem. To indicate to Halyard that you
want to read a local BOM, prefix the version you want to deploy (`${VERSION}`)
with `local:`, e.g.

```bash
hal config version edit --version local:${VERSION}
```

In this case, the `${CONFIG_INPUT_ROOT}` is `${HALCONFIG_DIR}/.boms`. As a
result, the BOM will be found under
`${HALCONFIG_DIR}/.boms/bom/${VERSION}.yml`.

> `${HALCONFIG_DIR}` is typically `~/.hal`

At this point, the configuration files for each service will by default be read
from GCS, unless you modify the BOM to indicate that they should be sourced
locally. This is done by prefixing the subcompent version with `local:` as well.
For example, in `~/.hal/.boms/bom/1.10.1.yml`:

```yaml
version: 1.10.1
timestamp: '2018-10-24 15:31:30'
services:
  echo:
    version: local:2.1.0-20181003100130               # 'local:' here
    commit: d20259cd47acd432670dcbddd8191eabbdbf7a4e
...
```

Indicates to Halyard to look in
`~/.hal/.boms/echo/2.1.0-20181003100130/echo.yml` for Echo's default
`echo.yml`, and then in `~/.hal/.boms/echo/echo.yml` as a backup.
