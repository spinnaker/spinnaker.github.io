---
layout: single
title:  "Secrets"
sidebar:
  nav: reference
---

{% include toc %}

Managing Spinnaker secrets separately from its configuration is a necessary step to enabling Spinnaker through an SCM like git. Spinnaker supports end-to-end secrets management, starting in version 1.14. Simply replace secrets in the Halconfig and service profiles with the syntax described here and Spinnaker will decrypt them as needed. 


### Secret Format
When referencing secrets in configs, we use the following general format:

```
encrypted:<secret engine>!<key1>:<value1>!<key2>:<value2>!...
```
The key-value parameters making up the string vary with each secret engine. Refer to the specific documentation for each engine for more information.

### In Halyard
Halyard knows how to decrypt the secrets we provide and will do so when the secret is needed, such as for validation and deployment. If the service we're deploying is able to decrypt secrets, Halyard will keep the secret in encrypted form when printing the service profiles. However if running an older version of a service, it will decrypt the configuration before sending it. 

For instance, if we replace the GitHub token in our hal config with an encrypted syntax:
```yaml
...
  github:
    enabled: true
    accounts:
    - name: github
      token: encrypted:<secret engine>!<key1>:<value1>!<key2>:<value2>!...
...
```

We'd find it still encrypted in `profiles/clouddriver.yml`:
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

### Non Halyard Configuration
We can also provide the same syntax in `*-local.yml` profile files or directly to Spinnaker services, since the services can also decrypt secrets.

### Supported Secret Engines
The secrets framework is extensible and support for new engines can easily be added. Currently the following are supported:

* [S3](/reference/halyard/secrets/s3-secrets/)

