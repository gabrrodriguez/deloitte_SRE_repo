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





1. Create IAM Policy and make a note of Policy ARN
2. Create IAM Role and k8s Service Account and bound them together
3. Install AWS Load Balancer Controller using HELM3 CLI
4. Understand IngressClass Concept and create a default Ingress Class


## Process 
