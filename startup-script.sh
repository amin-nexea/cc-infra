#!/bin/bash

# Update and install dependencies
apt-get update
apt-get install -y docker.io docker-compose git

# Start and enable Docker
systemctl start docker
systemctl enable docker

cd ~
mkdir cultcreative
cd cultcreative
git clone https://github.com/NxTech4021/cc-frontend.git
git clone https://github.com/NxTech4021/cc-backend.git
mkdir nginx

# Copy Nginx configuration and Dockerfile
cp /tmp/nginx/default.conf ./nginx/
cp /tmp/nginx/Dockerfile ./nginx/

# Copy docker-compose.yml
cp /tmp/docker-compose.yml ./docker-compose.yml




