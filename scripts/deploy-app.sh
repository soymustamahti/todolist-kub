#!/bin/bash

# Application Deployment Script with .env support
# This script deploys the Todo application to Kubernetes using Helm

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
        print_status "Using environment variables or manual configuration"
    fi
}

# Configuration variables
NAMESPACE="todo-app"
RELEASE_NAME="todo-app"
CHART_PATH="k8s/helm-charts/todo-app"
DOCKER_USERNAME="${DOCKER_USERNAME:-YOUR_DOCKER_USERNAME}"

# Check if kubectl is available and configured
check_kubectl() {
    print_status "Checking kubectl configuration..."
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        print_error "kubectl is not configured or cluster is not accessible"
        print_status "Make sure to set KUBECONFIG or configure kubectl properly"
        exit 1
    fi
    
    print_success "kubectl is configured and cluster is accessible"
}

# Check if Helm is available
check_helm() {
    print_status "Checking Helm installation..."
    if ! command -v helm &> /dev/null; then
        print_error "Helm is not installed. Please install Helm first."
        exit 1
    fi
    print_success "Helm is available"
}

# Add required Helm repositories
add_helm_repos() {
    print_status "Adding required Helm repositories..."
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
    print_success "Helm repositories added and updated"
}

# Build and push Docker images
build_and_push_images() {
    if [[ "$DOCKER_USERNAME" == "YOUR_DOCKER_USERNAME" ]]; then
        print_warning "DOCKER_USERNAME is not set. Skipping image build and push."
        print_status "Set DOCKER_USERNAME environment variable or add it to .env file"
        return 0
    fi
    
    print_status "Building and pushing Docker images..."
    print_status "Using Docker username: $DOCKER_USERNAME"
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    # Login to Docker registry if password is provided
    if [[ -n "$DOCKER_PASSWORD" ]]; then
        print_status "Logging into Docker registry..."
        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
        print_success "Logged into Docker registry"
    else
        print_warning "DOCKER_PASSWORD not set. Assuming already logged in."
    fi
    
    # Build backend image
    print_status "Building backend image..."
    docker build -t ${DOCKER_USERNAME}/todo-backend:latest -f app/apps/backend/Dockerfile app/
    
    # Build frontend image
    print_status "Building frontend image..."
    docker build -t ${DOCKER_USERNAME}/todo-frontend:latest -f app/apps/frontend/Dockerfile app/
    
    # Push images
    print_status "Pushing images to registry..."
    docker push ${DOCKER_USERNAME}/todo-backend:latest
    docker push ${DOCKER_USERNAME}/todo-frontend:latest
    
    print_success "Docker images built and pushed successfully"
}

# Install or upgrade the application
deploy_application() {
    print_status "Deploying Todo application..."
    
    # Create namespace if it doesn't exist
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    
    # Prepare Helm values
    local helm_args=(
        --namespace $NAMESPACE
        --create-namespace
        --wait
        --timeout=10m
    )
    
    # Add image configuration if Docker username is set
    if [[ "$DOCKER_USERNAME" != "YOUR_DOCKER_USERNAME" ]]; then
        helm_args+=(
            --set frontend.image.repository=${DOCKER_USERNAME}/todo-frontend
            --set frontend.image.tag=latest
            --set backend.image.repository=${DOCKER_USERNAME}/todo-backend
            --set backend.image.tag=latest
        )
    fi
    
    # Deploy using Helm
    helm upgrade --install $RELEASE_NAME $CHART_PATH "${helm_args[@]}"
    
    print_success "Application deployed successfully"
}

# Wait for deployment to be ready
wait_for_deployment() {
    print_status "Waiting for deployments to be ready..."
    
    kubectl wait --for=condition=available --timeout=300s deployment/todo-app-frontend -n $NAMESPACE
    kubectl wait --for=condition=available --timeout=300s deployment/todo-app-backend -n $NAMESPACE
    
    print_success "All deployments are ready"
}

