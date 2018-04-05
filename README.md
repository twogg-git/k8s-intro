![header](https://raw.githubusercontent.com/twogg-git/k8s-intro/master/kubernetes_katacoda.png)


**Note:** To follow this tutorial we are going to use [Katacoda Single-Node-Cluster](https://www.katacoda.com/courses/kubernetes/launch-single-node-cluster) a minikube cloud provider. If you want to try this exercices locally, here is [Minikube setup](https://github.com/kubernetes/minikube/) link.

## Kubernetes basics commands

```sh
minikube start
```
Start the cluster with start command, now have a running Kubernetes cluster in your terminal. Minikube just started a virtual machine, and a Kubernetes cluster is now running in that VM.

```sh
kubectl cluster-info
```
Kubernetes command line interface, kubectl, 
With Kubernetes we have a running master and a dashboard. The dashboard allows you to view your applications in a UI. 

```sh
kubectl get nodes
```
This command shows all nodes that can be used to host our applications.
Status Ready: this node it is ready to accept applications for deployment.

```sh
kubectl get all 
```
List your deployments. 


```sh
kubectl delete pod <pod-id>
```
**Note:** Every pod is generated based on its deployment file. Hence, every time you delete a pod, it comes up again because you defined the value 'replicas: X' in the deployment file. 

```sh
kubectl delete deployment <deploy-name>
```
To delete a Pod/s permanently, You will have to first delete the deployment of that pod and then delete the pod. This will delete the pod permanently. And of course, the deployment itself will be deleted permanently. 


And sure you can alternatively, delete the deployment file from Kubernetes's UI as well.
```sh
kubectl delete -f deployment_file_name.yml
```


## Kubernetes Deployment Commands 
Now, we are going to practice deployment and managemnt commnands of a [Golang app image](https://hub.docker.com/r/twogghub/k8s-intro/) stored in Docker Hub.


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


```sh
kubectl expose deployment twogg --port=8080 --external-ip=$(minikube ip) --type=LoadBalancer
```

```sh
kubectl get services
```

```sh
kubectl get pods
```

```sh
kubectl get pods,services --output wide
```

```sh
kubectl describe service twog
```

```sh
kubectl set image deployment twogg twogg=twogghub/k8s-intro:1.5-k8s
```

```sh
kubectl scale --replicas=3 deployment twogg
```

```sh
kubectl get pods --output wide --watch
```

```sh
kubectl get pods --output wide 
```

```sh
kubectl delete pod <pod-id>
```

```sh
kubectl get deployment twogg --output wide
```

```sh
kubectl logs <pod-id>
```

```sh
kubectl get pod <pod-id> --output=yaml
```

```sh
kubectl exec -ti <pod-id>  /bin/bash
```


## Kubectl Proxy

**Note:** Please try this commands locally, Katacoda Kubernetes playground does not support a cloud Kubernetes proxy. 

```sh
kubectl proxy
```
This kubectl command create a proxy that will forward communications into the cluster-wide, private network. The proxy can be terminated by pressing control-C and won't show any output while its running. 

With the proxy running now have a connection between our host and the Kubernetes cluster. The proxy enables direct access to the API from these terminals. Kubernetes hosted APIs now are available at: http://localhost:8001. 

To get the version: http://localhost:8001/version

## Pod API
The API server will automatically create an endpoint for each pod, based on the pod name, that is also accessible through the proxy. First we need to get the Pod name, and we'll store in the environment variable POD_NAME:
```sh
export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
```
```sh
echo $POD_NAME
```

Now we can make an HTTP request to the application running in that pod:
http://localhost:8001/api/v1/proxy/namespaces/default/pods/$POD_NAME/


