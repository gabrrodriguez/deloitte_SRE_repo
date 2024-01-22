# Application Load Balancer

## Pre-Reqs

### 1. Install & configure CLI Tools (`eksctl`, `kubectl`, `aws cli`)
```s
# Verify eksctl version
eksctl version

# For installing or upgrading latest eksctl version
https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html

# Verify EKS Cluster version
kubectl version --short
kubectl version
Important Note: You must use a kubectl version that is within one minor version difference of your Amazon EKS cluster control plane. For example, a 1.20 kubectl client works with Kubernetes 1.19, 1.20 and 1.21 clusters.

# For installing kubectl cli
https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
```

### 2. Create the Cluster & Worker Nodes

#### 2a. Create the Cluster using `eksctl`
1. Execute the following command
```s
eksctl create cluster --name=eksdemo1 \
                      --region=us-east-1 \
                      --zones=us-east-1a,us-east-1b \
                      --without-nodegroup 
```

2. Verify cluster was created 
```
eksctl get cluster   
```

#### 2b. Create & Associate IAM OIDC Provider for our EKS Cluster
1. To enable and use AWS IAM roles for Kubernetes service accounts on our EKS cluster, we must create & associate OIDC identity provider. Run the following command: 

```s
eksctl utils associate-iam-oidc-provider \
    --region us-east-1 \
    --cluster eksdemo1 \
    --approve
```

#### 2c. Create an EC2 Keypair
1. Create a new EC2 Keypair with name as `kube-demo`. This keypair we will use it when creating the EKS NodeGroup.

#### 2d. Create Node Group with additional Add-Ons

##### Public Subnet to deploy NodeGroup
1. These add-ons will create the respective IAM policies for us automatically within our Node Group role. Run the following command: 

```s
eksctl create nodegroup --cluster=eksdemo1 \
                       --region=us-east-1 \
                       --name=eksdemo1-ng-public1 \
                       --node-type=t3.medium \
                       --nodes=2 \
                       --nodes-min=2 \
                       --nodes-max=4 \
                       --node-volume-size=20 \
                       --ssh-access \
                       --ssh-public-key=kube-demo \
                       --managed \
                       --asg-access \
                       --external-dns-access \
                       --full-ecr-access \
                       --appmesh-access \
                       --alb-ingress-access 
```

##### Private Subnet to deploy Nodegroup
```s
eksctl create nodegroup --cluster=eksdemo1 \
                        --region=us-east-1 \
                        --name=eksdemo1-ng-private1 \
                        --node-type=t3.medium \
                        --nodes-min=2 \
                        --nodes-max=4 \
                        --node-volume-size=20 \
                        --ssh-access \
                        --ssh-public-key=kube-demo \
                        --managed \
                        --asg-access \
                        --external-dns-access \
                        --full-ecr-access \
                        --appmesh-access \
                        --alb-ingress-access \
                        --node-private-networking  
```

> NOTE: If you created a public nodegroup and want to delete it to replace with a private nodegroup (or vice versa) run the following command ```s eksctl delete nodegroup eksdemo1-ng-public1 --cluster eksdemo1```

> ADDL NOTE: Per security best practice you want to deploy your Worker Nodegroups to `Private Subnets` unless there is a specific reason to do otherwise.


#### 2e. Verify Cluster & Nodes
1. Verify NodeGroup subnets to confirm EC2 Instances are in Public Subnet
2. Verify Cluster, NodeGroup in EKS Management Console
3. List Worker Nodes
4. Verify Worker Node IAM Role and list of Policies
5. Verify Security Group Associated to Worker Nodes
6. Verify CloudFormation Stacks
7. Login to Worker Node using Keypair `kube-demo`

#### 2f. Update Worker Nodes Security Group to allow all traffic
1. Update SG to allow traffic from `0.0.0.0/0`

---------

### 3. Verify Cluster, Node Groups and configure kubectl cli if not configured

```s
# Verfy EKS Cluster
eksctl get cluster

# Verify EKS Node Groups
eksctl get nodegroup --cluster=eksdemo1

# Verify if any IAM Service Accounts present in EKS Cluster
eksctl get iamserviceaccount --cluster=eksdemo1
Observation:
1. No k8s Service accounts as of now. 

# This means that the kubeconfig file did not get configured with your eks cluster when you executed your eks cluster create commnad. 
# The config file is located at $HOME/.kube/config. If ever you cannot run a command that starts with kubectl it is b/c this file is not configured

# Configure kubeconfig for kubectl
eksctl get cluster # TO GET CLUSTER NAME
aws eks --region <region-code> update-kubeconfig --name <cluster_name>
aws eks --region us-east-1 update-kubeconfig --name eksdemo1

# Verify EKS Nodes in EKS Cluster using kubectl
kubectl get nodes

# Verify using AWS Management Console
1. EKS EC2 Nodes (Verify Subnet in Networking Tab)
2. EKS Cluster
```

