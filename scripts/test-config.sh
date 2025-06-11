#!/bin/bash

# Quick Test Script
# This script validates that your .env configuration is working

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Load .env file
if [[ -f ".env" ]]; then
    print_status "Loading .env file..."
    set -a
    source .env
    set +a
    print_success ".env file loaded"
else
    print_error ".env file not found!"
    print_status "Please create .env from .env.example"
    exit 1
fi

print_status "Validating configuration..."

# Check required variables
missing_vars=()
[[ -z "$MASTER_IP" ]] && missing_vars+=("MASTER_IP")
[[ -z "$WORKER1_IP" ]] && missing_vars+=("WORKER1_IP")
[[ -z "$WORKER2_IP" ]] && missing_vars+=("WORKER2_IP")
[[ -z "$VM_PASSWORD" ]] && missing_vars+=("VM_PASSWORD")

if [[ ${#missing_vars[@]} -gt 0 ]]; then
    print_error "Missing required variables:"
    for var in "${missing_vars[@]}"; do
        echo "  - $var"
    done
    exit 1
fi

print_success "All required variables are present"

# Show configuration summary
echo ""
print_status "Configuration Summary:"
echo "📡 Master Node:  $MASTER_IP"
echo "👷 Worker 1:     $WORKER1_IP"
echo "👷 Worker 2:     $WORKER2_IP"
echo "👤 User:         ${ANSIBLE_USER:-ubuntu}"
echo "🐳 Docker User:  ${DOCKER_USERNAME:-Not set}"
echo "🔧 K8s Version:  ${KUBERNETES_VERSION:-1.28.2}"

echo ""
print_status "Testing connectivity..."

# Test SSH connectivity
for ip in "$MASTER_IP" "$WORKER1_IP" "$WORKER2_IP"; do
    if sshpass -p "${VM_PASSWORD}" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "${ANSIBLE_USER:-ubuntu}@${ip}" "echo 'Connection successful'" &>/dev/null; then
        print_success "✅ $ip - Connection OK"
    else
        print_error "❌ $ip - Connection failed"
    fi
done

echo ""
print_success "Configuration test completed!"
print_status "You can now run:"
echo "  ./scripts/setup-cluster.sh     # Setup Kubernetes cluster"
echo "  ./scripts/deploy-app.sh        # Deploy application"
