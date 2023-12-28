# Kubernetes

## Architecture 

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/56736b17-7bea-4664-b843-03046cb8c34e">
</p>

- [ ] _kube apiserver_
> It acts as front-end for the K8 control plane. It exposes the K8 API. CLI Tools, Users, & even Master Node components, and Worker Node components all talk to the kube-apiserver. 

- [ ] _ectd_ 
> This is a consistent and hightly available key-value store used as the K8 backing store for all cluster data. It stores all information regarding the status of the master and worker nodes. 

- [ ] _kube-scheduler_
> Responsible for scheduling containers across multiple nodes. It watches for newly created Pods with no assigned node, and selects a node for them to run on. 

- [ ] _kube controller manager_ 
> Controllers are responsible for noticing and responding to when nodes, containers, or endpoints go down. They make decisions on bringing up new resources in this case. There are multiple controllers within the aggregated "controller manager" api: 
> 1. _Node Controller_ responsible for noticing when a node goes down. 
> 2. _Replication Controller_ responsible for maintaining the correct number of pods for every replication controller object in the system. 
> 3. _Endpoints Controller_ populates the Endpoints object, which joins services and pods. 
> 4. _Service Account & Token Controller_ creates a default namespace (aka account or folder) and API Access for new namespaces

- [ ] _cloud controller manager_ 
> A k8 control plane component that embeds cloud-specific control logic. It only runs controllers that are specific to the cloud provider. *On-Premise k8 clusters will not have a _cloud controller manager_.* This controller manager is also an aggregate of several other controllers: 
> 1. _Node Controller_ for checking the cloud provider to determine if a node has been deleted in the cloud after it stops responding. 
> 2. _Route Controller_ for setting up routes in the underlying cloud infrastructure
> 3. _Service Controller_ for creating, updating, and deleteing cloud provider for the load balancer

- [ ] _container runtime_
> Container runtime is the underlying software where we run all these kubernetes components. We are using Docker but we have other runtime options (_rkt_, _container d_, etc.)

- [ ] _kublet_
> Kubelet is the agent that runs on every node in the cluster (master & worker nodes). This agent is responsible for making sure that containers running on a pod in a node. 

- [ ] _kube proxy_
> It is a network proxy that runs on each node in your cluster. It maintains network rules on nodes. In short, these network rules allow network communication on your pods from the network sessions inside or outside of your cluster.

------

## EKS Architecture

So if the above is the "standard" Kubernetes architecture, what if any, changes are there to the EKS architecture? How does the EKS service accomodate this k8 architecture? 

<p align="center">
<img width="450" alt="image" src="https://github.com/gabrrodriguez/deloitte_SRE_repo/assets/126508932/ac3d8eaa-5568-46b5-8455-b17aa57a97c6">
</p> 

None of these aspects are ours to maange. AWS EKS will manage the control plane and the scaling of the worker nodes. 

--------

## K8 Fundamentals

### K8 Objects

Kubenetes is made up of a series of APIs that will interact act with K8 Objects used to deploy our applications. There are a *fundamental* set of Objects then there are *advanced* Objects. 

Here we will discuss the *fundamentals* defined as: 
- [ ] _pod_
> A single instance of an application. A _pod_ is the smallest unit of interaction in K8. 
- [ ] _replica set_
> A replica is an object that will maintain a stable set of pods running at any given time. It is used to _guarantee_ the availability of a specified number of identical pods. 
- [ ] _deployment_
> A deploymnet is an abstraction above a replicaset. A deployment will use a replica set to excercise its function. A deployment automatically replaces any instances that fail or are unresponsive. Rollout & Rollback changes are executed via deployments. Deployments are well suited for stateless applications. 
- [ ] _service_
> A service is an abstraction for pods providing a stable Virtual IP address. In simple terms a service is a Load Balancer. 

---------

### Object deployment approaches

There are 2 ways to deploy objects in a K8 cluster. 
1. _Imperative_
2. _Declarative_

The difference is simply the method you invoke an Object. An imperative declaration will be via the CLI or an interface of somekind. This is a single point in time change executed manually for the most part. These types of changes are strongly *DISCOURAGED* as you can create drift within the stack. 

The alternative is a declarative approach which uses some form of file type and syntax to document a declarative state of the changes invoked on the k8 cluster. This is the *Preferred* method of invoking changes on a K8 cluster. 

---------