------------

#### 4 - Create IAM Policy

4a. Create IAM policy for the AWS Load Balancer Controller that allows it to make calls to AWS APIs on your behalf. As on today 2.3.1 is the latest Load Balancer Controller. We will download always latest from main branch of Git Repo [aws-load-balancer-controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller). 

4b. Go to relevant directory and ensure that we don't have any config files
```s
# Change Directroy
cd 08-NEW-ELB-Application-LoadBalancers/
cd 08-01-Load-Balancer-Controller-Install

# Delete files before download (if any present)
rm iam_policy_latest.json
```

4c. Download sample IAM policies

```s
# Download IAM Policy
## Download latest
curl -o iam_policy_latest.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
## Verify latest
ls -lrta 

## Download specific version
curl -o iam_policy_v2.3.1.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.1/docs/install/iam_policy.json
```

4d. Use the files downloaded to create the necessary policy for your eksdemo1 cluster. Note the of the Policy ARN. 

```s
# Create IAM Policy using policy downloaded 
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy_latest.json
```

> NOTE: In this process, there is a high potential that there may be an error that needs resoluton. 
```s
gabrrodriguez@US-NF9V9G1605 8-ALB % aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy_latest.json

An error occurred (InvalidClientTokenId) when calling the CreatePolicy operation: The security token included in the request is invalid.
```

There have been changes in ELB v2 from other versions so, this error may not be applicable as you see, if you attempt to provide the profile with the relevant key to disposition the error you can see that the previous attempt did work. 

```s
gabrrodriguez@US-NF9V9G1605 8-ALB % export AWS_PROFILE="rodriggj"
gabrrodriguez@US-NF9V9G1605 8-ALB % aws iam create-policy \      
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy_latest.json

An error occurred (EntityAlreadyExists) when calling the CreatePolicy operation: A policy called AWSLoadBalancerControllerIAMPolicy already exists. Duplicate names are not allowed.
```

So the intial error was incorrect. You can validate this by going to the IAM Console and seeing if there was in fact a policy created called `AWSLoadBalancerControllerIAMPolicy`, 

4e. Create an IAM Role for the `AWS Load Balancer Controller` and attach the role to the K8 service account. 

```
# Verify if any existing service account
kubectl get sa -n kube-system
kubectl get sa aws-load-balancer-controller -n kube-system
```

> NOTE: Nothing with the name `aws-load-balancer-controller` should exist

```s
# Run the following command having input name, cluster and policy arn
eksctl create iamserviceaccount \
  --cluster=eksdemo1 \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::551061066810:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
```

You should see sample output similar to the following:

```s
2024-01-17 11:09:05 [ℹ]  1 iamserviceaccount (kube-system/aws-load-balancer-controller) was included (based on the include/exclude rules)
2024-01-17 11:09:05 [!]  metadata of serviceaccounts that exist in Kubernetes will be updated, as --override-existing-serviceaccounts was set
2024-01-17 11:09:05 [ℹ]  1 task: { 
    2 sequential sub-tasks: { 
        create IAM role for serviceaccount "kube-system/aws-load-balancer-controller",
        create serviceaccount "kube-system/aws-load-balancer-controller",
    } }2024-01-17 11:09:05 [ℹ]  building iamserviceaccount stack "eksctl-eksdemo1-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2024-01-17 11:09:06 [ℹ]  deploying stack "eksctl-eksdemo1-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2024-01-17 11:09:06 [ℹ]  waiting for CloudFormation stack "eksctl-eksdemo1-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2024-01-17 11:09:37 [ℹ]  waiting for CloudFormation stack "eksctl-eksdemo1-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2024-01-17 11:09:38 [ℹ]  created serviceaccount "kube-system/aws-load-balancer-controller"
```

You can verify creation and association with the `ekscli`

```s
eksctl get iamserviceaccount --cluster eksdemo1
```

Final verification should be to verify with Cloudformation 
- Goto Services -> CloudFormation 
- CFN Template Name: eksctl-eksdemo1-addon-iamserviceaccount-kube-system-aws-load-balancer-controller
- Click on Resources tab
- Click on link in Physical Id to open the IAM Role
- Verify it has eksctl-eksdemo1-addon-iamserviceaccount-kube-Role1-WFAWGQKTAVLR associated

