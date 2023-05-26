#!/bin/bash

# Update the package repositories
yum update

# Install Nginx
yum install -y nginx

# Start Nginx
service nginx start

# Set up the default Nginx web page
echo "<html>
<head>
    <title>Welcome to Nginx!</title>
</head>
<body>
    <h1>Success! The Nginx web server is running.</h1>
</body>
</html>" > /var/www/html/index.html

# Output the server IP address
SERVER_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Nginx is installed and configured. You can access the web page by visiting http://$SERVER_IP in your web browser."


