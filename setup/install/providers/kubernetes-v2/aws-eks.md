---
layout: single
title:  "Set up the Kubernetes provider for Amazon EKS"
sidebar:
  nav: setup
redirect_from: 
  - /setup/install/providers/aws/aws-ec2/ 
---

{% include toc %}

> Before you proceed further with this setup, we strongly recommend that you familiarize yourself with [Amazon EKS concepts](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html).
Also, visit the [AWS global infrastructure region table](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/) for the most up-to-date information on Amazon EKS regional availability.

These instructions assume that you have AWS CLI [installed](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) and [configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) on an Ubuntu machine running on AWS EC2.

## Preparing to install Spinnaker on EKS

The following steps describes how to the tools you need to install and manage Spinnaker and EKS. 

### 1. Install and configure kubectl

Install `kubectl` to manage Kubernetes and `aws-iam-authenticator` to manage cluster authentication:

```
# Download and install kubectl
`curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# Verify the installation of kubectl
kubectl help

# Download and install aws-iam-authenticator
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH 
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

#Verify the installation of aws-iam-authenticator
aws-iam-authenticator help`
```

The commands return the help information for `kubectl` and `aws-iam-authenticator` respectively. If the help for either tool does not get returned, verify that you have installed the tool.

### 2. Install awscli

```
# Install the awscli
sudo apt install python-pip awscli

# Verify the installation
aws --version
```

The command returns the `awscli` version.

### 3. Install eksctl

Install `eksctl` to manage EKS clusters from the command line:

```
# Download and configure eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

# Verify the installation
eksctl help
```

The command returns the help for `eksctl`.

### 4. Install Halyard

Install Halyard, which is used to install and manage Spinnaker: 

```
# Download and configure Halyard
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh

sudo useradd halyard

sudo bash InstallHalyard.sh

sudo update-halyard

# Verify the installation
hal -v
```

The command returns the Halyard version.

### 5. Create the Amazon EKS cluster for Spinnaker 

```
eksctl create cluster --name=eks-spinnaker --nodes=2 --region=us-west-2 --write-kubeconfig=false
```

## Install and configure Spinnaker

This section walks you through the process of installing and configuring Spinnaker for use with Amazon EKS. 

### 1. Retrieve Amazon EKS cluster kubectl contexts

```
aws eks update-kubeconfig --name eks-spinnaker --region us-west-2 --alias eks-spinnaker
```

### 2. Check Halyard version

More recent versions of Spinnaker require a more recent version of Halyard. For example, Spinnaker 1.19.x requires Halyard 1.32.0 or later. 

Verify your Halyard version: 

```
hal -v
```

### 3. Add and configure Kubernetes accounts

Enable the Kubernetes provider for Spinnaker:

```
# Enable the Kubernetes provider
hal config provider kubernetes enable

# Set the current kubectl context to the cluster for Spinnaker
kubectl config use-context eks-spinnaker
```

A context element in a kubeconfig file is used to group access parameters under a convenient name. Each context has three parameters: cluster, namespace, and user. By default, `kubectl` uses parameters from the current context to communicate with the cluster.

```
# Assign the Kubernetes context to CONTEXT
CONTEXT=$(kubectl config current-context)
```

Next, create a service account for the Amazon EKS cluster:

```
kubectl apply --context $CONTEXT -f https://spinnaker.io/downloads/kubernetes/service-account.yml
```

See the [Kubernetes documentation for more details on service accounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/).

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

Set the user entry in `kubeconfig`:

```
kubectl config set-credentials ${CONTEXT}-token-user --token $TOKEN

kubectl config set-context $CONTEXT --user ${CONTEXT}-token-user
```

Add `eks-spinnaker` cluster as a Kubernetes provider:

```
hal config provider kubernetes account add eks-spinnaker --context $CONTEXT
```

### 4. Enable artifact support

```
hal config features edit --artifacts true
```

### 5. Configure Spinnaker to install in Kubernetes

For our environment, we will use a distributed Spinnaker installation onto the Kubernetes cluster. This installation model has Halyard deploy each of the Spinnaker microservices separately. A distributed installation helps to limit update-related downtime.

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

Then, set the storage source to S3:

```
hal config storage edit --type s3
```

### 7. Choose the Spinnaker version

To identify the latest version of Spinnaker to install, run the following command to get a list of available versions:

```
hal version list
```

At the time of writing, 1.19.2 is the latest Spinnaker version. Configure Halyard to deploy Spinnaker 1.19.2: 

```
export VERSION=1.19.2

hal config version edit --version $VERSION
```

Now, we are finally ready to install Spinnaker on the `eks-spinnaker` Amazon EKS cluster:

```
hal deploy apply
```

### 8. Verify the Spinnaker installation

```
kubectl -n spinnaker get svc
```

The command returns the Spinnaker services that are in the `spinnaker` namespace.

### 9. Expose Spinnaker using Elastic Load Balancer

Expose the Spinnaker API (Gate) and the Spinnaker UI (Deck) using Load Balancers by running the following commands to create the `spin-gate-public` and `spin-deck-public services`:

```
export NAMESPACE=spinnaker
# Expose Gate and Deck
kubectl -n ${NAMESPACE} expose service spin-gate --type LoadBalancer \
  --port 80 --target-port 8084 --name spin-gate-public 

kubectl -n ${NAMESPACE} expose service spin-deck --type LoadBalancer \
  --port 80 --target-port 9000 --name spin-deck-public  
  
export API_URL=$(kubectl -n $NAMESPACE get svc spin-gate-public \
 -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
 
export UI_URL=$(kubectl -n $NAMESPACE get svc spin-deck-public \
 -o jsonpath='{.status.loadBalancer.ingress[0].hostname}') 

# Configure the URL for Gate
hal config security api edit --override-base-url http://${API_URL} 

# Configure the URL for Deck
hal config security ui edit --override-base-url http://${UI_URL}

# Apply your changes to Spinnaker
hal deploy apply
```

It can take several moments for Spinnaker to restart.

You can verify that the Spinnaker Pods have restarted and check their status:

```
kubectl -n spinnaker get pods
```

### 10. Re-verify the Spinnaker installation

Run the following command to verify that the Spinnaker services are present in the cluster: 

```
kubectl -n spinnaker get svc
```

### 11. Log in to Spinnaker console

Get the URL to Deck, the UI.

```
kubectl -n $NAMESPACE get svc spin-deck-public -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Navigate to the URL in a supported browser and log in.


