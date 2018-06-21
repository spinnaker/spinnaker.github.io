---
layout: single
title:  "Install and Configure Spin CLI"
sidebar:
  nav: guides
---

{% include toc %}

## Install `spin`

One way to manage applications and pipelines as code is through [spin](http://github.com/spinnaker/spin).

To acquire `spin`, do the following:

```bash
# See the versions released at https://github.com/spinnaker/spin/releases.
export VERSION=<desired spin version tag> # Select a tag from the released version, e.g. v0.1.0
curl -L https://github.com/spinnaker/spin/releases/download/$VERSION/spin -o spin
chmod +x ./spin
./spin --help
```

**Note**: The alpha `spin` binaries are only available for Linux platforms only at this point.
We'll compile binaries for other platforms likely in Spinnaker 1.9.x.

## Configure `spin`

`spin` reads its configuration from `~/.spin/config`. Currently, all configuration is for authentication mechanisms only.

### X.509

`spin` can be configured with X.509 to authenticate calls against Spinnaker. The configuration
block looks like this:

```yaml
auth:
  enabled: true
  x509:
    certPath: <cert file path>
    keyPath: <key file path>
```

or

```yaml
auth:
  enabled: true
  x509:
    # Pipes for multi-line strings in yaml.
    # Cert and key contents are 64 encoded pem values.
    cert: |
    <cert>
    key: |
    <key>
```

Follow the [ssl](https://www.spinnaker.io/setup/security/authentication/ssl/) and [x509](https://www.spinnaker.io/setup/security/authentication/x509/)
guides to generate the X.509 certificate and key files. Refer to [the example config](https://github.com/spinnaker/spin/blob/master/config/example.yaml)
and the [README](https://github.com/spinnaker/spin/blob/master/README.md) for more information about X.509 in `spin`.


### OAuth2

Coming soon in Spinnaker 1.9.x.
