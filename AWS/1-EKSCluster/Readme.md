# AWS EKS

<p align="center">
<img width="450 " alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/702ac50f-a906-48cf-bff6-44698ee5b276">
</p>

------

## AWS EKS Service

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/b57ef79d-2c7c-4f95-91f5-f907ceb177f2">
<p>

## Environment Setup
- [ ] aws cli
- [ ] ekscli
- [ ] kubectl

-------

## EKS Cluster

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/ba1ddf21-5afd-470c-bdc7-23afa5dbff0b">
</p>

### Create an EKS Cluster

1. Run the following command to use _Day1Dev_ profile 
```s
export AWS_PROFILE=rodriggj
```

2. Open a terminal session and run the following command: 

```s
eksctl create cluster   \
    --name=eksdemo1     \
    --region=us-east-1  \
    --zones=us-east-1a,us-east-1b   \
    --without-nodegroup
```

2a. Results in a screen similar to the following. The cluster will build over a period of ~15-20 minutes. 

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/ac8b8af6-2f7c-417a-8fbb-570c63c7f6b2">
</p>

3. If you navigate to the EKS service in the AWS Console, you should see something similar to the following: 

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/f6c18417-0147-48bb-b76d-ce9f1ad0d150">
</p>

4. What is happening in the background is the AWS Cloudformation service is utilizing a StackSet to build an AWS EKS Cluster. If you have to the Cloudformation service you will see the following: 

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/f1925ddb-0cd0-4f1c-bff5-1475e22d9c30">
</p>

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/4a0a1e9d-e57a-4dd8-a10d-af817f31e1b9">
</p>

5. Ultimately all the required resources will be provisioned and the EKS cluster will be ready for use. 

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/6c58ea84-9cef-48ec-80d9-7f55382e28e9">
</p>

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/eb335258-6202-4044-ab75-335c5971919d">
</p>

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/aaa379bd-b906-4429-8adb-e28f55b48795">
</p>

6. When the cluster creation process is complete you can run the following command to see the cluster details: 

```s
eksctl get clusters
```

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/d70be9ff-5a26-484d-98e5-e3cf9bd42244">
</p>

So what did you get? What are the resources that were created for you? You can see these in the CloudFormation service, under _Resources_, but a visual depiction is as follows: 

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/aec974cc-cb00-4fe4-a5d7-c1a77044c9f6">
</p>

1. An _Internet Gateway_ resources

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/b4eca542-d601-431b-b3bb-80357c65b1ab">
</p>

2. A _Virual Private Cloud_ resource

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/98c11cf2-2402-40d8-8e3c-233ae6ec3f8d">
</p>

3. Both *public* & *private* _Subnets_

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/292fd709-4ec4-4dd3-a88a-3588b6eade45">
</p>

4. *public* & *private* _Routing Tables_, _Subnet Associations_, & _Route Entries_

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/1af84ef5-2d1e-449b-8de8-1c516eeba4b0">
</p>

5. A _NAT Gateway_

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/78b7884b-2ca3-46b9-97a7-15f5bfb9091c">
</p>

6. An _Elastic IP Address_

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/d43527ac-4021-4d93-8f52-c5264c95c5b3">
</p>

7. Several _Security Groups_

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/04e094c9-293b-49a1-b7ca-2b0e8de5e52b">
</p>

8. And finally, IAM _Policies_, and a _Service Role_

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/56aaf5fe-b587-454f-ad24-019313a82853">
</p>

------

## Create & Associate an IAM OIDC Provider

1. To enable the AWS IAM roles with the K8 Service Accounts on our EKS Cluster, we must create an OIDC identity provider. To do this run the following command: 

```s
eksctl utils associate-iam-oidc-provider \
    --region us-east-1 \
    --cluster eksdemo1 \
    --approve
```

> NOTE: If repeating the above step you will have to validate if the _region_ and _cluster_ name need to be updated. 

2. If the command was formatted correctly and executed you should recieve a response that looks like this

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/7be76dee-a10f-4233-be9a-c92e1823cb70">
</p>

---------

## Create a Key Pair 

1. When we create our worker nodes which will be in our _NodeGroup_ these will be EC2 instances that we will need to interact at with using an RSA token to authenticat too. For this purpose we need to create a named _key pair_. You can do this via the CLI by running the following commaand or navigate to the EC2 AWS console and create one there. 

```s
aws ec2 create-key-pair --key-name eksdemo1
```

## Create the Node Group with Additional Add-Ons in Public Subnets

1. The nodegroup are the worker nodes that will host our container images. To create these on AWS will require some additional IAM policies that can be releatively tedious to do on the IAM console. As such you can use Add-Ons to create the appropriate IAM components needed for the NodeGroup. Run the following command: 
```s
eksctl create nodegroup \
    --cluster=eksdemo1  \
    --region=us-east-1  \
    --name=eksdemo1-ng-public1  \
    --node-type=t3.medium   \
    --nodes=2   \
    --nodes-min=2   \
    --nodes-max=4   \
    --node-volume-size=20   \
    --ssh-access    \
    --ssh-public-key=eksdemo1  \
    --managed   \
    --asg-access    \
    --external-dns-access   \
    --full-ecr-access   \
    --appmesh-access    \
    --alb-ingress-access
```

2. If this command is configured correctly you should see something like the following output in your console. 

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/468383d2-1ec6-44e4-afeb-76c6c80b2279">
</p>

3. So what did you get ... 

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/a807eaee-99f7-492e-93f6-367b3f69f15e">
</p>

4. If we want to verify our node creation from our terminal command line we can also type 

```s
kubectl get nodes 
# or 
kubectl get nodes -o wide
```

Which should result in the following: 

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/01566757-b744-425d-9f5b-ef3fc7fc36f4">
</p>

---------

## SSH into the EC2 Hosts 

1. In a terminal session change directories to the location you placed the _eksdemo1.pem_ file. 
```s
cd ~/Desktop/k8_cluster_demo/AWS
```

2. Change the permissions on the .pem file to read-only
```s
chmod 400 eksdemo1.pem
```

3. Reference the .pem file with an ssh command to connect to the ec2 host with its public IP address. 
```s
# First ec2 host
ssh -i "eksdemo1.pem" ec2-user@3.85.162.7

# In a seperate terminal session do the same thing
ssh -i "eksdemo1.pem" ec2-user@44.200.14.66
```

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/dfe72b6a-00ca-496f-9d14-35f81759305c">
</p>

--------

## Delete the EKS Cluster 

1. To not incur costs unnecessarily, you will want to delete the cluster and the associated nodes with the following command: 

```s
eksctl delete cluster eksdemo1
```

---------