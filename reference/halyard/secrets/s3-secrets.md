---
layout: single
title:  "Secrets in S3"
sidebar:
  nav: reference
---

{% include toc %}


This document describes how to set up Spinnaker secrets in an encrypted S3 bucket. This example uses a bucket (`mybucket`) in the `us-west-2` region to store GitHub credentials and a kubeconfig file. You reference the bucket by its URL `mybucket.us-west-2.amazonaws.com`.


## Authorization
Since you're storing sensitive information, you protect the bucket by restricting access and [enabling encryption](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/default-bucket-encryption.html).

Remember to run Halyard's daemon and Spinnaker services with IAM roles that allow them to read that content.


## Storing secrets

### Storing credentials
Store your GitHub credentials in `mybucket/spinnaker-secrets.yml`:

```yaml
github:
  password: <PASSWORD>
  token: <TOKEN>
```

Note: You could choose to store the password under different keys than `github.password` and `github.token`. You'd just need to change how to reference the secret further down.

### Storing sensitive files
Some Spinnaker configuration uses information stored as files. For example, upload the `kubeconfig` file of your Kubernetes account directly to `mybucket/mykubeconfig`:

```
aws s3 cp /path/to/mykubeconfig s3://mybucket/mykubeconfig
```


## Referencing secrets
Now that secrets are safely stored in the bucket, you reference them from your config files using the following format. The S3 specific parameters (`r:<region>`, `b:<bucket>`, `k:<optional yaml key>`) can be in any order:
To reference secret literal values:

```
encrypted:s3!r:<region>!b:<bucket>!f:<path to file>!k:<optional yaml key>
```

To reference secret files:

```
encryptedFile:s3!b:<bucket>!f:<path to file>
```

The `k:<key>` parameter is only necessary when storing secret values in a yaml file, like in our example. To reference `github.password` from the file above, use:
```
encrypted:s3!b:mybucket!f:spinnaker-secrets.yml!r:us-west-2!k:github.password
```

But to reference your kubeconfig file, you can leave off the `k` parameter and use `encryptedFile` prefix:
```
encryptedFile:s3!r:us-west-2!b:mybucket!f:mykubeconfig
```
