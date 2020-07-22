---
layout: single
title:  "Custom CAs for Webhooks"
sidebar:
  nav: guides
---

## Overview

[Webhook stages](/reference/pipeline/stages/#webhook) enable Spinnaker to make HTTP(S)
calls to external web services. If the configured webhook URL has the `https://`
scheme, Spinnaker will use TLS to communicate with the external server. Spinnaker
will attempt to validate the certificate presented by the server by building a chain
of trust back to a trusted certification authority (CA) and will refuse to connect
if the certificate cannot be validated.

By default Spinnaker uses the trust store provided by the JVM as its source of trusted
CAs. The default behavior is sufficient for webhooks to public-facing servers where
it is possible to build a chain of trust back to a root CA. Internal servers, however,
may have certificates issued by a company-specific CA that is not trusted by a root
CA. Webhooks to these servers over `https://` will fail using the default configuration.

In order to support this latter use case, Spinnaker allows users to supply additional
CAs to trust in addition to the default ones. These additional CAs will be used when
negotiating connections for outbound webhooks (including preconfigured webhooks) but
will not be used for any other connection initiated by Spinnaker. There is no
way to specify additional CAs on a per-webhook basis; the additional CAs will apply to
all webhooks.

## Create a trust store

Create a trust store in Java KeyStore (JKS) format via:
```bash
keytool -import -file <path-to-ca-certificate> -alias <name-of-first-ca> -keystore <name-for-keystore>.jks
```
where `<path-to-ca-certificate>` is the path to the certificate for the CA you'd like to trust in
PEM format, `<name-of-first-ca>` is an arbitrary alias for that CA, and `<name-for-keystore>` is
the name of a keystore that will be created.

You will be prompted to create a password for the new key store, which you'll need to supply to
Spinnaker in the next step.

After creating the key store with the above command, you can add additional CAs to the keystore
by running the same command but supplying a different CA certificate and alias. You'll be prompted
for the keystore password before the new CA can be added. As this trust store will augment the default
trust store, you don't need to add all of the root CAs to this custom trust store; only CAs that are
not in the default trust store need to be added.

## Configure Spinnaker to use the trust store

```bash
hal config webhook trust edit --trustStore <path-to-trust-store> --trustStorePassword
hal config webhook trust enable
```
The first command will prompt for the trust store password on standard input.

Alternately, if not using Halyard, the following can be added to `orca-local.yml`:
```yaml
webhook:
  trust:
    enabled: true
    trustStore: <path to trust store in jks format>
    trustStorePassword: <password for trustStore>
```
