#!/bin/bash

# Update the system
yum update

# Install Nginx, Docker and Git
yum install -y git docker #nginx

# Start the Docker service
service docker start

# Add the EC2 user to the docker group to run Docker commands without sudo
usermod -a -G docker ec2-user

# Clone Git repository
git clone https://github.com/Adesam97/NODE-APP.git /tmp/myapp

# Build Docker image
cd /tmp/myapp/docker-node-app
docker build -t myapp .

# # Configure Nginx to reverse proxy to the Docker container
# cat <<EOF > /etc/nginx/sites-available/myapp
# server {
#     listen 80;

#     location / {
#         proxy_pass http://localhost:3000;
#         proxy_set_header Host \$host;
#         proxy_set_header X-Real-IP \$remote_addr;
#     }
# }
# EOF

# # Enable the Nginx site
# ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/

# # Remove default Nginx configuration
# rm /etc/nginx/sites-enabled/default

# # Restart Nginx
# systemctl restart nginx

# Run Docker container
docker run -d --restart=always -p 80:3000 myapp

