#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/startup-script.log"

log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

main() {
    log "Starting startup script"

    TARGET_HOME="/home/amin"

    log "Current TARGET_HOME value: $TARGET_HOME"

    export HOME=$TARGET_HOME

    log "Installing prerequisites"
    sudo apt-get install -y ca-certificates curl gnupg

    # Add Docker's official GPG key:
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    log "Updating package lists again"
    sudo apt-get update

    log "Installing Docker"
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    log "Installing Node.js  version v20.11.1 (LTS)"
    NODE_VERSION="20.11.1"
    ARCH="x64"
    NODE_FILENAME="node-v${NODE_VERSION}-linux-${ARCH}.tar.xz"
    NODE_URL="https://nodejs.org/dist/v${NODE_VERSION}/${NODE_FILENAME}"

    log "Downloading Node.js from: ${NODE_URL}"
    if curl -fsSLO "${NODE_URL}"; then
        log "Node.js download successful"
    else
        log "Error: Failed to download Node.js. URL may be incorrect or file may not exist."
        log "Attempting to list available versions..."
        curl -fsSL https://nodejs.org/dist/ | grep "${NODE_VERSION}"
        return 1
    fi

    log "Extracting Node.js"
    sudo tar -xJf "${NODE_FILENAME}" -C /usr/local --strip-components=1
    rm "${NODE_FILENAME}"

    log "Verifying Node.js installation"
    node --version
    npm --version

    log "Installing Yarn globally"
    npm install -g yarn

    log "Starting Docker service"
    sudo systemctl start docker

    log "Enabling Docker service"
    sudo systemctl enable docker

    log "Checking Docker service status"
    sudo systemctl status docker

    log "Setting up project directories"
    mkdir -p "$TARGET_HOME/cultcreative/nginx"

    log "Changing to cultcreative directory"
    cd "$TARGET_HOME/cultcreative"

    log "Cloning frontend repository"
    git clone https://github.com/NxTech4021/cc-frontend.git

    log "Cloning backend repository"
    git clone -b testing/production https://github.com/NxTech4021/cc-backend.git

    log "Attempting to set correct ownership for cultcreative directory"
    sudo chown -R amin:amin "$TARGET_HOME/cultcreative" 2>&1 | tee -a "$LOG_FILE" || log "Failed to change ownership of cultcreative directory"

    log "Checking cultcreative directory after chown"
    ls -la "$TARGET_HOME/cultcreative" || log "Cannot list cultcreative directory after chown"

    log "Attempting to set correct ownership for backend directory"
    sudo chown -R amin:amin "$TARGET_HOME/cultcreative/cc-backend" 2>&1 | tee -a "$LOG_FILE" || log "Failed to change ownership of backend directory"

    log "Creating temporary nginx directory"
     mkdir -p /tmp/nginx

    log "Fetching and decoding Nginx config"
    curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/nginx-config" | base64 -d > /tmp/nginx/default.conf 2>> "$LOG_FILE" || log "Failed to fetch/decode Nginx config"

    log "Fetching and decoding Nginx Dockerfile"
    curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/nginx-dockerfile" | base64 -d > /tmp/nginx/Dockerfile 2>> "$LOG_FILE" || log "Failed to fetch/decode Nginx Dockerfile"

    log "Fetching and decoding docker-compose.yml"
    curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/docker-compose" | base64 -d > /tmp/docker-compose.yml 2>> "$LOG_FILE" || log "Failed to fetch/decode docker-compose.yml"

    log "Copying Nginx filess"
    cp /tmp/nginx/default.conf "$TARGET_HOME/cultcreative/nginx/" || log "Failed to copy Nginx config"
    cp /tmp/nginx/Dockerfile "$TARGET_HOME/cultcreative/nginx/" || log "Failed to copy Nginx Dockerfile"

    log "Copying docker-compose.yml"
    cp /tmp/docker-compose.yml "$TARGET_HOME/cultcreative/" || log "Failed to copy docker-compose.yml"

    log "Fetching secrets"
    DB_USER=$(gcloud secrets versions access latest --secret=db-user 2>> "$LOG_FILE") || { log "Failed to fetch DB_USER secret"; exit 1; }
    DB_PASSWORD=$(gcloud secrets versions access latest --secret=db-password 2>> "$LOG_FILE") || { log "Failed to fetch DB_PASSWORD secret"; exit 1; }
    DB_HOST=$(gcloud secrets versions access latest --secret=db-host 2>> "$LOG_FILE") || { log "Failed to fetch DB_HOST secret"; exit 1; }
    DB_NAME=$(gcloud secrets versions access latest --secret=db-name 2>> "$LOG_FILE") || { log "Failed to fetch DB_NAME secret"; exit 1; }

    log "Setting environment variables"
    export DB_USER DB_PASSWORD DB_HOST DB_NAME

    # Form and export the DATABASE_URL
    export DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:5432/${DB_NAME}"
    log "DATABASE_URL has been set (redacted for security)"

    # Create a .env file for Docker Compose
    cat << EOF > "$HOME/cultcreative/.env"
DATABASE_URL=${DATABASE_URL}
EOF

    log "Starting Docker Compose"
    sudo -E docker compose -f docker-compose.yml up -d >> "$LOG_FILE" 2>&1

    log "Startup script completed successfully"
}

# Run the main function
main "$@" 2>&1 | tee -a "$LOG_FILE"