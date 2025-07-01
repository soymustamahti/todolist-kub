# Kubernetes Cluster Setup with Ansible

This directory contains Ansible playbooks to set up a Kubernetes cluster using kubeadm with one master node and two worker nodes.

## Prerequisites

- Ansible installed on your local machine
- SSH access to all VMs
- VMs running Ubuntu/Debian

## Configuration

The cluster configuration is defined in the `.env` file in the parent directory:

- **Master node**: 173.249.6.99
- **Worker node 1**: 141.98.153.138  
- **Worker node 2**: 141.98.153.135
- **Username**: root
- **Password**: qyVZG2FxF2fP3qMACYWaa

## Files

- `inventory.ini`: Ansible inventory with VM details
- `ansible.cfg`: Ansible configuration
- `setup-common.yml`: Common setup tasks for all nodes (Docker, kubeadm, etc.)
- `setup-master.yml`: Master node initialization
- `setup-workers.yml`: Worker nodes joining the cluster
- `site.yml`: Main playbook that runs all setups
- `setup-cluster.sh`: Convenience script to run everything

## Usage

### Quick Setup

Run the automated setup script:

```bash
cd ansible
./setup-cluster.sh
```

### Manual Setup

1. Test connectivity:
```bash
ansible all -m ping
```

2. Run the complete setup:
```bash
ansible-playbook site.yml
```

3. Verify cluster status:
```bash
ansible master -m shell -a 'kubectl get nodes'
```

4. Get kubeconfig file:
```bash
ansible master -m fetch -a 'src=/etc/kubernetes/admin.conf dest=./kubeconfig flat=yes'
```

## What the Setup Does

1. **Common Setup** (all nodes):
   - Updates system packages
   - Installs Docker/containerd
   - Installs kubeadm, kubelet, kubectl
   - Configures kernel modules and sysctl parameters
   - Disables swap

2. **Master Node**:
   - Initializes Kubernetes cluster with `kubeadm init`
   - Installs Flannel CNI for pod networking
   - Generates join command for worker nodes

3. **Worker Nodes**:
   - Joins the cluster using the generated join command

## Network Configuration

- **Pod CIDR**: 10.244.0.0/16 (Flannel)
- **Service CIDR**: 10.96.0.0/12
- **CNI**: Flannel

## Troubleshooting

- Check VM connectivity: `ansible all -m ping`
- Check cluster status: `ansible master -m shell -a 'kubectl get nodes'`
- View pods: `ansible master -m shell -a 'kubectl get pods -A'`
- Check logs: `ansible all -m shell -a 'journalctl -u kubelet -n 50'`
