#!/bin/bash

# Set Kubernetes Cluster Context to our cluster
echo "Setting Kubernetes Cluster Context to created cluster"
echo "--------------------------------------------------"
aws --region $(terraform output -raw region) eks update-kubeconfig --name $(terraform output -raw cluster_name)

# Test Cluster Context after setting
kubectl config current-context

# Connect to cluster to make sure it is up and running (check namespace and nodes)
echo "Connecting to cluster to make sure it is up and running (print namespace and nodes)"
echo "--------------------------------------------------"
kubectl get ns
echo "--------------------------------------------------"
kubectl get nodes

# All good if the kubectl commands run and show the output like above.

kubectl delete deploy node-deployment

kubectl delete services ingress-node

# Create application
echo "--------------------------------------------------"
echo "Creating application in cluster..."
kubectl apply -f node-k8.yaml 


# Check that pods and services are running
echo "--------------------------------------------------"
echo "Verifying that pods are running"
echo "--------------------------------------------------"
sleep 50

kubectl get pods

# Check service and obtain AWS load balancer URL listed under EXTERNAL-IP
kubectl get services


# To Delete
# kubectl delete deploy node-app

# kubectl delete services ingress-node-app