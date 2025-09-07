# EC2 Tomcat Application 🚀

A complete Apache Tomcat web application deployment solution for AWS EC2, featuring Infrastructure as Code with Terraform, automated deployment scripts, and a sample Java web application.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Usage](#usage)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)
- [Security](#security)
- [Cost Management](#cost-management)
- [Contributing](#contributing)

## 🎯 Overview

This project provides a production-ready setup for deploying Java web applications on Apache Tomcat running on AWS EC2 instances. It includes:

- **Infrastructure as Code**: Complete AWS infrastructure provisioning with Terraform
- **Automated Deployment**: Shell scripts for building and deploying applications
- **Sample Application**: A fully functional Java servlet-based web application
- **Production Configuration**: Optimized Tomcat configurations for production use
- **Security**: Best practices for AWS security groups and access control

## ✨ Features

### Infrastructure
- ☁️ AWS EC2 instance with Amazon Linux 2
- 🌐 VPC with public subnet and internet gateway
- 🔒 Security group with proper port configuration
- 🔑 SSH key pair management
- 📍 Elastic IP for consistent access
- 🔄 Nginx reverse proxy (optional)

### Application
- ☕ Java servlet-based web application
- 📱 Responsive web interface
- 🔧 Maven build system
- 📊 Real-time server information display
- 🎨 Modern UI with CSS styling
- 📄 Custom error pages

### Operations
- 🚀 Automated deployment pipeline
- 📋 Comprehensive logging configuration
- 🔍 Health check endpoints
- 🧹 Cleanup and teardown scripts
- 📊 Performance monitoring ready

## 📦 Prerequisites

Before you begin, ensure you have the following installed:

### Required Tools
- **Terraform** (>= 1.0) - [Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- **AWS CLI** (>= 2.0) - [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- **Java** (>= 8) - [Installation Guide](https://adoptium.net/)
- **Maven** (>= 3.6) - [Installation Guide](https://maven.apache.org/install.html)

### AWS Setup
1. **AWS Account**: Active AWS account with appropriate permissions
2. **AWS Credentials**: Configured via `aws configure` or environment variables
3. **Permissions**: EC2, VPC, and IAM permissions for resource creation

### Verification
```bash
# Check required tools
terraform --version
aws --version
java -version
mvn --version

# Verify AWS credentials
aws sts get-caller-identity
```

## 🚀 Quick Start

### 1. Clone and Setup
```bash
# Navigate to your projects directory
cd ~/projects

# The project is already created at ec2-tomcat-app
cd ec2-tomcat-app

# Verify project structure
ls -la
```

### 2. Infrastructure Setup
```bash
# Run the infrastructure setup script
./scripts/setup-infrastructure.sh
```

This script will:
- Generate SSH key pairs
- Create Terraform configuration
- Provision AWS infrastructure
- Test connectivity

### 3. Deploy Application
```bash
# Deploy the application
./scripts/deploy.sh
```

This script will:
- Build the Java application
- Create WAR file
- Deploy to EC2 instance
- Start Tomcat service

### 4. Access Your Application
After deployment, access your application at:
- **Main Application**: `http://YOUR-IP-ADDRESS`
- **Tomcat Manager**: `http://YOUR-IP-ADDRESS:8080/manager`

## 📁 Project Structure

```
ec2-tomcat-app/
├── 📁 app/                          # Java web application
│   ├── 📄 pom.xml                   # Maven configuration
│   ├── 📁 src/main/
│   │   ├── 📁 java/com/example/webapp/
│   │   │   └── 📄 HelloServlet.java  # Sample servlet
│   │   └── 📁 webapp/
│   │       ├── 📁 WEB-INF/
│   │       │   └── 📄 web.xml       # Web app configuration
│   │       ├── 📄 index.jsp         # Homepage
│   │       └── 📄 error.jsp         # Error page
├── 📁 terraform/                    # Infrastructure as Code
│   ├── 📄 main.tf                   # Main Terraform configuration
│   ├── 📄 variables.tf              # Variable definitions
│   ├── 📄 outputs.tf                # Output definitions
│   ├── 📄 user_data.sh              # EC2 initialization script
│   └── 📄 terraform.tfvars.example  # Example variables
├── 📁 scripts/                      # Automation scripts
│   ├── 📄 setup-infrastructure.sh   # Infrastructure provisioning
│   ├── 📄 deploy.sh                 # Application deployment
│   └── 📄 cleanup.sh                # Resource cleanup
├── 📁 config/tomcat/                # Tomcat configurations
│   ├── 📄 server.xml                # Server configuration
│   ├── 📄 context.xml               # Context configuration
│   ├── 📄 tomcat-users.xml          # User authentication
│   └── 📄 logging.properties        # Logging configuration
├── 📄 .gitignore                    # Git ignore rules
└── 📄 README.md                     # This documentation
```

## ⚙️ Configuration

### Terraform Variables

Create `terraform/terraform.tfvars` with your configuration:

```hcl
# AWS Configuration
aws_region = "us-west-2"

# Project Configuration
project_name = "my-tomcat-app"

# EC2 Configuration
instance_type = "t3.micro"

# Tomcat Configuration
tomcat_version = "9.0.82"

# SSH Configuration
public_key = "ssh-rsa AAAAB3NzaC1yc2E... your-email@example.com"
```

### Tomcat Configuration

#### Manager Access
Default credentials (change in production):
- **Username**: `admin`
- **Password**: `admin123!`

#### Performance Tuning
Edit `config/tomcat/server.xml`:
- **Max Threads**: 200
- **Connection Timeout**: 20000ms
- **Compression**: Enabled for text content

#### Security Settings
- Error reporting disabled
- Server info hidden
- Session timeout: 30 minutes

## 🚀 Deployment

### Manual Deployment Steps

1. **Build Application**
   ```bash
   cd app
   mvn clean package
   ```

2. **Deploy to EC2**
   ```bash
   # Set your SSH key path
   export SSH_KEY_PATH=~/.ssh/tomcat-app-key
   
   # Run deployment script
   ./scripts/deploy.sh
   ```

### Automated CI/CD Integration

For production use, integrate with CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
name: Deploy to EC2
on:
  push:
    branches: [ main ]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy
        run: ./scripts/deploy.sh
```

## 🎯 Usage

### Accessing the Application

1. **Web Interface**
   - Navigate to `http://YOUR-EC2-IP`
   - Explore the sample application features
   - Test the servlet endpoints

2. **Tomcat Manager**
   - Access at `http://YOUR-EC2-IP:8080/manager`
   - Use credentials: `admin` / `admin123!`
   - Monitor applications and server status

3. **SSH Access**
   ```bash
   ssh -i ~/.ssh/tomcat-app-key ec2-user@YOUR-EC2-IP
   ```

### Application Endpoints

| Endpoint | Description |
|----------|-------------|
| `/` | Main application homepage |
| `/hello` | Sample servlet |
| `/hello?name=YourName` | Personalized greeting |
| `/manager` | Tomcat manager (requires auth) |

## 📊 Monitoring

### Log Files
```bash
# Tomcat application logs
sudo tail -f /opt/tomcat/logs/catalina.out

# System logs
sudo journalctl -u tomcat -f

# Access logs
sudo tail -f /opt/tomcat/logs/localhost_access_log.*
```

### Health Checks
```bash
# Check Tomcat status
sudo systemctl status tomcat

# Check application response
curl http://localhost:8080

# Check process
ps aux | grep tomcat
```

### Performance Monitoring
```bash
# Memory usage
free -h

# Disk usage
df -h

# Network connections
netstat -tlnp | grep :8080
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Tomcat Won't Start
```bash
# Check logs
sudo journalctl -u tomcat -n 50

# Check configuration
sudo -u tomcat /opt/tomcat/bin/catalina.sh configtest

# Check Java
java -version
```

#### 2. Application Not Accessible
```bash
# Check security groups
aws ec2 describe-security-groups

# Check Tomcat binding
netstat -tlnp | grep :8080

# Check firewall
sudo firewall-cmd --list-all
```

#### 3. SSH Connection Issues
```bash
# Check key permissions
ls -la ~/.ssh/tomcat-app-key

# Set correct permissions
chmod 600 ~/.ssh/tomcat-app-key

# Test connection
ssh -i ~/.ssh/tomcat-app-key -v ec2-user@YOUR-IP
```

### Debug Commands

```bash
# Application debugging
export CATALINA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n"

# Memory analysis
jstack $(pgrep java)
jstat -gc $(pgrep java)

# Network debugging
tcpdump -i eth0 port 8080
```

## 🔒 Security

### Best Practices Implemented

1. **Network Security**
   - Custom VPC with controlled access
   - Security groups with minimal required ports
   - SSH access restricted (consider IP whitelisting)

2. **Application Security**
   - Default passwords disabled in production
   - Error reporting minimized
   - Server information hidden

3. **System Security**
   - Regular system updates via user_data
   - Non-root Tomcat execution
   - File permissions properly configured

### Security Checklist

- [ ] Change default Tomcat manager passwords
- [ ] Restrict SSH access to specific IP ranges
- [ ] Enable HTTPS with SSL certificates
- [ ] Configure log monitoring and alerting
- [ ] Regular security updates
- [ ] Backup strategy implementation

### Hardening Steps

```bash
# Change manager passwords
sudo vi /opt/tomcat/conf/tomcat-users.xml

# Restrict SSH (optional)
sudo vi /etc/ssh/sshd_config
sudo systemctl restart sshd

# Enable firewall
sudo systemctl enable firewalld
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
```

## 💰 Cost Management

### AWS Resources Created
- **EC2 Instance**: t3.micro (~$8.50/month)
- **Elastic IP**: $3.65/month (when not associated)
- **EBS Storage**: ~$0.80/month for 8GB
- **Data Transfer**: Varies by usage

### Cost Optimization Tips

1. **Instance Sizing**
   - Start with t3.micro for testing
   - Use t3.small or larger for production
   - Consider Reserved Instances for long-term use

2. **Resource Cleanup**
   - Use `./scripts/cleanup.sh` when done
   - Stop instances when not in use
   - Remove unused snapshots and volumes

3. **Monitoring**
   - Set up AWS billing alerts
   - Use AWS Cost Explorer
   - Monitor CloudWatch metrics

### Cleanup

```bash
# Destroy all resources
./scripts/cleanup.sh

# Manual cleanup if needed
cd terraform
terraform destroy
```

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make changes and test thoroughly
4. Submit a pull request

### Code Style
- Use consistent indentation
- Add comments for complex logic
- Follow Java naming conventions
- Include documentation updates

### Testing
- Test on different instance types
- Verify in multiple AWS regions
- Check deployment scripts thoroughly
- Validate security configurations

### Reporting Issues
- Use GitHub Issues
- Include system information
- Provide error logs
- Describe reproduction steps

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Apache Tomcat team for the excellent servlet container
- HashiCorp for Terraform
- AWS for cloud infrastructure
- Open source community for various tools and libraries

---

## 📞 Support

-- Support will be available in the future Insha Allah --
