#!/bin/bash

# Infrastructure setup script for EC2 Tomcat application
# This script provisions AWS infrastructure using Terraform

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

# Check if required tools are installed
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install Terraform first."
        log_info "Visit: https://learn.hashicorp.com/tutorials/terraform/install-cli"
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed. Please install AWS CLI first."
        log_info "Visit: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials are not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    log_success "All prerequisites are installed"
}

# Generate SSH key pair if not exists
setup_ssh_key() {
    log_info "Setting up SSH key pair..."
    
    SSH_KEY_DIR="$HOME/.ssh"
    SSH_KEY_NAME="tomcat-app-key"
    PRIVATE_KEY_PATH="$SSH_KEY_DIR/$SSH_KEY_NAME"
    PUBLIC_KEY_PATH="$SSH_KEY_DIR/$SSH_KEY_NAME.pub"
    
    if [ ! -f "$PRIVATE_KEY_PATH" ]; then
        log_info "Generating new SSH key pair..."
        ssh-keygen -t rsa -b 2048 -f "$PRIVATE_KEY_PATH" -N "" -C "tomcat-app-$(date +%Y%m%d)"
        chmod 600 "$PRIVATE_KEY_PATH"
        chmod 644 "$PUBLIC_KEY_PATH"
        log_success "SSH key pair generated: $PRIVATE_KEY_PATH"
    else
        log_info "SSH key pair already exists: $PRIVATE_KEY_PATH"
    fi
    
    # Export the key path for use in deployment script
    export SSH_KEY_PATH="$PRIVATE_KEY_PATH"
    
    # Read public key content
    PUBLIC_KEY_CONTENT=$(cat "$PUBLIC_KEY_PATH")
    log_success "SSH key pair is ready"
}

# Setup Terraform variables
setup_terraform_vars() {
    log_info "Setting up Terraform variables..."
    
    cd "$TERRAFORM_DIR"
    
    TFVARS_FILE="terraform.tfvars"
    
    if [ ! -f "$TFVARS_FILE" ]; then
        log_info "Creating terraform.tfvars file..."
        
        # Get AWS region from AWS CLI config or use default
        AWS_REGION=$(aws configure get region 2>/dev/null || echo "us-west-2")
        
        cat > "$TFVARS_FILE" << EOF
# AWS Configuration
aws_region = "$AWS_REGION"

# Project Configuration
project_name = "tomcat-app"

# EC2 Configuration
instance_type = "t3.micro"

# Tomcat Configuration
tomcat_version = "9.0.82"

# SSH Configuration
public_key = "$PUBLIC_KEY_CONTENT"
EOF
        
        log_success "Terraform variables file created: $TFVARS_FILE"
    else
        log_info "Terraform variables file already exists: $TFVARS_FILE"
        
        # Update the public key in existing file
        if command -v sed &> /dev/null; then
            # Use a temporary file for cross-platform compatibility
            sed "s|^public_key = .*|public_key = \"$PUBLIC_KEY_CONTENT\"|" "$TFVARS_FILE" > "$TFVARS_FILE.tmp" && mv "$TFVARS_FILE.tmp" "$TFVARS_FILE"
            log_info "Updated public key in terraform.tfvars"
        fi
    fi
    
    cd "$PROJECT_ROOT"
}

# Initialize and apply Terraform
apply_terraform() {
    log_info "Applying Terraform configuration..."
    
    cd "$TERRAFORM_DIR"
    
    # Initialize Terraform
    log_info "Initializing Terraform..."
    terraform init
    
    # Validate configuration
    log_info "Validating Terraform configuration..."
    terraform validate
    
    # Plan the deployment
    log_info "Planning Terraform deployment..."
    terraform plan -out=tfplan
    
    # Apply the configuration
    log_info "Applying Terraform configuration..."
    log_warning "This will create AWS resources that may incur costs."
    
    read -p "Do you want to proceed with creating AWS resources? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform apply tfplan
        
        # Clean up plan file
        rm -f tfplan
        
        log_success "Infrastructure created successfully!"
    else
        log_info "Terraform apply cancelled by user"
        rm -f tfplan
        exit 0
    fi
    
    cd "$PROJECT_ROOT"
}

# Display infrastructure information
show_infrastructure_info() {
    log_info "Retrieving infrastructure information..."
    
    cd "$TERRAFORM_DIR"
    
    echo ""
    echo "🏗️  Infrastructure Information:"
    echo "================================"
    
    # Get outputs
    INSTANCE_ID=$(terraform output -raw instance_id 2>/dev/null || echo "N/A")
    INSTANCE_IP=$(terraform output -raw instance_public_ip 2>/dev/null || echo "N/A")
    INSTANCE_DNS=$(terraform output -raw instance_public_dns 2>/dev/null || echo "N/A")
    TOMCAT_URL=$(terraform output -raw tomcat_url 2>/dev/null || echo "N/A")
    SSH_COMMAND=$(terraform output -raw ssh_connection_command 2>/dev/null || echo "N/A")
    
    echo "📋 Instance ID: $INSTANCE_ID"
    echo "🌐 Public IP: $INSTANCE_IP"
    echo "🔗 Public DNS: $INSTANCE_DNS"
    echo "🚀 Tomcat URL: $TOMCAT_URL"
    echo "💻 SSH Command: ssh -i $SSH_KEY_PATH ec2-user@$INSTANCE_IP"
    echo ""
    
    log_info "Waiting for instance to be fully ready (this may take a few minutes)..."
    sleep 30
    
    # Test SSH connectivity
    log_info "Testing SSH connectivity..."
    if ssh -i "$SSH_KEY_PATH" -o ConnectTimeout=10 -o StrictHostKeyChecking=no ec2-user@"$INSTANCE_IP" "echo 'SSH connection successful'" &>/dev/null; then
        log_success "SSH connection test successful"
    else
        log_warning "SSH connection test failed. The instance may still be initializing."
    fi
    
    cd "$PROJECT_ROOT"
}

# Main execution
main() {
    log_info "Starting infrastructure setup..."
    
    check_prerequisites
    setup_ssh_key
    setup_terraform_vars
    apply_terraform
    show_infrastructure_info
    
    log_success "Infrastructure setup completed successfully!"
    echo ""
    echo "🎉 Your AWS infrastructure is now ready!"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Wait for the EC2 instance to fully initialize (5-10 minutes)"
    echo "   2. Run './scripts/deploy.sh' to deploy your application"
    echo "   3. Access your application at: http://$INSTANCE_IP"
    echo ""
    echo "💡 Useful commands:"
    echo "   - Check instance status: aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].State.Name' --output text"
    echo "   - SSH to instance: ssh -i $SSH_KEY_PATH ec2-user@$INSTANCE_IP"
    echo "   - View Tomcat logs: ssh -i $SSH_KEY_PATH ec2-user@$INSTANCE_IP 'sudo tail -f /opt/tomcat/logs/catalina.out'"
    echo ""
    echo "💰 Don't forget to run 'terraform destroy' when you're done to avoid AWS charges!"
}

# Run main function
main "$@"
