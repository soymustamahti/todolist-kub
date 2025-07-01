#!/bin/bash

# Load environment variables
if [ -f ../.env ]; then
    export $(cat ../.env | grep -v '^#' | xargs)
fi

echo "Starting Kubernetes cluster setup with Ansible..."
echo "Master node: $MASTER_IP"
echo "Worker nodes: $WORKER1_IP, $WORKER2_IP"

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "Ansible is not installed. Installing..."
    sudo apt update
    sudo apt install -y ansible
fi

# Test connectivity to all nodes
echo "Testing connectivity to all nodes..."
ansible all -m ping

if [ $? -eq 0 ]; then
    echo "All nodes are reachable. Starting cluster setup..."
    
    # Run the complete setup
    ansible-playbook site.yml
    
    if [ $? -eq 0 ]; then
        echo "Kubernetes cluster setup completed successfully!"
        echo ""
        echo "To verify the cluster status, run:"
        echo "ansible master -m shell -a 'kubectl get nodes'"
        echo ""
        echo "To get the cluster config, run:"
        echo "ansible master -m fetch -a 'src=/etc/kubernetes/admin.conf dest=./kubeconfig flat=yes'"
    else
        echo "Cluster setup failed. Please check the logs above."
        exit 1
    fi
else
    echo "Cannot reach all nodes. Please check:"
    echo "1. Network connectivity"
    echo "2. SSH access"
    echo "3. Credentials in inventory.ini"
    exit 1
fi
