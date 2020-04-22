---
Layout: single
title:  "Alibaba Cloud Container Service For Kubernetes (ACK) Setup"
sidebar:
  nav: setup
---

{% include toc %}

This page describes how to set up a Kubernetes cluster on
[ACK](https://www.alibabacloud.com/product/kubernetes) to be used with Spinnaker's
Kubernetes provider.

# Create a cluster

You can create a Kubernetes cluster on ACK using [console](https://cs.console.aliyun.com) 
as shown in the [official documentation](https://www.alibabacloud.com/help/doc-detail/86488.htm). 
You can also use [Alibaba Cloud CLI](https://github.com/aliyun/aliyun-cli) or 
[Terraform ](https://www.terraform.io/docs/providers/alicloud/r/cs_kubernetes.html) tools to automate provisioning your clusters.

# Download kubectl configuration file on hal node

Run the following command on the `hal` node:

```bash
mkdir $HOME/.kube
scp root@$MASTER:/etc/kubernetes/kube.conf $HOME/.kube/config
```

# Next Steps

[Follow the setup instructions for adding a Kubernetes account in
Spinnaker](/setup/install/providers/kubernetes-v2/#adding-an-account).
