---
layout: single
title:  "Secrets in S3"
sidebar:
  nav: reference
---

{% include toc %}


This document describes how to set up Spinnaker secrets in an encrypted S3 bucket. In this example, we'll be using a `mybucket` bucket in the `us-west-2` region to store GitHub credentials and a kubeconfig file. We'll be referencing the bucket by its URL `mybucket.us-west-2.amazonaws.com`.


## Authorization
Since we're storing sensitive information, we'll protect the bucket by restricting access and [enabling encryption](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/default-bucket-encryption.html).

The important thing to remember is to run Halyard's daemon and Spinnaker services with IAM roles that allow them to read that content.


## Storing secrets
### Storing credentials
Let's store our GitHub credentials in `mybucket/spinnaker-secrets.yml`:

```yaml
github:
  password: <PASSWORD>
  token: <TOKEN>
```

Note: We could have chosen to store the password under different keys than `github.password` and `github.token`. We'd just need to change how to reference the secret further down.

### Storing sensitive files
Some of Spinnaker configuration also uses information stored as files. Let's upload the `kubeconfig` file of our Kubernetes account directly to `mybucket/mykubeconfig`.


## Referencing secrets
Now that secrets are safely stored in our bucket, we'll reference them from our config files with the following format. The S3 specific parameters (`r:<region>`, `b:<bucket>`, etc) can be in any order:

```
encrypted:s3!r:<region>!b:<bucket>!f:<path to file>!k:<optional key>
```

For example, to reference `github.password` from the file above, we'll use:
```
encrypted:s3!b:mybucket!f:spinnaker-secrets.yml!r:us-west-2!k:github.password
```

And to reference our kubeconfig file:
```
encrypted:s3!r:us-west-2!b:mybucket!f:mykubeconfig
```
