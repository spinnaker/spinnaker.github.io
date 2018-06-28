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

### On Linux

```bash
curl -LO https://storage.googleapis.com/spinnaker-artifacts/spin/$(curl -s https://storage.googleapis.com/spinnaker-artifacts/spin/latest)/linux/amd64/spin

chmod +x spin

sudo mv spin /usr/local/bin/spin
```

### On MacOS

```bash
curl -LO https://storage.googleapis.com/spinnaker-artifacts/spin/$(curl -s https://storage.googleapis.com/spinnaker-artifacts/spin/latest)/darwin/amd64/spin

chmod +x spin

sudo mv spin /usr/local/bin/spin
```

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

`spin` can be configured with OAuth2.0 to authenticate calls against Spinnaker. The configuration
block looks like this:

```yaml
auth:
  enabled: true
  oauth2:
    authUrl: # OAuth2 provider auth url
    tokenUrl: # OAuth2 provider token url
    clientId: # OAuth2 client id
    clientSecret: # OAuth2 client secret
    scopes: # Scopes requested for the token
    - scope1
    - scope2
```

See https://www.spinnaker.io/setup/security/authentication/oauth/providers/ 
to see examples for acquiring a clientId/clientSecret from your provider.

Unlike X.509, OAuth2 needs to be initialized once to authenticate with the provider before
it can be used for automation. To authenticate, configure OAuth2 as shown above and execute
any `spin` command. You will be prompted to authenticate with your OAuth2 provider
and paste an access code. `spin` then exchanges the code for an OAuth2 access/refresh token pair,
which it caches in your `~/.spin/config` file for future use. All subsequent `spin` calls will
use the cached OAuth2 token for authentication with no user input required. If an OAuth2
access token expires, `spin` will use the refresh token to renew the access token expiry.
