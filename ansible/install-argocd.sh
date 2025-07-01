#!/bin/bash

echo "Installing ArgoCD using Helm..."

# Install Helm if not present
if ! command -v helm &> /dev/null; then
    echo "Installing Helm..."
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    sudo apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm --yes
fi

# Add ArgoCD Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Create argocd namespace
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --set server.service.type=NodePort \
  --set server.service.nodePortHttp=30080 \
  --set server.service.nodePortHttps=30443 \
  --set server.extraArgs[0]="--insecure" \
  --set configs.params."server\.insecure"=true \
  --set configs.secret.argocdServerAdminPassword='$2a$10$rRyBsGSHK6.uc8fntPwVIuLVHgsAhAX7TcdrqW/RADU0ufmhjQ5Ca' \
  --set redis-ha.enabled=false \
  --set controller.replicas=1 \
  --set server.replicas=1 \
  --set server.autoscaling.enabled=false \
  --set repoServer.replicas=1 \
  --set repoServer.autoscaling.enabled=false \
  --set applicationSet.replicas=1

echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo "ArgoCD installed successfully!"
echo ""
echo "Access ArgoCD:"
echo "- URL: http://$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}'):30080"
echo "- Username: admin"
echo "- Password: admin"
echo ""
echo "To get the initial admin password (if needed):"
echo "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