4f. Verify k8s Service Account using `kubectl`
```s
kubectl get sa -n kube-system
kubectl get sa aws-load-balancer-controller -n kube-system
kubectl describe sa aws-load-balancer-controller -n kube-system
```

-------

#### 5. Install the AWS Load Balancer Controller using Helm V3

5a. Install `helm`

```s
# Install Helm (if not installed) MacOS
brew install helm

# Verify Helm version
helm version
```

5b. Install AWS Load Balancer Controller

5b 1: 
```s
# Add the eks-charts repository.
helm repo add eks https://aws.github.io/eks-charts

# Update your local repo to make sure that you have the most recent charts.
helm repo update
```

5b 2: To run the next command you will need to gather the 1. `eksCluster Name`, 2. `regionCode`, 3. `vpcId` of our EKS cluster, 4. `accountId` 
```s
# Install the AWS Load Balancer Controller.
## Template
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=<region-code> \
  --set vpcId=<vpc-xxxxxxxx> \
  --set image.repository=<account>.dkr.ecr.<region-code>.amazonaws.com/amazon/aws-load-balancer-controller

## Replace Cluster Name, Region Code, VPC ID, Image Repo Account ID and Region Code  
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=eksdemo1 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=vpc-0081be58f12530dba \
  --set image.repository=602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller
```

You should see something similar to this if everything worked correctly: 
```s
gabrrodriguez@US-NF9V9G1605 8-ALB % helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=eksdemo1 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=vpc-0081be58f12530dba \
  --set image.repository=602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller
NAME: aws-load-balancer-controller
LAST DEPLOYED: Mon Jan 22 10:31:10 2024
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
AWS Load Balancer controller installed!
```

> NOTE 1: If you're deploying the controller to Amazon EC2 nodes that have restricted access to the Amazon EC2 instance metadata service (IMDS), or if you're deploying to Fargate, then add the following flags to the command that you run:
```s
--set region=region-code
--set vpcId=vpc-xxxxxxxx
```

> NOTE 2: If you're deploying to any Region other than us-west-2, then add the following flag to the command that you run, replacing account and region-code with the values for your region listed in Amazon EKS add-on container image addresses. [Get Region & Account Info](https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html)

```s
--set image.repository=account.dkr.ecr.region-code.amazonaws.com/amazon/aws-load-balancer-controller
```

5c. Verify that the installation is complete with `kubectl`

```s
# Verify that the controller is installed.
kubectl -n kube-system get deployment 
kubectl -n kube-system get deployment aws-load-balancer-controller
kubectl -n kube-system describe deployment aws-load-balancer-controller
```

5d. Verify that AWS Load Balancer Controller Webhook Service is Created 

```s
kubectl -n kube-system get svc 
kubectl -n kube-system get svc aws-load-balancer-webhook-service
kubectl -n kube-system describe svc aws-load-balancer-webhook-service
```

5e. Verify labels in Service and Selector labels are in Deployment 
```s
kubectl -n kube-system get svc aws-load-balancer-webhook-service -o yaml
kubectl -n kube-system get deployment aws-load-balancer-controller -o yaml
```

Validation Steps: 
1. Verify `spec.selector` label in `aws-load-balancer-webhook-service`
2. Compare it with `aws-load-balancer-controller` Deployment `spec.selector.matchLabels`
3. Both values should be same which traffic coming to `aws-load-balancer-webhook-service` on port 443 will be sent to port 9443 on `aws-load-balancer-controller` deployment related pods. 

5f. Verify AWS Load Balancer Controller Logs

```s
# List Pods
kubectl get pods -n kube-system

# Review logs for AWS LB Controller POD-1
kubectl -n kube-system logs -f <POD-NAME> 
kubectl -n kube-system logs -f  aws-load-balancer-controller-86b598cbd6-5pjfk

# Review logs for AWS LB Controller POD-2
kubectl -n kube-system logs -f <POD-NAME> 
kubectl -n kube-system logs -f aws-load-balancer-controller-86b598cbd6-vqqsk
```

5g. Verify AWS Load Balancer Controller k8 Service Account - Internals

```s
# List Service Account and its secret
kubectl -n kube-system get sa aws-load-balancer-controller
kubectl -n kube-system get sa aws-load-balancer-controller -o yaml
kubectl -n kube-system get secret <GET_FROM_PREVIOUS_COMMAND - secrets.name> -o yaml
kubectl -n kube-system get secret aws-load-balancer-controller-token-5w8th 
kubectl -n kube-system get secret aws-load-balancer-controller-token-5w8th -o yaml
```