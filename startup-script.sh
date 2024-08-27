#!/bin/bash

# Function for logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/startup-script.log
}

log "Starting startup script"

# Update and install dependencies
log "Updating package lists"
apt-get update >> /var/log/startup-script.log 2>&1 || log "Failed to update package lists"

log "Installing dependencies"
apt-get install -y docker.io docker-compose git >> /var/log/startup-script.log 2>&1 || log "Failed to install dependencies"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.bashrc
nvm install v20.17.0
npm install -g yarn
sudo chown -R $(whoami):$(whoami) /home/famintech/cultcreative/cc-backend

# Start and enable Docker
log "Starting and enabling Docker"
systemctl start docker >> /var/log/startup-script.log 2>&1 || log "Failed to start Docker"
systemctl enable docker >> /var/log/startup-script.log 2>&1 || log "Failed to enable Docker"

log "Checking Docker service status"
systemctl status docker >> /var/log/startup-script.log 2>&1 || log "Docker service status check failed"

# Create directory structure
log "Creating directory structure"
cd /home/famintech/
sudo mkdir -p /home/famintech/cultcreative/
sudo mkdir -p /home/famintech/cultcreative/nginx
sudo chown -R famintech:famintech /home/famintech/cultcreative
cd /home/famintech/cultcreative || {
    log "Failed to change directory to /home/famintech/cultcreative"
    exit 1
}

# Clone repositories
log "Cloning repositories"
if [ ! -d "cc-frontend" ]; then
    git clone https://github.com/NxTech4021/cc-frontend.git
    if [ $? -eq 0 ]; then
        log "Successfully cloned cc-frontend"
    else
        log "Failed to clone cc-frontend. Error code: $?"
    fi
else
    log "cc-frontend directory already exists, skipping clone"
fi

if [ ! -d "cc-backend" ]; then
    git clone https://github.com/NxTech4021/cc-backend.git
    if [ $? -eq 0 ]; then
        log "Successfully cloned cc-backend"
    else
        log "Failed to clone cc-backend. Error code: $?"
    fi
else
    log "cc-backend directory already exists, skipping clone"
fi

# List contents of current directory
log "Contents of /home/famintech/cultcreative:"
ls -la

# List contents of nginx directory
log "Contents of /home/famintech/cultcreative/nginx:"
ls -la nginx

log "Creating temporary nginx directory"
mkdir -p /tmp/nginx

log "Fetching and decoding Nginx config"
echo "$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/nginx-config)" | base64 -d > /tmp/nginx/default.conf 2>> /var/log/startup-script.log || log "Failed to fetch/decode Nginx config"

log "Fetching and decoding Nginx Dockerfile"
echo "$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/nginx-dockerfile)" | base64 -d > /tmp/nginx/Dockerfile 2>> /var/log/startup-script.log || log "Failed to fetch/decode Nginx Dockerfile"

log "Fetching and decoding docker-compose.yml"
echo "$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/docker-compose)" | base64 -d > /tmp/docker-compose.yml 2>> /var/log/startup-script.log || log "Failed to fetch/decode docker-compose.yml"

log "Copying Nginx files"
cp /tmp/nginx/default.conf ./nginx/ || log "Failed to copy Nginx config"
cp /tmp/nginx/Dockerfile ./nginx/ || log "Failed to copy Nginx Dockerfile"

log "Copying docker-compose.yml"
cp /tmp/docker-compose.yml ./docker-compose.yml || log "Failed to copy docker-compose.yml"

log "Fetching secrets"
DB_USER=$(gcloud secrets versions access latest --secret=db-user 2>> /var/log/startup-script.log) || log "Failed to fetch DB_USER secret"
DB_PASSWORD=$(gcloud secrets versions access latest --secret=db-password 2>> /var/log/startup-script.log) || log "Failed to fetch DB_PASSWORD secret"
DB_HOST=$(gcloud secrets versions access latest --secret=db-host 2>> /var/log/startup-script.log) || log "Failed to fetch DB_HOST secret"
DB_NAME=$(gcloud secrets versions access latest --secret=db-name 2>> /var/log/startup-script.log) || log "Failed to fetch DB_NAME secret"

log "Setting environment variables"
export DB_USER DB_PASSWORD DB_HOST DB_NAME

log "Verifying environment variables"
env | grep -E "DB_|GOOGLE_" >> /var/log/startup-script.log

log "Processing docker-compose.yml"
envsubst < docker-compose.yml > docker-compose.processed.yml || log "Failed to process docker-compose.yml"

log "Docker Compose file content:"
cat docker-compose.processed.yml | sed 's/\(password:\s*\).*/\1[REDACTED]/' >> /var/log/startup-script.log

log "Starting Docker Compose"
docker-compose -f docker-compose.processed.yml up -d >> /var/log/startup-script.log 2>&1 || {
  log "Failed to start Docker Compose. Error: $?"
  docker-compose -f docker-compose.processed.yml config >> /var/log/startup-script.log 2>&1
  log "Docker Compose configuration check output above"
}

log "Available Docker images:"
docker images >> /var/log/startup-script.log 2>&1 || log "Failed to list Docker images"

log "Docker networks:"
docker network ls >> /var/log/startup-script.log 2>&1 || log "Failed to list Docker networks"

log "Startup script completed"