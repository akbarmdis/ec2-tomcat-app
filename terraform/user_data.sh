#!/bin/bash
# User data script to install and configure Tomcat on Amazon Linux 2

# Update system
yum update -y

# Install Java 8 (required for Tomcat)
yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel

# Create tomcat user
useradd -m -U -d /opt/tomcat -s /bin/false tomcat

# Download and install Tomcat
cd /tmp
TOMCAT_VERSION=${tomcat_version}
wget https://archive.apache.org/dist/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
tar xzf apache-tomcat-$TOMCAT_VERSION.tar.gz -C /opt/tomcat --strip-components=1

# Set permissions
chown -R tomcat: /opt/tomcat
chmod +x /opt/tomcat/bin/*.sh

# Create systemd service file for Tomcat
cat > /etc/systemd/system/tomcat.service << 'EOF'
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start Tomcat
systemctl daemon-reload
systemctl enable tomcat
systemctl start tomcat

# Configure firewall (if firewalld is running)
if systemctl is-active --quiet firewalld; then
    firewall-cmd --zone=public --permanent --add-port=8080/tcp
    firewall-cmd --reload
fi

# Install nginx for reverse proxy (optional)
yum install -y nginx

# Configure nginx as reverse proxy
cat > /etc/nginx/conf.d/tomcat.conf << 'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Start and enable nginx
systemctl enable nginx
systemctl start nginx

# Create a simple test application
mkdir -p /opt/tomcat/webapps/test
cat > /opt/tomcat/webapps/test/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Tomcat Test Application</title>
</head>
<body>
    <h1>Welcome to Apache Tomcat on AWS EC2!</h1>
    <p>This is a test application running on Tomcat.</p>
    <p>Server time: <script>document.write(new Date());</script></p>
</body>
</html>
EOF

# Restart Tomcat to pick up the new application
systemctl restart tomcat

# Log completion
echo "Tomcat installation and configuration completed" >> /var/log/user-data.log
