#!/bin/bash

# Cleanup script for EC2 Tomcat application
# This script destroys AWS infrastructure to avoid ongoing costs

set -e  # Exit on any error

# Configuration variables
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Terraform is installed
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Show current infrastructure
show_current_infrastructure() {
    log_info "Checking current infrastructure..."
    
    cd "$TERRAFORM_DIR"
    
    if [ ! -f "terraform.tfstate" ]; then
        log_warning "No Terraform state file found. No infrastructure to destroy."
        exit 0
    fi
    
    echo ""
    echo "🏗️  Current Infrastructure:"
    echo "=========================="
    
    # Get current resources
    terraform show -json | jq -r '.values.root_module.resources[]? | select(.type == "aws_instance") | "\(.values.instance_type) instance: \(.values.public_ip // "N/A")"' 2>/dev/null || true
    terraform show -json | jq -r '.values.root_module.resources[]? | select(.type == "aws_eip") | "Elastic IP: \(.values.public_ip)"' 2>/dev/null || true
    
    echo ""
    
    cd "$PROJECT_ROOT"
}

# Destroy infrastructure
destroy_infrastructure() {
    log_warning "This will destroy ALL AWS resources created by this project!"
    log_warning "This action CANNOT be undone!"
    
    echo ""
    echo "📋 Resources that will be destroyed:"
    echo "   - EC2 Instance"
    echo "   - Elastic IP"
    echo "   - Security Group"
    echo "   - VPC and networking components"
    echo "   - SSH Key Pair (in AWS)"
    echo ""
    
    read -p "Are you absolutely sure you want to destroy all resources? Type 'yes' to confirm: " -r
    
    if [[ $REPLY == "yes" ]]; then
        log_info "Proceeding with infrastructure destruction..."
        
        cd "$TERRAFORM_DIR"
        
        # Plan the destruction
        log_info "Planning destruction..."
        terraform plan -destroy -out=destroy-plan
        
        # Apply the destruction
        log_info "Destroying infrastructure..."
        terraform apply destroy-plan
        
        # Clean up plan file
        rm -f destroy-plan
        
        log_success "Infrastructure destroyed successfully!"
        
        cd "$PROJECT_ROOT"
    else
        log_info "Destruction cancelled by user"
        exit 0
    fi
}

# Clean up local files
cleanup_local_files() {
    log_info "Cleaning up local files..."
    
    cd "$TERRAFORM_DIR"
    
    # Remove Terraform state and backup files
    if [ -f "terraform.tfstate" ]; then
        log_info "Removing Terraform state files..."
        rm -f terraform.tfstate terraform.tfstate.backup
    fi
    
    # Remove Terraform lock file
    if [ -f ".terraform.lock.hcl" ]; then
        rm -f .terraform.lock.hcl
    fi
    
    # Remove Terraform directory
    if [ -d ".terraform" ]; then
        rm -rf .terraform
    fi
    
    # Remove terraform.tfvars (keep the example)
    if [ -f "terraform.tfvars" ]; then
        log_info "Removing terraform.tfvars..."
        rm -f terraform.tfvars
    fi
    
    cd "$PROJECT_ROOT"
    
    # Clean up build artifacts
    if [ -d "app/target" ]; then
        log_info "Cleaning up build artifacts..."
        rm -rf app/target
    fi
    
    log_success "Local cleanup completed"
}

# Optionally clean up SSH keys
cleanup_ssh_keys() {
    SSH_KEY_DIR="$HOME/.ssh"
    SSH_KEY_NAME="tomcat-app-key"
    PRIVATE_KEY_PATH="$SSH_KEY_DIR/$SSH_KEY_NAME"
    PUBLIC_KEY_PATH="$SSH_KEY_DIR/$SSH_KEY_NAME.pub"
    
    if [ -f "$PRIVATE_KEY_PATH" ] || [ -f "$PUBLIC_KEY_PATH" ]; then
        echo ""
        log_warning "SSH key pair found: $PRIVATE_KEY_PATH"
        read -p "Do you want to delete the SSH key pair as well? (y/N): " -r
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -f "$PRIVATE_KEY_PATH" "$PUBLIC_KEY_PATH"
            log_success "SSH key pair deleted"
        else
            log_info "SSH key pair preserved"
        fi
    fi
}

# Show cleanup summary
show_cleanup_summary() {
    echo ""
    echo "🧹 Cleanup Summary:"
    echo "=================="
    echo "✅ AWS infrastructure destroyed"
    echo "✅ Terraform state files removed"
    echo "✅ Build artifacts cleaned"
    echo ""
    echo "📋 What's left:"
    echo "   - Project source code (preserved)"
    echo "   - SSH keys (if you chose to keep them)"
    echo "   - This script and documentation"
    echo ""
    echo "💡 To completely remove the project:"
    echo "   cd .. && rm -rf $(basename "$PROJECT_ROOT")"
}

# Main execution
main() {
    log_info "Starting cleanup process..."
    
    check_prerequisites
    show_current_infrastructure
    destroy_infrastructure
    cleanup_local_files
    cleanup_ssh_keys
    show_cleanup_summary
    
    log_success "Cleanup completed successfully!"
    echo ""
    echo "💰 All AWS resources have been destroyed to prevent ongoing charges."
    echo "🎉 Thank you for using the EC2 Tomcat Application project!"
}

# Run main function with confirmation
echo "🧹 EC2 Tomcat Application Cleanup Script"
echo "========================================"
echo ""
log_warning "This script will destroy your AWS infrastructure!"
echo ""
read -p "Do you want to continue? (y/N): " -r

if [[ $REPLY =~ ^[Yy]$ ]]; then
    main "$@"
else
    log_info "Cleanup cancelled by user"
    exit 0
fi
