---
layout: single
title:  "Secrets"
sidebar:
  nav: reference
---

{% include toc %}

Storing Spinnaker configs in a git repository is a great solution for maintaining versions of your configurations, but storing secrets in plain text is a bad security practice. As of version 1.14, Spinnaker supports separating your secrets from your configs through end-to-end secrets management. Simply replace secrets in the Halconfig and service profiles with the syntax described here, and Spinnaker will decrypt them as needed. 


## Secret Format
To reference secrets in configs, use the following general format:

```
encrypted:<secret engine>!<key1>:<value1>!<key2>:<value2>!...
```
The key-value parameters making up the string vary with each secret engine. Refer to the specific documentation for each engine for more information.

## In Halyard
Halyard decrypts your secrets as needed, for example for validation and deployment. If the service you're deploying can decrypt secrets, Halyard keeps the secret in encrypted form when printing the service profiles. However if you're running an older version of a service, it decrypts the configuration before sending it. 

For instance, if you replace the GitHub token in your hal config with an encrypted syntax:
```yaml
...
  github:
    enabled: true
    accounts:
    - name: github
      token: encrypted:<secret engine>!<key1>:<value1>!<key2>:<value2>!...
...
```

You'd find it still encrypted in `profiles/clouddriver.yml`:
```yaml
...
  github:
    enabled: true
    accounts:
    - name: github
      token: encrypted:<secret engine>!<key1>:<value1>!<key2>:<value2>!...
...
```

And for an older release of Clouddriver that does not support decryption, the secret will be in plain text:
```yaml
...
  github:
    enabled: true
    accounts:
    - name: github
      token: <TOKEN>
...
```
Note: Using the encrypted syntax in a `hal` command will not work, so you'll need to edit the hal config directly.

## Non-Halyard Configuration
You can also provide the same syntax in `*-local.yml` profile files or directly to Spinnaker services, since the services can also decrypt secrets.

## Supported Secret Engines
The secrets framework is extensible and support for new engines can easily be added. Currently the following is supported:

* [S3](/reference/halyard/secrets/s3-secrets/)

