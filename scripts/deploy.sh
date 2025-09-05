#!/bin/bash

# Deployment script for Tomcat application on AWS EC2
# This script builds the application and deploys it to the EC2 instance

set -e  # Exit on any error

# Configuration variables
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$PROJECT_ROOT/app"
WAR_NAME="tomcat-webapp.war"
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
    
    if ! command -v mvn &> /dev/null; then
        log_error "Maven is not installed. Please install Maven first."
        exit 1
    fi
    
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    log_success "All prerequisites are installed"
}

# Build the application
build_application() {
    log_info "Building the application..."
    
    cd "$APP_DIR"
    
    # Clean and package the application
    mvn clean package -DskipTests
    
    if [ ! -f "target/$WAR_NAME" ]; then
        log_error "Build failed - WAR file not found"
        exit 1
    fi
    
    log_success "Application built successfully"
    cd "$PROJECT_ROOT"
}

# Get EC2 instance IP from Terraform output
get_instance_ip() {
    log_info "Getting EC2 instance IP..."
    
    cd "$TERRAFORM_DIR"
    
    if [ ! -f "terraform.tfstate" ]; then
        log_error "Terraform state file not found. Please run 'terraform apply' first."
        exit 1
    fi
    
    INSTANCE_IP=$(terraform output -raw instance_public_ip 2>/dev/null)
    
    if [ -z "$INSTANCE_IP" ]; then
        log_error "Could not get instance IP from Terraform output"
        exit 1
    fi
    
    log_success "Instance IP: $INSTANCE_IP"
    cd "$PROJECT_ROOT"
}

# Deploy application to EC2
deploy_to_ec2() {
    log_info "Deploying application to EC2..."
    
    # Check if private key file exists
    if [ -z "$SSH_KEY_PATH" ]; then
        log_warning "SSH_KEY_PATH not set. Please set it to your private key file path."
        read -p "Enter path to your SSH private key file: " SSH_KEY_PATH
    fi
    
    if [ ! -f "$SSH_KEY_PATH" ]; then
        log_error "SSH private key file not found: $SSH_KEY_PATH"
        exit 1
    fi
    
    # Set correct permissions for SSH key
    chmod 600 "$SSH_KEY_PATH"
    
    # Copy WAR file to EC2 instance
    log_info "Copying WAR file to EC2 instance..."
    scp -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no \
        "$APP_DIR/target/$WAR_NAME" \
        ec2-user@"$INSTANCE_IP":/tmp/
    
    # Deploy on the server
    log_info "Deploying application on the server..."
    ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no ec2-user@"$INSTANCE_IP" << 'EOF'
        # Stop Tomcat
        sudo systemctl stop tomcat
        
        # Backup existing application (if any)
        if [ -d /opt/tomcat/webapps/ROOT ]; then
            sudo mv /opt/tomcat/webapps/ROOT /opt/tomcat/webapps/ROOT.backup.$(date +%Y%m%d_%H%M%S)
        fi
        
        # Remove old ROOT.war if exists
        sudo rm -f /opt/tomcat/webapps/ROOT.war
        
        # Deploy new application
        sudo cp /tmp/tomcat-webapp.war /opt/tomcat/webapps/ROOT.war
        sudo chown tomcat:tomcat /opt/tomcat/webapps/ROOT.war
        
        # Clean up temp file
        rm -f /tmp/tomcat-webapp.war
        
        # Start Tomcat
        sudo systemctl start tomcat
        
        # Wait a bit for deployment
        sleep 10
        
        # Check if Tomcat is running
        if sudo systemctl is-active --quiet tomcat; then
            echo "Tomcat is running successfully"
        else
            echo "Tomcat failed to start"
            exit 1
        fi
EOF
    
    if [ $? -eq 0 ]; then
        log_success "Application deployed successfully!"
        log_info "Application URL: http://$INSTANCE_IP:8080"
        log_info "Direct access: http://$INSTANCE_IP"
    else
        log_error "Deployment failed"
        exit 1
    fi
}

# Main execution
main() {
    log_info "Starting deployment process..."
    
    check_prerequisites
    build_application
    get_instance_ip
    deploy_to_ec2
    
    log_success "Deployment completed successfully!"
    echo ""
    echo "🎉 Your application is now available at:"
    echo "   📱 Application: http://$INSTANCE_IP"
    echo "   🚀 Tomcat Manager: http://$INSTANCE_IP:8080"
    echo ""
    echo "📋 Next steps:"
    echo "   - Test your application in a web browser"
    echo "   - Monitor logs: ssh -i $SSH_KEY_PATH ec2-user@$INSTANCE_IP 'sudo tail -f /opt/tomcat/logs/catalina.out'"
    echo "   - Check Tomcat status: ssh -i $SSH_KEY_PATH ec2-user@$INSTANCE_IP 'sudo systemctl status tomcat'"
}

# Run main function
main "$@"
