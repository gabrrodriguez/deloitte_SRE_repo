# Creating Persistent Storage for K8 images: Elastic Block Store (EBS)

## Steps: 
1. [Install Container Storage Interface (CSI) Driver on K8 Cluster](https://github.com/gabrrodriguez/deloitte_SRE_repo/tree/main/AWS/EKS/4-EKSVolumes#install-container-storage-interface-csi-driver-on-k8-cluster)

2. [Configure the manifests for *StorageClass*, *PVC*, & *ConfigMap*](https://github.com/gabrrodriguez/deloitte_SRE_repo/tree/main/AWS/EKS/4-EKSVolumes#configure-the-manifests-for-storageclass-pvc--configmap)

----------

## Install Container Storage Interface (CSI) Driver on K8 Cluster <sub>[AWS Documentation: CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)</sub>

### 1. Create an IAM Policy

1. Go to IAM 
2. Use the following JSON blob to create an IAM Policy

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow", 
            "Action": [
                "ec2:AttachVolume",
                "ec2:CreateSnapshot",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:DeleteSnapshot",
                "ec2:DeleteTags",
                "ec2:DeleteVolume",
                "ec2:DescribeInstances",
                "ec2:DescribeSnapshots",
                "ec2:DescribeTags",
                "ec2:DescribeVolumes",
                "ec2:DetachVolume"
            ],
            "Resource": "*"   
        }
    ]
}
```
3. Configure the Policy
    a. Name: *Amazon_EBS_CSI_Driver*
    b. Description: *Policy for EC2 instances to access EBS on behalf of EKS K8 Cluster*

4. Click *Create Policy*

### 2. Associate IAM Policy to Worker Nodes 

1. Get the Worker Node IAM Role ARN
```s
kubectl -n kube-system describe configmap aws-auth
```
The output will be as follows: 

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/d2993c34-43c1-40a4-85cf-418194cd64fa">
</p>

2. Copy the _arn_ and we will search this in the IAM roles so we can associate our Policy we creaeted. 
```s
eksctl-eksdemo1-nodegroup-eksdemo1-NodeInstanceRole-6r1Uny2vdM2R
```

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/076d6cbb-20ef-4f93-ac8b-9a9ab49483e3">
</p>

3. Go to the IAM 

Select the policy and click *Attach Policies*

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/3f883e21-bf1e-4e19-a222-480c48cd0a5d">
</p>

Now search for the policy we created *AWS_EBS_CSI_Driver* and associate the policy to this role. 

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/061a60f3-601d-449a-a05a-4b89b9c8773a">
</p>

> An alternative way to have found the role instead of using the `kubectl` command listed in Step 1. If you navigate to the EC2 console, and select one of the worker nodes that we created, and view the bottom half of the EC2 output you will find an attibute for IAM role. 

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/060e0f43-aca5-4af3-9f2f-65d03aa5e99f">
</p>

### 3. Install EBS CSI Driver

1. Now we can deploy the EBS CSI Driver. First validate that the k8 version you are running is *greater* than 1.14. To do this run the following command: 

```s
kubectl version --client --short
```

Here we see that we are running 1.26 so we should be good to install the driver. 

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/aed538b9-6da6-4dd2-aec1-64cbed429563">
</p>

2. Run the following command to install the CSI Driver

```s
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable?ref=master" 
```
> NOTE: There are a suite of utilitiy packages that are open source to support various K8 projects. See github for Special Interest Groups (SIG) repo here [kubernetes-sigs](https://github.com/kubernetes-sigs)

Which should result in something like this: 

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/60d08971-752c-4a0c-8110-5195b8cd1259">
</p>

3. So if we now check the pods in the `kube-system` namespace we should see that the CSI driver is installed by the creation of some pods

```s
kubectl get pods -n kube-system 
```

Should result in something that looks like this 

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/adba1b16-1846-4847-bf20-239e873d18cf">
</p>

---------

## Configure the manifests for *StorageClass*, *PVC*, & *ConfigMap*

Here we will create a series of K8 Objects to support a MySQL pod that requires persistent storage. In total we will create 5 K8 Manifests: 

| Kubernetes Object | K8 Manifest       |
| ----------------- | ----------------- |
| Storage Class     | storage-class.yml |
| Storage Class     | storage-class.yml |
| Storage Class     | storage-class.yml |
| Storage Class     | storage-class.yml |
| Storage Class     | storage-class.yml |

1. 