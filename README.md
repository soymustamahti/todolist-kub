# ToDo List Kubernetes Application

This project sets up a complete Kubernetes infrastructure on 3 DigitalOcean VMs with a ToDo List application.

## 🚀 Quick Start

### Prerequisites
- Ansible installed on your local machine
- SSH access to the 3 VMs
- Docker Hub account (for image registry)

### Infrastructure Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/soymustamahti/todolist-kub.git
   cd todolist-kub
   ```

2. **Update inventory.ini with your VM IPs (if different):**
   ```ini
   [master]
   k8s-master ansible_host=167.71.35.144

   [workers]
   k8s-worker1 ansible_host=164.92.168.187
   k8s-worker2 ansible_host=167.172.99.233
   ```

3. **Run the Ansible playbook:**
   ```bash
   ansible-playbook -i inventory.ini setup.yml
   ```

This single command will:
- Install Docker on all nodes
- Install Kubernetes components (kubeadm, kubelet, kubectl)
- Initialize the master node
- Join worker nodes to the cluster
- Install Traefik (Ingress Controller)
- Install Prometheus (Monitoring)
- Install ArgoCD (GitOps)

### Application Deployment

After the infrastructure is ready, deploy the ToDo app:

```bash
# Apply the ArgoCD application (from master node)
kubectl apply -f k8s-manifests/argo-app.yaml
```

## 🏗️ Architecture

### Infrastructure Components
- **3 VMs**: 1 Master + 2 Workers
- **Container Runtime**: Docker
- **Orchestration**: Kubernetes 1.28
- **Ingress**: Traefik
- **Monitoring**: Prometheus + Grafana
- **GitOps**: ArgoCD

### Application Stack
- **Frontend**: HTML + CSS + JavaScript
- **Backend**: Express.js (Node.js)
- **Database**: PostgreSQL
- **Container Registry**: Docker Hub

## 🌐 Access URLs

After deployment, access the services:

- **ToDo App**: http://167.71.35.144:30080 or http://todoapp.167.71.35.144.nip.io:30080
- **ArgoCD**: http://167.71.35.144:30092 (admin/[get password from cluster])
- **Prometheus**: http://167.71.35.144:30090
- **Grafana**: http://167.71.35.144:30091

### Get ArgoCD Admin Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## 🔄 CI/CD Pipeline

The GitHub Actions workflow automatically:
1. Builds Docker image on push to `main`
2. Pushes to Docker Hub
3. Updates Kubernetes manifests with new image tag
4. ArgoCD automatically syncs changes

### Required Secrets
Add these to your GitHub repository secrets:
- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub password

## 📁 Project Structure

```
├── inventory.ini           # Ansible inventory
├── setup.yml              # Main Ansible playbook
├── roles/                  # Ansible roles
│   ├── common/            # Basic system setup
│   ├── docker/            # Docker installation
│   ├── kubernetes/        # K8s components
│   ├── master/            # Master node setup
│   ├── workers/           # Worker nodes join
│   ├── traefik/           # Ingress controller
│   ├── prometheus/        # Monitoring
│   └── argocd/            # GitOps
├── app/                   # ToDo application
│   ├── src/server.js      # Express.js backend
│   ├── public/index.html  # Frontend
│   ├── Dockerfile         # Container image
│   └── package.json       # Dependencies
├── k8s-manifests/         # Kubernetes YAMLs
│   ├── app.yaml           # App deployment
│   ├── db.yaml            # PostgreSQL
│   ├── ingress.yaml       # Traefik ingress
│   └── argo-app.yaml      # ArgoCD application
└── .github/workflows/     # CI/CD pipeline
    └── deploy.yml         # GitHub Actions
```

## 🛠️ Local Development

For local development:

```bash
cd app
npm install
docker-compose up -d
npm run dev
```

## 📊 Monitoring

- **Prometheus**: Metrics collection
- **Grafana**: Visualization dashboards
- **Default credentials**: admin/prom-operator

## 🔧 Troubleshooting

### Check Cluster Status
```bash
kubectl get nodes
kubectl get pods -A
```

### Check ArgoCD Apps
```bash
kubectl get applications -n argocd
```

### View Pod Logs
```bash
kubectl logs -n todoapp deployment/todoapp
kubectl logs -n todoapp deployment/postgres
```

### Reset Cluster (if needed)
```bash
kubeadm reset
# Then re-run the Ansible playbook
```

## 🎯 Features

- ✅ **Full Infrastructure Automation**: One command setup
- ✅ **High Availability**: Multi-node cluster
- ✅ **Auto-scaling**: Kubernetes HPA ready
- ✅ **Monitoring**: Prometheus + Grafana
- ✅ **GitOps**: ArgoCD automated deployments
- ✅ **Security**: Non-root containers, secrets management
- ✅ **Persistent Storage**: PostgreSQL data persistence
- ✅ **Load Balancing**: Traefik ingress
- ✅ **CI/CD**: GitHub Actions pipeline

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
