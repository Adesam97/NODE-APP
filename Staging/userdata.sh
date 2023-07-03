#!/bin/bash

# Update the system
yum update

# Install Nginx, Docker and Git
yum install -y docker #git

# Start the Docker service
service docker start

# Add the EC2 user to the docker group to run Docker commands without sudo
usermod -a -G docker ec2-user

# Clone Git repository
#git clone https://github.com/Adesam97/NODE-APP.git /tmp/myapp

# Build Docker image
docker rmi fikunmisamson/node-app --force
docker pull fikunmisamson/node-app:latest
docker rm node-web --force

# Run Docker container
docker run -dit --name node-web --restart=always -p 80:3000 -p 443:443 fikunmisamson/node-app:latest

