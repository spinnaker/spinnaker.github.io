---
layout: single
title:  "Deploy to Google Kubernetes Engine with RBAC"
sidebar:
  nav: setup
---

{% include toc %}

If you've deployed Spinnaker already using [this
codelab](/setup/quickstart/halyard-gke) you're left with a Spinnaker that can only deploy to the cluster that Spinnaker is deployed in.
In many cases you want to deploy to clusters in another GCP project that also have Kubernetes RBAC enabled.

In this codelab, we will enable Spinnaker to push your containers to another GCP project that have a cluster secured by RBAC. This codelab will allow Spinnaker to be able to manipulate all deployments in the target cluster. 
You may want to limit Spinnaker further but how to do that is not covered by this tutorial. 
This guide won't show you how to setup Spinnaker in a RBAC cluster.

## Overview

At the end of this guide you will have

* A new Kubernetes provider with RBAC enabled
* Ability to deploy to a cluster in another GCP project

## Part 0: Prerequisites

A GCP project (referred to as $GCP_PROJECT) running a Spinnaker [GKE cluster with halyard](/setup/quickstart/halyard-gke/)

Another K8s cluster (referred to as $K8_TEST) running with Kubernetes version > 1.6 on another GCP project ($GCP_TEST)

## Part 1: Configure Gcloud

Make sure that you are authenticated against the test cluster ($K8_TEST). 

```bash
gcloud info
```

If you are unfamiliar with how to use multiple project with gcloud you can use this [guide](https://cloud.google.com/sdk/docs/managing-configurations) to get started

Set your zone and project variables and get the credentials for the kubernetes cluster

```bash
GCP_PROJECT=my-spinnaker-project
ZONE=us-central1-f
K8_TEST=my-test-cluster
GCP_TEST=my-test-project
gcloud container clusters get-credentials $K8_TEST --zone $ZONE --project $GCP_TEST
```

## Part 2: Add Service account to GCP

Create the service account in GCP test project (note that you get the service account from your Spinnaker project)

````bash
HALYARD_SA=halyard-service-account

#Get the SA email from the Spinnaker project
HALYARD_SA_EMAIL=$(gcloud iam service-accounts list \
    --project=$GCP_PROJECT \
    --filter="displayName:$HALYARD_SA" \
    --format='value(email)')

#Add policy bindings in the Test project
gcloud projects add-iam-policy-binding $GCP_TEST \
    --role roles/iam.serviceAccountKeyAdmin \
    --member serviceAccount:$HALYARD_SA_EMAIL

gcloud projects add-iam-policy-binding $GCP_TEST \
    --role roles/container.admin \
    --member serviceAccount:$HALYARD_SA_EMAIL
```` 
## Part 3: Add a service account (SA) to kubernetes

Next we need to add a service account to kubernetes that will handle the authorization inside the kubernetes cluster.
Create a file, spinnaker-service-account.yaml, with the following content:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: spinnaker-service-account
  namespace: default
```
Apply the service account

```bash
kubectl apply -f ./spinnaker-service-account.yaml
```

Then we need to set access for Spinnaker to edit the cluster in order to let Spinnaker manage deployments to the cluster

```bash
kubectl create clusterrolebinding \
    --user system:serviceaccount:default:spinnaker-service-account \
    spinnaker \
    --clusterrole edit
```
    
If you can't create a clusterrolebinding make sure that you have the right permissions.
The following command enables you to make other roles in the cluster

```bash
#replace your.google.cloud.email@example.org with your Gcloud account
kubectl create clusterrolebinding user-cluster-admin-binding \
    --clusterrole=cluster-admin \
    --user=your.google.cloud.email@example.org
```
      
Now we want to get the secret for the service account that was created by kubernetes. 
Store it somewhere safe for the next part

```bash
#Get the name of the secret
SERVICE_ACCOUNT_TOKEN=`kubectl get serviceaccounts spinnaker-service-account -o jsonpath='{.secrets[0].name}'`

#Get token and base64 decode it since all secrets are stored in base64 in kubernetes and store it somewhere safe for later use
kubectl get secret $SERVICE_ACCOUNT_TOKEN -o jsonpath='{.data.token}' | base64 -D
```

## Part 4: Add provider to halyard

SSH in to your halyard instance

```bash
gcloud compute ssh $HALYARD_HOST \
    --project=$GCP_PROJECT \
    --ssh-flag="-L 9000:localhost:9000" \
    --ssh-flag="-L 8084:localhost:8084"
```

Add the credentials to the kubeconfig file

```bash
gcloud container clusters get-credentials $K8_TEST --project $GCP_TEST --zone us-central1-f
```

Get the new user profile that was created by gcloud and add the token you received before in part 3

```bash
TEST_USER_PROFILE=`kubectl config current-context`
kubectl config set-credentials $TEST_USER_PROFILE --token replace-with-your-token-here
```

Add the new kubernetes provider
```bash
hal config provider kubernetes account add my-test-account \
    --docker-registries my-gcr-account \
    --context $(kubectl config current-context)
```

Apply your changes to Spinnaker

```bash
hal deploy apply
```



