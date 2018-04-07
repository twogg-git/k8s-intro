![header](https://raw.githubusercontent.com/twogg-git/k8s-intro/master/kubernetes_katacoda.png)


**Note:** To follow this tutorial we are going to use [Katacoda Single-Node-Cluster](https://www.katacoda.com/courses/kubernetes/launch-single-node-cluster) an online Kubernetes-Minikube playground. If you want to try this exercices locally, here is [Minikube](https://github.com/kubernetes/minikube/) setup link.

## Start a Kubernetes cluster with Minukube

We are going to use Minikube to deploy Kubernetes locally. It comes with support for a variety of hypervisors, including VirtualBox, VMware Fusion, KVM, and xhyve, and OSs, including OSX, Windows, and Linux.

The Minikube CLI can be used to start, stop, delete, obtain status, and perform other actions on the virtual machine. 

```sh
# First start a virtual machine with Minikube in your terminal, then a Kubernetes cluster will be runnig in that VM.
minikube start

# With Kubernetes we have a running master and a dashboard. The dashboard allows you to view your applications in a UI. 
minikube dashboard
```

## Kubectl basics commands

Kubectl is the native CLI for Kubernetes, it performs actions on the Kubernetes cluster once the Minikube virtual machine has been started.

```sh
# cluster-info will display addresses of the master and services with label kubernetes.io/cluster-service=true 
kubectl cluster-info

# To further debug and diagnose cluster problems use
kubectl cluster-info dump

# To show all nodes on that cluster use, (only "Status Ready" nodes will accept applications for deployment)
kubectl get nodes

# Outputs the most important information about all the resources available
kubectl get all 
```

## Kubernetes Deployment Commands 

Now, we are going to practice deployment and managemnt commnands with a [Golang app image](https://hub.docker.com/r/twogghub/k8s-intro/) stored in Docker Hub.

```sh
kubectl run twogg --image=twogghub/k8s-intro:1.4-k8s
```

The run command creates a new deployment. Here we include the deployment name, and app image location (include the full repository url for images hosted outside Docker hub).

This command performed a few things for you:
- Searched for a suitable node where an instance of the application could be run (we have only 1 available node)
- Scheduled the application to run on that Node
- Configured the cluster to reschedule the instance on a new Node when needed

```sh
kubectl get deployments
```
In this case, there is 1 deployment running a single instance of *twogg*. (The instance is running inside a Docker container on that node). Pods that are running inside Kubernetes are running on a private, isolated network. By default they are visible from other pods and services within the same kubernetes cluster, but not outside that network. When we use kubectl, we're interacting through an API endpoint to communicate with our application.

**Cluster Ip Exposure**

The following are the exposure types that Kubernetes provides for your applications:
- ClusterIp: Expose service through k8s cluster** with ip/name:port
- NodePort: Expose service through vm's also external to k8s ip/name:port
- LoadBalancer: Expose service to external connections or whatever you defined in your load balancer setup.

```sh
kubectl expose deployment twogg --port=8080 --external-ip=$(minikube ip) --type=LoadBalancer
```
Now, we are going to deploy a service named **twogg** accesible by the port **8080**, and expose an IP to access it outside the cluster. Also we need to optain and set an external ip from nimukube.

## Kubernetes Deployment Commands 

```sh
#
kubectl get services

kubectl get pods

kubectl get pods,services --output wide

kubectl describe service twog

kubectl set image deployment twogg twogg=twogghub/k8s-intro:1.5-k8s

kubectl scale --replicas=3 deployment twogg

kubectl get pods --output wide --watch

kubectl get pods --output wide 

kubectl delete pod <pod-id>

# Get detailed deployment info 
kubectl get deployment <deploy-name> --output wide

# Review a pod's logs
kubectl logs <pod-id>

# Get pod's info output in a yaml file
kubectl get pod <pod-id> --output=yaml

# To interac inside the pod
kubectl exec -ti <pod-id> /bin/bash
```

## Kubectl Proxy

**Note:** Please, try this commands locally Katacoda Kubernetes playground does not support a cloud Kubernetes proxy. 

This kubectl command create a proxy that will forward communications into the cluster-wide, private network. The proxy can be terminated by pressing control-C and won't show any output while its running. 

```sh
kubectl proxy
```

With the proxy running now we have a connection between our host and the Kubernetes cluster.
Hosted APIs now are available at: http://localhost:8001 
To get the version: http://localhost:8001/version

The API server will automatically create an endpoint for each pod, based on the pod name, that is also accessible through the proxy. 

```sh
# First we need to get the Pod name, and we'll store in the environment variable POD_NAME
export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')

# To output our pods name 
echo $POD_NAME
```

To make an HTTP request to the application running in that pod: http://localhost:8001/api/v1/proxy/namespaces/default/pods/$POD_NAME/

## Cleaning up your cluster

Every pod is generated based on its deployment file, every time you delete a pod, it comes up again because you 
defined the value 'replicas: X' in the deployment file, to delete a Pod/s permanently, You will have to first delete the deployment of that pod and then delete the pod.

```sh
# To delete an specific pod  
kubectl delete pod <pod-id>

# This will delete the pod(s) permanently and the deployment itself will be deleted permanently 
kubectl delete deployment <deploy-name>

# You can alternatively, delete the deployment file from Kubernetes's UI as well
kubectl delete -f deployment_file_name.yml
```
