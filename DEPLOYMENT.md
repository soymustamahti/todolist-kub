# 🚀 Todo App Kubernetes Deployment Guide

This guide will help you deploy your Todo application to Kubernetes with automatic CI/CD.

## 📋 Prerequisites

- 3 Ubuntu VMs (20.04 or later)
- Docker Hub account: `soymustael`
- GitHub repository: `https://github.com/soymustamahti/todolist-kub`

## 🔧 Step 1: Setup Kubernetes Cluster

### On Master Node (173.249.6.99):
```bash
# SSH to master node
ssh root@173.249.6.99

# Download and run setup script
curl -fsSL https://raw.githubusercontent.com/soymustamahti/todolist-kub/main/setup-k8s-master.sh -o setup-k8s-master.sh
chmod +x setup-k8s-master.sh
./setup-k8s-master.sh
```

### On Worker Nodes (141.98.153.138 & 141.98.153.135):
```bash
# SSH to each worker node
ssh root@141.98.153.138
ssh root@141.98.153.135

# On each worker node:
curl -fsSL https://raw.githubusercontent.com/soymustamahti/todolist-kub/main/setup-k8s-worker.sh -o setup-k8s-worker.sh
chmod +x setup-k8s-worker.sh
./setup-k8s-worker.sh

# Run the join command provided by master node
sudo kubeadm join 173.249.6.99:6443 --token <token> --discovery-token-ca-cert-hash <hash>
```

## 🔐 Step 2: Configure GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:

### Required Secrets:
```
DOCKER_USERNAME: soymustael
DOCKER_PASSWORD: <your-docker-hub-password>
KUBE_CONFIG: <base64-encoded-kubeconfig-file>
```

### Get kubeconfig for GitHub:
```bash
# On master node, encode kubeconfig
cat ~/.kube/config | base64 -w 0
# Copy this output to KUBE_CONFIG secret
```

## ⚙️ Step 3: Setup Application Secrets

### On Master Node:
```bash
# Clone your repository
git clone https://github.com/soymustamahti/todolist-kub.git
cd todolist-kub

# Generate and apply secrets
./setup-secrets.sh

# Apply secrets to cluster
kubectl apply -f k8s/secrets.yaml
```

## 🎯 Step 4: Initial Deployment

### Deploy application manually first time:
```bash
# Apply all Kubernetes manifests
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/postgres-pv.yaml
kubectl apply -f k8s/postgres-deployment.yaml

# Wait for postgres to be ready
kubectl wait --for=condition=ready pod -l app=postgres -n todo-app --timeout=300s

# Deploy backend and frontend
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/ingress.yaml

# Check deployment status
kubectl get pods -n todo-app
kubectl get services -n todo-app
```

## 📱 Step 5: Access Your Application

### Setup local access (on your machine):
```bash
# Add to /etc/hosts (Linux/Mac) or C:\Windows\System32\drivers\etc\hosts (Windows)
173.249.6.99 todo-app.local

# Get ingress controller port
kubectl get svc -n ingress-nginx

# Access application
curl http://todo-app.local:<NodePort>
```

## 🔄 Step 6: Automatic Deployment

Now your application will automatically deploy when you push to the `main` branch!

### Test the CI/CD:
```bash
# Make a change to your code
echo "// Updated" >> apps/frontend/src/App.tsx

# Commit and push
git add .
git commit -m "Test CI/CD deployment"
git push origin main

# Watch the deployment
kubectl get pods -n todo-app -w
```

## 🏥 Step 7: Health Checks

### Check application health:
```bash
# Check pods
kubectl get pods -n todo-app

# Check logs
kubectl logs -f deployment/backend-deployment -n todo-app
kubectl logs -f deployment/frontend-deployment -n todo-app

# Check database
kubectl exec -it deployment/postgres-deployment -n todo-app -- psql -U todouser -d todoapp -c "\dt"
```

## 🔧 Troubleshooting

### Common Issues:

1. **Pods not starting:**
   ```bash
   kubectl describe pod <pod-name> -n todo-app
   ```

2. **Database connection issues:**
   ```bash
   kubectl exec -it deployment/backend-deployment -n todo-app -- env | grep DATABASE
   ```

3. **Ingress not working:**
   ```bash
   kubectl get ingress -n todo-app
   kubectl describe ingress todo-ingress -n todo-app
   ```

4. **CI/CD failures:**
   - Check GitHub Actions logs
   - Verify secrets are set correctly
   - Ensure kubeconfig is valid

## 📊 Monitoring

### View application status:
```bash
# Get all resources
kubectl get all -n todo-app

# Check resource usage
kubectl top pods -n todo-app
kubectl top nodes

# View events
kubectl get events -n todo-app --sort-by='.lastTimestamp'
```

## 🛡️ Security Notes

- All sensitive data is stored in Kubernetes secrets
- Database passwords are automatically generated
- JWT secrets are randomly generated
- Application runs with non-root users
- Network policies can be added for additional security

## 🎉 Success!

Your Todo application is now:
- ✅ Running on Kubernetes
- ✅ Automatically deploying on code changes
- ✅ Using production-ready configuration
- ✅ Secured with proper secrets management
- ✅ Highly available with multiple replicas
