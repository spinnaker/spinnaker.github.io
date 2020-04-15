---
layout: single
title:  "Set up a K8s v2 provider for Amazon EKS"
sidebar:
  nav: setup
---

{% include toc %}

> Before you proceed further with this setup, we strongly recommend that you familiarize yourself with [Amazon EKS concepts](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html).
Also, please visit the [AWS global infrastructure region table](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/) for the most up-to-date information on Amazon EKS regional availability.

These instructions assume that you have AWS CLI [installed](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) and [configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) on an Ubuntu machine running on AWS EC2.

## Installing Spinnaker on EKS

### 1. Install and configure Kubectl

Install `kubectl `and `aws-iam-authenticator `on an Ubuntu machine:

```
`curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH 
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

aws-iam-authenticator help`
```

The script verifies that `aws-iam-authenticator` is working by displaying the help contents of `aws-iam-authenticator`.

### 2. Install awscli

```
sudo apt install python-pip awscli

aws --version
```

### 3. Install eksctl

```
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin
```

### 4. Install Halyard

```
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh

sudo useradd halyard

sudo bash InstallHalyard.sh

sudo update-halyard

hal -v
```

### 5. Create the Spinnaker Amazon EKS cluster

```
eksctl create cluster --name=eks-spinnaker --nodes=2 --region=us-west-2 --write-kubeconfig=false
```

## Install and configure Spinnaker

This section will walk you through the process of installing and configuring Spinnaker for use with Amazon EKS. 

### 1. Retrieve Amazon EKS cluster kubectl contexts

```
aws eks update-kubeconfig --name eks-spinnaker --region us-west-2 --alias eks-spinnaker
```

### 2. Check halyard version

```
hal -v
```

### 3. Add and configure Kubernetes accounts

Set the Kubernetes provider as enabled:

```
hal config provider kubernetes enable

kubectl config use-context eks-spinnaker
```

A context element in a kubeconfig file is used to group access parameters under a convenient name. Each context has three parameters: cluster, namespace, and user. By default, the kubectl command line tool uses parameters from the current context to communicate with the cluster.

```
CONTEXT=$(kubectl config current-context)
```

We will create a service account for the Amazon EKS cluster. See the [Kubernetes documentation for more details on service accounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/).

```
kubectl apply --context $CONTEXT -f https://spinnaker.io/downloads/kubernetes/service-account.yml
```

Extract the secret token of the `spinnaker-service-account`:

```
TOKEN=$(kubectl get secret --context $CONTEXT \
   $(kubectl get serviceaccount spinnaker-service-account \
       --context $CONTEXT \
       -n spinnaker \
       -o jsonpath='{.secrets[0].name}') \
   -n spinnaker \
   -o jsonpath='{.data.token}' | base64 --decode)
```

Set the user entry in `kubeconfig:`

```
kubectl config set-credentials ${CONTEXT}-token-user --token $TOKEN

kubectl config set-context $CONTEXT --user ${CONTEXT}-token-user
```

Add `eks-spinnaker` cluster as a Kubernetes provider.

```
hal config provider kubernetes account add eks-spinnaker --provider-version v2 --context $CONTEXT
```

### 4. Enable artifact support

```
hal config features edit --artifacts true
```

### 5. Configure Spinnaker to install in Kubernetes

For our environment we will use a distributed Spinnaker installation onto the Kubernetes cluster. This installation model has Halyard deploy each of the Spinnaker microservices separately. A distributed installation helps to limit update-related downtime.

```
hal config deploy edit --type distributed --account-name eks-spinnaker
```

### 6. Configure Spinnaker to use AWS S3

You will need your AWS account access key and secret access key.

```
export`` YOUR_ACCESS_KEY_ID``=<``access``-``key``>`

`hal config storage s3 edit ``--``access``-``key``-``id $YOUR_ACCESS_KEY_ID \`
` ``--``secret``-``access``-``key ``--``region us``-``west``-``2
```

Enter your AWS account secret access key at the prompt.

```
hal config storage edit --type s3
```

### 7. Choose the Spinnaker version

To identify the latest version of Spinnaker to install, run the following to get a list of available versions:

```
hal version list
```

At the time of writing, 1.19.2 is the latest Spinnaker version:

```
export VERSION=1.19.2

hal config version edit --version $VERSION
```

Now we are finally ready to install Spinnaker on the eks-spinnaker Amazon EKS cluster.

```
hal deploy apply
```

### 8. Verify the Spinnaker installation

```
kubectl -n spinnaker get svc
```

### 9. Expose Spinnaker using Elastic Loadbalancer

Expose the Spinnaker API (Gate) and the Spinnaker UI (Deck) via Load Balancers by running the following commands to create the `spin-gate-public` and `spin-deck-public services`:

```
export NAMESPACE=spinnaker

kubectl -n ${NAMESPACE} expose service spin-gate --type LoadBalancer \
  --port 80 --target-port 8084 --name spin-gate-public 

kubectl -n ${NAMESPACE} expose service spin-deck --type LoadBalancer \
  --port 80 --target-port 9000 --name spin-deck-public  
  
export API_URL=$(kubectl -n $NAMESPACE get svc spin-gate-public \
 -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
 
export UI_URL=$(kubectl -n $NAMESPACE get svc spin-deck-public \
 -o jsonpath='{.status.loadBalancer.ingress[0].hostname}') 

hal config security api edit --override-base-url http://${API_URL} 

hal config security ui edit --override-base-url http://${UI_URL}

hal deploy apply
```

It can take several moments for Spinnaker to restart and you can verify that your PODs have restarted.

```
kubectl -n spinnaker get pods
```

### 10. Re-verify the Spinnaker installation

```
kubectl -n spinnaker get svc
```

### 11. Log in to Spinnaker console

Get the URL to the UI and login via a Web browser.

```
kubectl -n $NAMESPACE get svc spin-deck-public -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```