# Show deployment status
show_status() {
    print_status "Deployment Status:"
    echo ""
    
    # Show pods
    echo "📦 Pods:"
    kubectl get pods -n $NAMESPACE
    echo ""
    
    # Show services
    echo "🌐 Services:"
    kubectl get services -n $NAMESPACE
    echo ""
    
    # Show ingress
    echo "🚪 Ingress:"
    kubectl get ingress -n $NAMESPACE
    echo ""
    
    # Get service URLs
    print_status "Application URLs:"
    
    # Get cluster IP for services
    FRONTEND_PORT=$(kubectl get service todo-app-frontend -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "Not available")
    BACKEND_PORT=$(kubectl get service todo-app-backend -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "Not available")
    
    # Get node IP
    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}' 2>/dev/null)
    if [[ -z "$NODE_IP" ]]; then
        NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
    fi
    
    if [[ "$FRONTEND_PORT" != "Not available" ]]; then
        echo "🎨 Frontend: http://$NODE_IP:$FRONTEND_PORT"
    fi
    
    if [[ "$BACKEND_PORT" != "Not available" ]]; then
        echo "⚙️  Backend: http://$NODE_IP:$BACKEND_PORT"
    fi
    
    # Check if ingress is configured
    if kubectl get ingress todo-app-ingress -n $NAMESPACE &> /dev/null; then
        INGRESS_HOST=$(kubectl get ingress todo-app-ingress -n $NAMESPACE -o jsonpath='{.spec.rules[0].host}')
        echo "🌍 Ingress: http://$INGRESS_HOST (configure your DNS to point to $NODE_IP)"
    fi
}

# Setup ArgoCD application
setup_argocd() {
    print_status "Setting up ArgoCD application..."
    
    # Check if ArgoCD is installed
    if ! kubectl get namespace argocd &> /dev/null; then
        print_warning "ArgoCD namespace not found. ArgoCD might not be installed."
        return 0
    fi
    
    # Apply ArgoCD application manifest
    kubectl apply -f k8s/manifests/argocd-application.yaml
    
    print_success "ArgoCD application configured"
    print_status "Application will be automatically synced by ArgoCD"
}

# Cleanup function
cleanup() {
    print_status "Cleaning up Todo application..."
    
    # Delete Helm release
    helm uninstall $RELEASE_NAME -n $NAMESPACE 2>/dev/null || print_warning "Release not found"
    
    # Delete namespace
    kubectl delete namespace $NAMESPACE 2>/dev/null || print_warning "Namespace not found"
    
    print_success "Cleanup completed"
}

# Show help
show_help() {
    echo "Todo Application Deployment Script with .env support"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  --build-only        Only build and push Docker images"
    echo "  --deploy-only       Only deploy the application (skip image build)"
    echo "  --status            Show deployment status"
    echo "  --argocd            Setup ArgoCD application"
    echo "  --cleanup           Remove the application from cluster"
    echo ""
    echo "Configuration:"
    echo ""
    echo "1. The script automatically loads variables from .env file"
    echo "2. Required variables in .env for image build:"
    echo "   DOCKER_USERNAME=your_docker_username"
    echo "   DOCKER_PASSWORD=your_docker_password"
    echo ""
    echo "3. Required for deployment:"
    echo "   KUBECONFIG=~/.kube/config-todo-cluster (or similar)"
    echo ""
    echo "Examples:"
    echo "  $0                      # Full deployment (uses .env variables)"
    echo "  $0 --build-only         # Only build and push images"
    echo "  $0 --deploy-only        # Only deploy (skip image build)"
    echo "  $0 --status             # Check deployment status"
}

# Main deployment function
main() {
    print_status "Starting Todo application deployment..."
    
    load_env_file
    check_kubectl
    check_helm
    add_helm_repos
    build_and_push_images
    deploy_application
    wait_for_deployment
    show_status
    
    print_success "Todo application deployment completed!"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    --build-only)
        load_env_file
        check_kubectl
        build_and_push_images
        exit 0
        ;;
    --deploy-only)
        load_env_file
        check_kubectl
        check_helm
        add_helm_repos
        deploy_application
        wait_for_deployment
        show_status
        exit 0
        ;;
    --status)
        load_env_file
        check_kubectl
        show_status
        exit 0
        ;;
    --argocd)
        load_env_file
        check_kubectl
        setup_argocd
        exit 0
        ;;
    --cleanup)
        load_env_file
        check_kubectl
        cleanup
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
