---
layout: single
title:  "Amazon EKS"
sidebar:
  nav: setup
---

{% include toc %}

> Before you proceed with installing Spinnaker on EKS, we strongly recommend that you familiarize yourself with [Amazon EKS concepts](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)

Below are the instructions to be followed if you want to configure [Kubernetes V2 (manifest based) Clouddriver](/setup/install/providers/kubernetes-v2) 
to run Spinnaker on [Amazon EKS](https://aws.amazon.com/eks/).

These instructions assumes that you have AWS CLI [installed](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) ,
[configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) and have access to managing and each of the managed account.

## Managing Account - Base Setup

In Managing Account Create a two subnet VPC , IAM Roles, Instance Profiles and Security Group for EKS control plane communication and an EKS Cluster

> This step will take around 15-20 minutes to complete
   
```
curl -O https://raw.githubusercontent.com/spinnaker/spinnaker.github.io/master/setup/install/providers/aws/managing.yaml  
aws cloudformation deploy --stack-name spinnaker-managing-infrastructure-setup --template-file managing.yaml \
--parameter-overrides UseAccessKeyForAuthentication=false --capabilities CAPABILITY_NAMED_IAM
```

Once the stack creation succeeds, note the following

```
VPC_ID=$(aws cloudformation describe-stacks --stack-name spinnaker-managing-infrastructure-setup --query 'Stacks[0].Outputs[?OutputKey==`VpcId`].OutputValue' --output text)
CONTROL_PLANE_SG=$(aws cloudformation describe-stacks --stack-name spinnaker-managing-infrastructure-setup --query 'Stacks[0].Outputs[?OutputKey==`SecurityGroups`].OutputValue' --output text)
AUTH_ARN=$(aws cloudformation describe-stacks --stack-name spinnaker-managing-infrastructure-setup --query 'Stacks[0].Outputs[?OutputKey==`AuthArn`].OutputValue' --output text)
SUBNETS=$(aws cloudformation describe-stacks --stack-name spinnaker-managing-infrastructure-setup --query 'Stacks[0].Outputs[?OutputKey==`SubnetIds`].OutputValue' --output text)
MANAGING_ACCOUNT_ID=$(aws cloudformation describe-stacks --stack-name spinnaker-managing-infrastructure-setup --query 'Stacks[0].Outputs[?OutputKey==`ManagingAccountId`].OutputValue' --output text)
EKS_CLUSTER_ENDPOINT=$(aws cloudformation describe-stacks --stack-name spinnaker-managing-infrastructure-setup --query 'Stacks[0].Outputs[?OutputKey==`EksClusterEndpoint`].OutputValue' --output text)
EKS_CLUSTER_NAME=$(aws cloudformation describe-stacks --stack-name spinnaker-managing-infrastructure-setup --query 'Stacks[0].Outputs[?OutputKey==`EksClusterName`].OutputValue' --output text)
EKS_CLUSTER_CA_DATA=$(aws cloudformation describe-stacks --stack-name spinnaker-managing-infrastructure-setup --query 'Stacks[0].Outputs[?OutputKey==`EksClusterCA`].OutputValue' --output text)
SPINNAKER_INSTANCE_PROFILE_ARN=$(aws cloudformation describe-stacks --stack-name spinnaker-managing-infrastructure-setup --query 'Stacks[0].Outputs[?OutputKey==`SpinnakerInstanceProfileArn`].OutputValue' --output text)
```


## Managed Account - Base setup

In each of managed account, create role that can be assumed by Spinnaker

> This needs to be executed in managing account as well.

```

aws cloudformation deploy --stack-name spinnaker-managed-infrastructure-setup --template-file managed.yaml \
--parameter-overrides AuthArn=$AUTH_ARN ManagingAccountId=$MANAGING_ACCOUNT_ID --capabilities CAPABILITY_NAMED_IAM

```

## kubectl configurations

Before you proceed next, ensure to configure [kubectl and heptio authenticator for aws is installed and configured](https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html)

Also, when an Amazon EKS cluster is created, the IAM entity (user or role) that creates the cluster is added to the Kubernetes RBAC authorization table as the administrator. Initially, only that IAM user can make calls to the Kubernetes API server using kubectl.

If you use the console to create the cluster, you must ensure that the same IAM user credentials are in the AWS SDK credential chain when you are running kubectl commands on your cluster.

In the setup as done above, we used AWS CLI , hence you must ensure that the server/workstation from where you are running the following kubectl commands have the same AWS credentials.


*  Create default kubectl configuration file

Paste the following to your kubeconfig file , replace `<endpoint-url>` , `<base64-encoded-ca-cert>` and `<cluster-name>` with values of $EKS_CLUSTER_ENDPOINT , $EKS_CLUSTER_CA_DATA and $EKS_CLUSTER_NAME
as noted above

```yaml

apiVersion: v1
clusters:
- cluster:
    server: <endpoint-url>
    certificate-authority-data: <base64-encoded-ca-cert>
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: heptio-authenticator-aws
      args:
        - "token"
        - "-i"
        - "<cluster-name>"
        # - "-r"
        # - "<role-arn>"
      # env:
        # - name: AWS_PROFILE
        #   value: "<aws-profile>"

```

* Execute the following commands, which will create the necessary services accounts and cluster role bindings

```
CONTEXT=aws
kubectl apply -f https://raw.githubusercontent.com/spinnaker/spinnaker.github.io/master/setup/install/providers/aws/eks/eks-admin-service-account.yaml 
kubectl apply -f https://raw.githubusercontent.com/spinnaker/spinnaker.github.io/master/setup/install/providers/aws/eks/eks-admin-cluster-role-binding.yaml 
kubectl apply -f https://raw.githubusercontent.com/spinnaker/spinnaker.github.io/master/setup/install/providers/aws/eks/spinnaker-service-account.yaml 
kubectl create namespace spinnaker
kubectl apply -f https://raw.githubusercontent.com/spinnaker/spinnaker.github.io/master/setup/install/providers/aws/eks/spinnaker-service-account.yaml 
kubectl apply -f https://raw.githubusercontent.com/spinnaker/spinnaker.github.io/master/setup/install/providers/aws/eks/spinnaker-cluster-role-binding.yaml 
TOKEN=$(kubectl get secret --context $CONTEXT \
   $(kubectl get serviceaccount spinnaker-service-account \
       --context $CONTEXT \
       -n spinnaker \
       -o jsonpath='{.secrets[0].name}') \
   -n spinnaker \
   -o jsonpath='{.data.token}' | base64 --decode)
kubectl config set-credentials ${CONTEXT}-token-user --token $TOKEN
kubectl config set-context $CONTEXT --user ${CONTEXT}-token-user
```

> This point onwards, the location (either EC2 instance, or local) where you run halyard commands from should have the kubeconfig file that was created
by the above kubectl commands. If you ran the kubectl commands locally and want to run halyard command on an instance, then you can copy the kubeconfig file
from local to the instance.

## Enable Kubernetes Cloud provider using Halyard

```
./hal config provider kubernetes enable
./hal config provider kubernetes account add ${MY_K8_ACCOUNT}   --provider-version v2   --context $(kubectl config current-context)
./hal config features edit --artifacts true
```


## Enable EC2 Cloud Provider using Halyard

```

./hal config provider aws account add ${NAME_OF_YOUR_AWS_ACCOUNT} \
    --account-id ${YOUR_AWS_ACCOUNT_ID} \
    --assume-role role/spinnakerManaged

./hal config provider aws enable

```


## Choose Halyard distributed deployment

```

./hal config deploy edit --type distributed --account-name ${MY_K8_ACCOUNT}

```

## Choose persistant storage to S3 using Halyard


```
./hal config storage s3 edit \
    --access-key-id ${ACCESS_KEY_HAVING_S3_ACCESS} \
    --secret-access-key \
    --region us-west-2

./hal config storage edit --type s3

```

## Create Kubernetes worker nodes

```
curl -O https://raw.githubusercontent.com/spinnaker/spinnaker.github.io/master/setup/install/providers/aws/amazon-eks-nodegroup.yaml  
aws cloudformation deploy --stack-name spinnaker-eks-nodes --template-file amazon-eks-nodegroup.yaml \
--parameter-overrides NodeInstanceProfile=$SPINNAKER_INSTANCE_PROFILE_ARN \
NodeInstanceType=t2.large ClusterName=$EKS_CLUSTER_NAME NodeGroupName=spinnaker-cluster-nodes ClusterControlPlaneSecurityGroup=$CONTROL_PLANE_SG \
Subnets=$SUBNETS VpcId=$VPC_ID --capabilities CAPABILITY_NAMED_IAM

```

## Join the nodes created above with Spinnaker EKS cluster and watch them to appear in ready state

Replace `<spinnaker-role-arn>` with $AUTH_ARN and save it as aws-auth-cm.yaml

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: <spinnaker-role-arn>
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes

```

Run following to join nodes with the cluster

```
kubectl apply -f aws-auth-cm.yaml
```

Watch the nodes to come in ready state

```

kubectl get nodes --watch

```

## Deploy Spinnaker using Halyard

```

./hal config version edit --version 1.7.6
./hal deploy apply

```

## Connect

```

./hal deploy connect

```
