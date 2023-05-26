#!/bin/bash

# Update the system
yum update

# Install Nginx, Docker and Git
yum install -y git docker 

# Start the Docker service
service docker start

# Add the EC2 user to the docker group to run Docker commands without sudo
usermod -a -G docker ec2-user

# Clone Git repository
git clone https://github.com/Adesam97/NODE-APP.git /tmp/myapp

# Build Docker image
cd /tmp/myapp/docker-node-app
docker build -t myapp .

# Run Docker container
docker run -d --restart=always -p 80:3000 myapp

