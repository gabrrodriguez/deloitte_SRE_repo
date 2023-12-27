#!/bin/bash 

# Configure the AWS CLI with a profile on your local
# Export the profile to interact with your AWS account via the CLI
export AWS_PROFILE=rodriggj

# Create an EKS cluster, in US East region via a CloudFormation Stackset
eksctl create cluster   \
    --name=eksdemo1     \
    --region=us-east-1  \
    --zones=us-east-1a,us-east-1b   \
    --without-nodegroup

# Once the EKS cluster is created you can view your EKS cluster from CLI
eksctl get clusters

# Later we will create K8 Service Accounts and Namespaces 
# to interact with these K8 Objects we will need to configure an OIDC provider
eksctl utils associate-iam-oidc-provider \
    --region us-east-1 \
    --cluster eksdemo1 \
    --approve

# When we create our NodeGroup, this will be EC2 hosts as our Worker Nodes
# We will need to authenticate to the worker nodes with a KeyPair
aws ec2 create-key-pair --key-name eksdemo1

# Results in: 
#{
#    "KeyFingerprint": "0e:d5:f6:e7:c0:28:c9:2e:1b:f0:7f:42:28:c7:c2:ff:85:49:cd:4a",
#    "KeyMaterial": "-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEAvtIQibUepWY97+nJoisQLZ4kgLeDJ2oGqf7UVSP2thxVtJz0\nRGcNUzqJ54b9JJhus5Ce9sEEDk/OIytI7gNdVOq9JlUf2Mpx986BfOnZ4xUJ7kbY\nCYljTopOiw3LTxLNiq5ym3DQO2gq5PznKoHHc3Xb3GKpkqW082agLbNMbTEEkoAg\n80sHiTQD9yGmWni/hZdo/s0Yqhi+a1mYUznRFFh3TiLfvL52n8Xp4L1g3KGhNZ53\nzr71OvggvWxDu7wKbkqxajvZAspK+g+HH+ZFuQylI+faEWdKnFXP4cgBmQa0F/dw\nKaGMKtDhD5bfshUaSu4xMfsSDMpkkzRW91vXnQIDAQABAoIBAEoC2e0/dap7VGyY\nRd+DSlwXKVtPUixYYEtRDnQTZd5OcSODeO6K9c0hOFm3rrmh8dXtsupMBNG0PGTB\npiDC51FHVqPmglqocrnFu82COkNsZpSnn6VbR0wwMrSWXhPGXDh83vDROcLA7Vox\niUugWIa84NDC57h8UwnQ9TGkiHEU1NcwNY8pIwPdlWbw8zX7cxguV2j5+f2cppDO\nDZZ5ow0C7XxbUdE40oBOYvpuvAQ1zsxZVb6KiXopw1Wyd3eOYLHJ+4i30gkV1z45\n6OVPhZwmYFrDZOGZJV+bRKB43X0aFosY+fEe2cjrpDoi/5a5nUjPFzIRC8tq0SaW\nCBd/XvUCgYEA8sQoGlKmLoiCTIuUP4PXGg+1OWYl446mRLVfYqU/VnLr4sbeEavm\nLdbvHvurl4IS3UYjfmHIvpDYPE3/p6xYmOQtKnPHo5ySlxl95iOqp4LxbMoYk6cE\nNH+nPHhnQlUQZXNAK56cxWDKERj380+sbTnzGVuzLvHJ3rTRXw2Q9PsCgYEAyTj/\nV2UV/F9tkm7xW140D43mI1D49Kz/9spn10RMi0L8lVdfQAvX1XpdhbUabFEFor/P\n36eX79EOtLFu1Wzr2wDl/caXjQo1UpGMc3YR9Eh/GeyexADrzaRijlae0P261InK\nUnNNlQy+er44QqB+7u2BmqZ9kWxfCRUXcAb20kcCgYB5rXesOeCxUhp84zja3Onj\nVhwvONOkysrrhTzZ5Jlqaw9wCt0jXlVwhFo13U6UEc4CujTwE3LakR7QmweYsvl1\nKGi67m0RxFh1A4Hm59mRPEBllqXa28tvxMu9s1uOE7S0JJ/1PPq2s1yUVT9x5G04\nEeOWwi99SBM2XMrUKaiOIQKBgBIAZl+ELJZaVywdfrwkzlWB5U/Ng6gn/fIvI2EP\nvCVNRdl6aowJQzLW8pzumcGM8gsgS9F/ZclPk5g4s2imiOcbyneMl6xHeIO9f6oo\nquyGu9Au6fkw9+d6yFJhj2209UzkUtRTemJWNIg4kkHrp89qMgkK0fr7jfj7CRC9\nnsErAoGBAICrlm7e97XunNPPm8gzFSTvFoRdJkk2xd4TV8K5JzvnEhnvguB5A4EZ\n0lypExSIyhxzBDHfugHo6uIEfdD66N1/ABLtRDnVYj0Xl6J3Pc1nj6D0jCDxD2ay\nagNyYsHlIdAbHRYgGDneXgjE78RqdI6DYvjNme279GGigsS5Paow\n-----END RSA PRIVATE KEY-----",
#    "KeyName": "eksdemo1",
#    "KeyPairId": "key-07cea0bb16b59148a"
#}

# Note the above format for the RSA Key includes the escape character \n which is a line break 
# You must format the line breaks as needed and remove the "\n" escape characters or you will throw an "invalid format" error.
# Save the correctly formatted file in order for the .pem key to work in the ssh request to the EC2


# To create a NodeGroup in a public subnet we can configure with the following command. Note the add-ons used here are providing IAM access roles
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

# To verify node creation we can stdout to our terminal screen the node details 
kubectl get nodes -o wide

# To ssh into the EC2 host once created you need to execute the following commands
# Nav to the location of the .pem file. Mine is on the Desktop, in a dir hierarchy noted below, you will have to specify your own path
cd ~/Desktop/k8_cluster_demo/AWS

# change the file permissions of the file to read-only
chmod 400 eksdemo1.pem

# Utilize the RSA key in the .pem file to ssh to the box
ssh -i "eksdemo1.pem" ec2-user@3.85.162.7

# In a sepearte terminal window do the same thing to the 2nd EC2 host
ssh -i "eksdemo1.pem" ec2-user@44.200.14.66

# To delete the EKS Cluster execute the following commands: 
eksctl delete cluster eksdemo1


