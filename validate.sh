#!/bin/bash

# Cluster Validation Script
# Checks if all components are running correctly

echo "🔍 Validating Kubernetes cluster..."
echo "===================================="

# Check if we can connect to the master node
MASTER_IP="167.71.35.144"
if ! ssh -o ConnectTimeout=5 root@$MASTER_IP "echo 'Connected successfully'" &>/dev/null; then
    echo "❌ Cannot connect to master node at $MASTER_IP"
    exit 1
fi

echo "✅ Connected to master node"

# Check cluster status
echo ""
echo "📊 Cluster Status:"
ssh root@$MASTER_IP "kubectl get nodes"

echo ""
echo "🔧 System Pods:"
ssh root@$MASTER_IP "kubectl get pods -n kube-system"

echo ""
echo "📦 Application Pods:"
ssh root@$MASTER_IP "kubectl get pods -n todoapp"

echo ""
echo "🌐 Services:"
ssh root@$MASTER_IP "kubectl get svc -n todoapp"

echo ""
echo "📊 Ingress:"
ssh root@$MASTER_IP "kubectl get ingress -n todoapp"

echo ""
echo "🎯 ArgoCD:"
ssh root@$MASTER_IP "kubectl get pods -n argocd | grep argocd-server"

echo ""
echo "📈 Monitoring:"
ssh root@$MASTER_IP "kubectl get pods -n monitoring | head -5"

echo ""
echo "🚦 Traefik:"
ssh root@$MASTER_IP "kubectl get pods -n traefik"

echo ""
echo "🔑 ArgoCD Admin Password:"
ssh root@$MASTER_IP "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo"

echo ""
echo "🌐 Access URLs:"
echo "• ToDo App: http://$MASTER_IP:30080"
echo "• ArgoCD: http://$MASTER_IP:30092"
echo "• Prometheus: http://$MASTER_IP:30090"
echo "• Grafana: http://$MASTER_IP:30091"

echo ""
echo "🧪 Testing ToDo App Health:"
if curl -s -o /dev/null -w "%{http_code}" http://$MASTER_IP:30080/health | grep -q "200"; then
    echo "✅ ToDo app is responding correctly"
else
    echo "⚠️  ToDo app health check failed - it may still be starting up"
fi

echo ""
echo "Validation complete! 🎉"
