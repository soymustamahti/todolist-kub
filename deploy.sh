#!/bin/bash

# ToDo List Kubernetes Deployment Script
# This script automates the complete setup of the Kubernetes cluster and application

set -e

echo "🚀 Starting Kubernetes cluster deployment..."
echo "============================================"

# Check if Ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo "❌ Ansible is not installed. Please install Ansible first."
    echo "   Ubuntu/Debian: sudo apt update && sudo apt install ansible"
    echo "   CentOS/RHEL: sudo yum install ansible"
    echo "   macOS: brew install ansible"
    exit 1
fi

# Check if inventory file exists
if [ ! -f "inventory.ini" ]; then
    echo "❌ inventory.ini file not found!"
    echo "   Please create the inventory file with your VM IPs."
    exit 1
fi

# Verify connectivity to all hosts
echo "🔍 Checking connectivity to all hosts..."
if ! ansible all -m ping; then
    echo "❌ Cannot connect to one or more hosts!"
    echo "   Please check your SSH credentials and network connectivity."
    exit 1
fi

echo "✅ All hosts are reachable!"

# Run the main playbook
echo ""
echo "📦 Running Ansible playbook..."
echo "This will take approximately 10-15 minutes..."
echo ""

ansible-playbook setup.yml

echo ""
echo "🎉 Deployment completed successfully!"
echo "============================================"
echo ""
echo "Your Kubernetes cluster is ready with the following components:"
echo "• Docker (container runtime)"
echo "• Kubernetes 1.28 (1 master + 2 workers)"
echo "• Traefik (Ingress Controller)"
echo "• Prometheus + Grafana (Monitoring)"
echo "• ArgoCD (GitOps)"
echo "• ToDo List Application"
echo ""
echo "🌐 Access URLs:"
echo "• ToDo App: http://167.71.35.144:30080"
echo "• ArgoCD: http://167.71.35.144:30092"
echo "• Prometheus: http://167.71.35.144:30090"
echo "• Grafana: http://167.71.35.144:30091"
echo ""
echo "🔑 To get ArgoCD admin password:"
echo "ssh root@167.71.35.144 'kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d'"
echo ""
echo "📚 Next steps:"
echo "1. Access the ToDo app in your browser"
echo "2. Set up ArgoCD application for GitOps"
echo "3. Configure monitoring dashboards in Grafana"
echo ""
echo "Happy Kubernetes-ing! 🎊"
