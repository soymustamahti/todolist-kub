#!/bin/bash

# Kubernetes Cluster Setup Script with .env support
# This script automates the setup of a Kubernetes cluster using Ansible with .env file support

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Load environment variables from .env file
load_env_file() {
    local env_file=".env"
    
    if [[ -f "$env_file" ]]; then
        print_status "Loading environment variables from $env_file..."
        
        # Export variables from .env file
        set -a  # Automatically export all variables
        source "$env_file"
        set +a  # Stop auto-export
        
        print_success "Environment variables loaded from $env_file"
    else
        print_warning ".env file not found. You can create one from .env.example"
        print_status "Using environment variables or command line parameters"
    fi
}

# Check if Ansible is installed
check_ansible() {
    print_status "Checking if Ansible is installed..."
    if ! command -v ansible &> /dev/null; then
        print_error "Ansible is not installed. Please install Ansible first."
        print_status "On Ubuntu/Debian: sudo apt update && sudo apt install ansible sshpass"
        print_status "On CentOS/RHEL: sudo yum install ansible sshpass"
        print_status "On macOS: brew install ansible hudochenkov/sshpass/sshpass"
        exit 1
    fi
    
    # Check if sshpass is installed for password authentication
    if ! command -v sshpass &> /dev/null; then
        print_warning "sshpass is not installed. Installing it for password authentication..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y sshpass
            elif command -v yum &> /dev/null; then
                sudo yum install -y sshpass
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y sshpass
            else
                print_error "Cannot install sshpass automatically. Please install it manually."
                exit 1
            fi
        else
            print_error "Please install sshpass manually for your operating system."
            exit 1
        fi
    fi
    
    print_success "Ansible and sshpass are installed"
}

# Validate environment variables
validate_env_vars() {
    print_status "Validating environment variables..."
    
    local missing_vars=()
    
    # Check required IP addresses
    [[ -z "$MASTER_IP" ]] && missing_vars+=("MASTER_IP")
    [[ -z "$WORKER1_IP" ]] && missing_vars+=("WORKER1_IP")
    [[ -z "$WORKER2_IP" ]] && missing_vars+=("WORKER2_IP")
    
    # Check passwords
    if [[ -z "$VM_PASSWORD" && -z "$MASTER_PASSWORD" ]]; then
        missing_vars+=("VM_PASSWORD or MASTER_PASSWORD")
    fi
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        print_error "Missing required environment variables:"
        for var in "${missing_vars[@]}"; do
            echo "  - $var"
        done
        print_status ""
        print_status "Please either:"
        print_status "1. Create a .env file from .env.example and fill in your values"
        print_status "2. Export the environment variables manually:"
        print_status "   export MASTER_IP=your_master_ip"
        print_status "   export WORKER1_IP=your_worker1_ip"
        print_status "   export WORKER2_IP=your_worker2_ip"
        print_status "   export VM_PASSWORD=your_password"
        exit 1
    fi
    
    print_success "All required environment variables are set"
    
    # Show configuration summary
    print_status "Configuration Summary:"
    echo "  Master Node: $MASTER_IP"
    echo "  Worker 1: $WORKER1_IP"
    echo "  Worker 2: $WORKER2_IP"
    echo "  User: ${ANSIBLE_USER:-ubuntu}"
    echo "  Kubernetes Version: ${KUBERNETES_VERSION:-1.28.2}"
}

# Check inventory configuration
check_inventory() {
    print_status "Creating dynamic inventory with environment variables..."
    
    # Create a temporary inventory file with actual values
    export INVENTORY_FILE="/tmp/inventory-dynamic.yml"
    
    # Use individual passwords if set, otherwise fall back to VM_PASSWORD
    local master_password="${MASTER_PASSWORD:-$VM_PASSWORD}"
    local worker1_password="${WORKER1_PASSWORD:-$VM_PASSWORD}"
    local worker2_password="${WORKER2_PASSWORD:-$VM_PASSWORD}"
    
    cat > "$INVENTORY_FILE" << EOF
[masters]
master-node ansible_host=$MASTER_IP ansible_user=$ANSIBLE_USER ansible_ssh_pass=$master_password ansible_become_pass=$master_password

[workers]
worker-1 ansible_host=$WORKER1_IP ansible_user=$ANSIBLE_USER ansible_ssh_pass=$worker1_password ansible_become_pass=$worker1_password
worker-2 ansible_host=$WORKER2_IP ansible_user=$ANSIBLE_USER ansible_ssh_pass=$worker2_password ansible_become_pass=$worker2_password

[k8s_cluster:children]
masters
workers

[k8s_cluster:vars]
# Common variables
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no'
ansible_host_key_checking=false
kubernetes_version=${KUBERNETES_VERSION:-1.28.2}
container_runtime=containerd
pod_network_cidr=${POD_NETWORK_CIDR:-10.244.0.0/16}
service_cidr=${SERVICE_CIDR:-10.96.0.0/12}

# Docker registry credentials
docker_registry_url=docker.io
docker_registry_username=${DOCKER_USERNAME:-YOUR_DOCKER_USERNAME}
docker_registry_password=${DOCKER_PASSWORD:-YOUR_DOCKER_PASSWORD}
EOF
    
    print_success "Dynamic inventory created at $INVENTORY_FILE"
}

