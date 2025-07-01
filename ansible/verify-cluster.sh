#!/bin/bash

echo "=== Kubernetes Cluster Status ==="
echo ""

echo "Cluster Nodes:"
ansible master -m shell -a "kubectl get nodes -o wide"
echo ""

echo "System Pods:"
ansible master -m shell -a "kubectl get pods -A"
echo ""

echo "Cluster Info:"
ansible master -m shell -a "kubectl cluster-info"
echo ""

echo "To use this cluster from your local machine:"
echo "export KUBECONFIG=$(pwd)/kubeconfig"
echo "kubectl get nodes"
echo ""
echo "Or copy the kubeconfig to your default location:"
echo "mkdir -p ~/.kube"
echo "cp kubeconfig ~/.kube/config"
