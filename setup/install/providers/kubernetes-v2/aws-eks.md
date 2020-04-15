---
layout: single
title:  "Set up a K8s v2 provider for Amazon EKS"
sidebar:
  nav: setup
---

{% include toc %}

> Before you proceed further with this setup, we strongly recommend that you familiarize yourself with [Amazon EKS concepts](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html).
Also, please visit the [AWS global infrastructure region table](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/) for the most up-to-date information on Amazon EKS regional availability.

These instructions assume that you have AWS CLI [installed](https://docs.aws.amazon.com/cli/latest/userguide/installing.html),
[configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html), and have access to each of the managed account and managing account.

## Set up the managing account

In the managing account, create a two-subnet VPC, IAM roles, instance profiles, and a Security Group for EKS control-plane communications and an EKS cluster.

> This step will take around 15-20 minutes to complete
   
```bash
curl -O https://d3079gxvs8ayeg.cloudfront.net/templates/managing.yaml  
aws cloudformation deploy --stack-name spinnaker-managing-infrastructure-setup --template-file managing.yaml \
--parameter-overrides UseAccessKeyForAuthentication=false EksClusterName=spinnaker-cluster --capabilities CAPABILITY_NAMED_IAM
```

After the stack creation succeeds, run the following:

```bash
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

## Set up the managed account

In each of managed accounts, create a IAM role that can be assumed by Spinnaker:

> This needs to be executed in managing account as well.

```bash
curl -O https://d3079gxvs8ayeg.cloudfront.net/templates/managed.yaml  

aws cloudformation deploy --stack-name spinnaker-managed-infrastructure-setup --template-file managed.yaml \
--parameter-overrides AuthArn=$AUTH_ARN ManagingAccountId=$MANAGING_ACCOUNT_ID --capabilities CAPABILITY_NAMED_IAM
```

## `kubectl` and `heptio authenticator` configurations

1. Install and configure [kubectl and aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html) on the workstation/instance where you are running Halyard from. Halyard version must be >=1.5.0.

    Also, when an Amazon EKS cluster is created, the IAM entity (user or role) that creates the cluster is added to the Kubernetes RBAC authorization table as the administrator. Initially, only that IAM user can make calls to the Kubernetes API server using `kubectl`.

    If you use the console to create the cluster, you must ensure that the same IAM user credentials are in the AWS SDK credential chain when you are running `kubectl` commands on your cluster.

    In the setup as done above, we used AWS CLI, hence you must ensure that the server/workstation from where you are running the `kubectl` commands in step-2 below have the same AWS credentials.

{:start="2"}

2. Create default [kubectl configuration file](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html)

    Paste the following to your `kubeconfig` file, replace `<endpoint-url>`, `<base64-encoded-ca-cert>` and `<cluster-name>` with values of `$EKS_CLUSTER_ENDPOINT`, `$EKS_CLUSTER_CA_DATA` and `$EKS_CLUSTER_NAME`
    as noted above:

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
      command: aws-iam-authenticator
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

   (Optional) To have the Heptio authenticator assume a role to perform cluster operations (instead of the default AWS credential provider chain), uncomment the `-r` and `<role-arn>` lines and substitute an IAM role ARN to use with your user.

   (Optional) To have the Heptio authenticator always use a specific named AWS credential profile (instead of the default AWS credential provider chain), uncomment the env lines and substitute `<aws-profile>` with the profile name to use.

{:start="3"}

3. [Create the necessary service accounts and cluster role bindings](/setup/install/providers/kubernetes-v2/#optional-create-a-kubernetes-service-account)

## Enable Kubernetes Cloud provider using Halyard

```bash
hal config provider kubernetes enable
hal config provider kubernetes account add ${MY_K8_ACCOUNT} --provider-version v2 --context $(kubectl config current-context)
```

Finally, enable [artifact support](/reference/artifacts-with-artifactsrewrite//#enabling-artifact-support).

## Launch and Configure Amazon EKS Worker Nodes

Worker nodes launched using the below commands are standard Amazon EC2 instances and use [EKS optimized AMIs](https://docs.aws.amazon.com/eks/latest/userguide/worker.html).

```bash
curl -O https://d3079gxvs8ayeg.cloudfront.net/templates/amazon-eks-nodegroup.yaml
aws cloudformation deploy --stack-name spinnaker-eks-nodes --template-file amazon-eks-nodegroup.yaml \
--parameter-overrides NodeInstanceProfile=$SPINNAKER_INSTANCE_PROFILE_ARN \
NodeInstanceType=t2.large ClusterName=$EKS_CLUSTER_NAME NodeGroupName=spinnaker-cluster-nodes ClusterControlPlaneSecurityGroup=$CONTROL_PLANE_SG \
Subnets=$SUBNETS VpcId=$VPC_ID --capabilities CAPABILITY_NAMED_IAM

```

## Join the nodes with the Spinnaker EKS cluster

Replace `<spinnaker-role-arn>` with `$AUTH_ARN` and save it as `aws-auth-cm.yaml`

{% raw %}
```yaml
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
{% endraw %}

Join the nodes with the cluster:

```bash
kubectl apply -f aws-auth-cm.yaml
```

Watch the status of your nodes and wait for them to reach the `Ready` status:

```bash
kubectl get nodes --watch
```

## Next steps

Optionally, you can [set up another cloud provider](/setup/install/providers/), but otherwise you’re ready to [choose an environment](/setup/install/environment/) in which to install Spinnaker.