# Test connectivity to all hosts
test_connectivity() {
    print_status "Testing connectivity to all hosts..."
    
    # Test with the dynamic inventory
    if ansible all -i "$INVENTORY_FILE" -m ping; then
        print_success "All hosts are reachable"
    else
        print_error "Some hosts are not reachable. Please check your configuration:"
        print_status "1. Verify IP addresses are correct"
        print_status "2. Verify passwords are correct"
        print_status "3. Ensure SSH is enabled on all VMs"
        print_status "4. Check if user has sudo privileges"
        exit 1
    fi
}

# Install required Ansible collections
install_ansible_collections() {
    print_status "Installing required Ansible collections..."
    ansible-galaxy collection install kubernetes.core
    ansible-galaxy collection install community.general
    print_success "Ansible collections installed"
}

# Run the main playbook
setup_kubernetes() {
    print_status "Setting up Kubernetes cluster..."
    ansible-playbook -i "$INVENTORY_FILE" infrastructure/ansible/playbook.yml
    print_success "Kubernetes cluster setup completed"
}

# Install tools (ArgoCD, Prometheus, Traefik)
install_tools() {
    print_status "Installing ArgoCD, Prometheus, and Traefik..."
    ansible-playbook -i "$INVENTORY_FILE" infrastructure/ansible/install-tools.yml
    print_success "Tools installation completed"
}

# Copy kubeconfig for local access
setup_local_kubeconfig() {
    print_status "Setting up local kubeconfig..."
    
    print_status "Copying kubeconfig from master node ($MASTER_IP)..."
    
    # Create .kube directory if it doesn't exist
    mkdir -p ~/.kube
    
    # Use sshpass for password authentication
    local master_password="${MASTER_PASSWORD:-$VM_PASSWORD}"
    local user="${ANSIBLE_USER:-ubuntu}"
    
    # Try to copy from user's home directory first, then from root
    if sshpass -p "$master_password" scp -o ConnectTimeout=10 -o StrictHostKeyChecking=no $user@$MASTER_IP:~/.kube/config ~/.kube/config-todo-cluster 2>/dev/null; then
        print_success "Kubeconfig copied from user directory"
    elif sshpass -p "$master_password" scp -o ConnectTimeout=10 -o StrictHostKeyChecking=no $user@$MASTER_IP:/etc/kubernetes/admin.conf ~/.kube/config-todo-cluster 2>/dev/null; then
        print_success "Kubeconfig copied from admin.conf"
    else
        print_error "Failed to copy kubeconfig. Trying manual setup..."
        print_status "Please manually copy the kubeconfig:"
        print_status "scp $user@$MASTER_IP:/etc/kubernetes/admin.conf ~/.kube/config-todo-cluster"
        return 1
    fi
    
    # Update server address in kubeconfig
    sed -i.bak "s|server: https://.*:6443|server: https://$MASTER_IP:6443|g" ~/.kube/config-todo-cluster
    
    print_success "Kubeconfig saved to ~/.kube/config-todo-cluster"
    print_status "To use this cluster, run: export KUBECONFIG=~/.kube/config-todo-cluster"
}

# Display cluster information
show_cluster_info() {
    print_success "Kubernetes cluster setup completed!"
    echo ""
    print_status "Cluster Information:"
    
    echo "🔧 Master Node: $MASTER_IP"
    echo "🎯 ArgoCD: http://$MASTER_IP:30080"
    echo "📊 Grafana: http://$MASTER_IP:30091 (admin/admin123)"
    echo "📈 Prometheus: http://$MASTER_IP:30090"
    echo "🚨 AlertManager: http://$MASTER_IP:30092"
    echo "🌐 Traefik Dashboard: http://$MASTER_IP:30080/dashboard/"
    echo ""
    print_status "Next steps:"
    echo "1. Set your kubeconfig: export KUBECONFIG=~/.kube/config-todo-cluster"
    echo "2. Deploy your application using ArgoCD or Helm"
    echo "3. Configure your domain to point to the cluster IP"
}

# Main execution
main() {
    print_status "Starting Kubernetes cluster setup with .env support..."
    
    load_env_file
    check_ansible
    validate_env_vars
    check_inventory
    install_ansible_collections
    test_connectivity
    setup_kubernetes
    install_tools
    setup_local_kubeconfig
    show_cluster_info
}

# Help function
show_help() {
    echo "Kubernetes Cluster Setup Script with .env support"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --check-only   Only check prerequisites and connectivity"
    echo "  --tools-only   Only install tools (ArgoCD, Prometheus, Traefik)"
    echo ""
    echo "Configuration:"
    echo ""
    echo "1. Create .env file from template:"
    echo "   cp .env.example .env"
    echo "   # Edit .env with your actual values"
    echo ""
    echo "2. Required variables in .env:"
    echo "   MASTER_IP=192.168.1.10"
    echo "   WORKER1_IP=192.168.1.11"
    echo "   WORKER2_IP=192.168.1.12"
    echo "   VM_PASSWORD=your_password"
    echo ""
    echo "3. Optional variables:"
    echo "   ANSIBLE_USER=ubuntu (default)"
    echo "   KUBERNETES_VERSION=1.28.2 (default)"
    echo "   DOCKER_USERNAME=your_docker_username"
    echo ""
    echo "Requirements:"
    echo "- All VMs must have SSH enabled"
    echo "- User must have sudo privileges on all VMs"
    echo "- sshpass must be installed for password authentication"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    --check-only)
        load_env_file
        check_ansible
        validate_env_vars
        check_inventory
        test_connectivity
        print_success "All prerequisites are met!"
        exit 0
        ;;
    --tools-only)
        load_env_file
        check_ansible
        validate_env_vars
        check_inventory
        install_ansible_collections
        install_tools
        exit 0
        ;;
    "")
        main
        ;;
    *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac
