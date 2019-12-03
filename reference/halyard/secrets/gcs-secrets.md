---
layout: single
title:  "Secrets in GCS"
sidebar:
  nav: reference
---

{% include toc %}


This document describes how to set up Spinnaker secrets in a GCS bucket. This example uses a bucket (`mybucket`) to store GitHub credentials and a kubeconfig file.


## Authorization
Since you're storing sensitive information you protect the bucket by restricting access to it. Encryption at rest is [already provided](https://cloud.google.com/storage/docs/encryption/default-keys) automatically without additional setup.

Remember to run Halyard's daemon and Spinnaker services with a service account that allows them to read that content.


## Storing secrets

### Storing credentials
Store your GitHub credentials in `mybucket/spinnaker-secrets.yml`:

```yaml
github:
  password: <PASSWORD>
  token: <TOKEN>
```

Note: You could choose to store the password under different keys than `github.password` and `github.token`. You'd just need to [change how to reference the secret](#referencing-secrets).

### Storing sensitive files
Some Spinnaker configuration uses information stored as files. For example, upload the `kubeconfig` file of your Kubernetes account directly to `mybucket/mykubeconfig`:

```
gsutil cp /path/to/mykubeconfig gs://mybucket/mykubeconfig
```


## Referencing secrets
Now that secrets are safely stored in the bucket, you reference them from your config files using the following format. The GCS specific parameters (`b:<bucket>`, `f:<path to file>`, etc) can be in any order:

```
encrypted:gcs!b:<bucket>!f:<path to file>!k:<optional yaml key>
```

The `k:<key>` parameter is only necessary when storing secret values in a yaml file, like in our example. To reference `github.password` from the file above, use:
```
encrypted:gcs!b:mybucket!f:spinnaker-secrets.yml!k:github.password
```

But to reference your kubeconfig file, you can leave off the `k` parameter:
```
encrypted:gcs!b:mybucket!f:mykubeconfig
```
