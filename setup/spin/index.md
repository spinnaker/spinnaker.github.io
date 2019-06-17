---
layout: single
title:  "Install and Configure Spin CLI"
sidebar:
  nav: setup
redirect_from: /guides/spin/cli/
---

{% include toc %}

For more information, see the [spin CLI Guide](/guides/spin/)

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

### On Windows

```powershell
New-Item -ItemType Directory $env:LOCALAPPDATA\spin -ErrorAction SilentlyContinue

Invoke-WebRequest -OutFile $env:LOCALAPPDATA\spin\spin.exe -UseBasicParsing "https://storage.googleapis.com/spinnaker-artifacts/spin/$([System.Text.Encoding]::ASCII.GetString((Invoke-WebRequest https://storage.googleapis.com/spinnaker-artifacts/spin/latest).Content))/windows/amd64/spin.exe"

Unblock-File $env:LOCALAPPDATA\spin\spin.exe

$path = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User) -split ";"
if ($path -inotcontains "$env:LOCALAPPDATA\spin") {
  $path += "$env:LOCALAPPDATA\spin"
  [Environment]::SetEnvironmentVariable("PATH", $path -join ";", [EnvironmentVariableTarget]::User)

  $env:PATH = (([Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine) -split ";") + $path) -join ";"
}
```

## Configure `spin`

`spin` reads its configuration from `~/.spin/config`. 

This configuration file doesn't exist yet, after you install `spin`. You need to create it.

1. Create the directory:
```bash
mkdir ~/.spin/
```

1. In that directory, create the `config` file. 

   Use [example.yaml](https://github.com/spinnaker/spin/blob/master/config/example.yaml) to populate it.

Currently, all configuration is for authentication mechanisms only.

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

#### Client ID and Client Secret

`spin` can be configured with an OAuth2 client ID and secret to authenticate calls against Spinnaker. The configuration
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

Read [the OAuth setup instructions](https://www.spinnaker.io/setup/security/authentication/oauth/providers/)
to see examples for acquiring a clientId/clientSecret from your provider.

This OAuth2 configuration method needs to be initialized once to authenticate with the provider before
it can be used for automation. To authenticate, configure OAuth2 as shown above and execute
any `spin` command. You will be prompted to authenticate with your OAuth2 provider
and paste an access code. This process involves configuring the `callback url` to be http://localhost:8085 in order to view and retrieve the access code to be provided to the prompt. `spin` then exchanges the code for an OAuth2 access/refresh token pair,
which it caches in your `~/.spin/config` file for future use. All subsequent `spin` calls will
use the cached OAuth2 token for authentication with no user input required. If an OAuth2
access token expires, `spin` will use the refresh token to renew the access token expiry.

#### Access and Refresh Token

`spin` can also be configured with an OAuth2 access token and refresh token in lieu of configuring
an OAuth2 client ID and secret. The `spin` configuration looks like this:

```yaml
auth:
  enabled: true
  oauth2:
    authUrl: # OAuth2 provider auth url
    tokenUrl: # OAuth2 provider token url
    # no clientId or clientSecret
    scopes: # Scopes requested for the token
    - scope1
    - scope2
    cachedToken:
      accesstoken: ${ACCESS_TOKEN} # Note the key capitalization
      refreshtoken: ${REFRESH_TOKEN} # Note the key capitalization
```

This method is OAuth2-provider specific since the workflow to acquire
a token is different for each provider. To do so using Google OAuth2 and `gcloud`:

  1. Authenticate with Google via `gcloud auth login`.

  2. Use the following commands to acquire the tokens:

    ```
    ACCESS_TOKEN=$(gcloud auth print-access-token)
    REFRESH_TOKEN=$(gcloud auth print-refresh-token)
    ```

### Basic

`spin` can be configured with basic authentication credentials to authenticate calls against Spinnaker. The configuration
block looks like this:

```yaml
auth:
  enabled: true
  basic:
    username: < username >
    password: < password >
```

## Global Flags

`spin` has a few helpful global flags:

```
Global Options:

        --gate-endpoint               Gate (API server) endpoint.
        --no-color                    Removes color from CLI output.
        --insecure=false              Ignore certificate errors during connection to endpoints.
        --quiet=false                 Squelch non-essential output.
        --output <output format>      Formats CLI output.

```

### Output Formatting

The global `--output` flag allows users to manipulate `spin`'s output format.
By default, `spin` will print the command output in json. Users can also specify
a `jsonpath` in the output flag to extract nested data from the command output:

```bash
spin pipeline get --name pipelineName --application app --output jsonpath="{.stages}"

[
<stages>
]
```

`spin` leverages the `kubectl` `jsonpath` libraries to support this. Follow the [kubectl documentation](https://kubernetes.io/docs/reference/kubectl/jsonpath/)
for more information about the possible `jsonpath` arguments.
