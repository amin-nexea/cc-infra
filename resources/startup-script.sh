#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/startup-script.log"

log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

run_command() {
    if ! "$@"; then
        log "Error: Command '$*' failed"
        return 1
    fi
}

main() {
    log "Starting startup script"

    # Create a new user
    NEW_USER="cultcreative"
    log "Creating new user: $NEW_USER"
    useradd -m -s /bin/bash "$NEW_USER"
    
    # Set up sudo for the new user
    log "Setting up sudo for $NEW_USER"
    echo "$NEW_USER ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/$NEW_USER

    # Set HOME to the new user's home directory
    export HOME="/home/$NEW_USER"
    log "HOME directory set to: $HOME"

    # Change ownership of the log file to the new user
    chown $NEW_USER:$NEW_USER "$LOG_FILE"

    # Run the rest of the script as the new user
    su - $NEW_USER << EOF
    log "Running as user: $(whoami)"

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

    log "Installing NVM"
    export NVM_DIR="\$HOME/.nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
    [ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"

    log "Installing Node.js v20.17.0"
    nvm install v20.17.0
    nvm use 20.17.0

    log "Installing Yarn globally"
    npm install -g yarn

    log "Starting Docker service"
    sudo systemctl start docker

    log "Enabling Docker service"
    sudo systemctl enable docker

    log "Checking Docker service status"
    sudo systemctl status docker

    log "Setting up project directories"
    mkdir -p "\$HOME/cultcreative/nginx"

    log "Changing to cultcreative directory"
    cd "\$HOME/cultcreative"

    log "Cloning frontend repository"
    git clone https://github.com/NxTech4021/cc-frontend.git

    log "Cloning backend repository"
    git clone https://github.com/NxTech4021/cc-backend.git

    log "Setting correct ownership for cultcreative directory"
    sudo chown -R "\$(whoami):\$(whoami)" "\$HOME/cultcreative"

    log "Setting correct ownership for backend directory"
    sudo chown -R "\$(whoami):\$(whoami)" "\$HOME/cultcreative/cc-backend"

    log "Creating temporary nginx directory"
    mkdir -p /tmp/nginx

    log "Fetching and decoding Nginx config"
    curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/nginx-config" | base64 -d > /tmp/nginx/default.conf 2>> "$LOG_FILE" || log "Failed to fetch/decode Nginx config"

l   og "Fetching and decoding Nginx Dockerfile"
    curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/nginx-dockerfile" | base64 -d > /tmp/nginx/Dockerfile 2>> "$LOG_FILE" || log "Failed to fetch/decode Nginx Dockerfile"

    log "Fetching and decoding docker-compose.yml"
    curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/docker-compose" | base64 -d > /tmp/docker-compose.yml 2>> "$LOG_FILE" || log "Failed to fetch/decode docker-compose.yml"

    log "Copying Nginx files"
    cp /tmp/nginx/default.conf "$HOME/cultcreative/nginx/" || log "Failed to copy Nginx config"
    cp /tmp/nginx/Dockerfile "$HOME/cultcreative/nginx/" || log "Failed to copy Nginx Dockerfile"

    log "Copying docker-compose.yml"
    cp /tmp/docker-compose.yml "$HOME/cultcreative/" || log "Failed to copy docker-compose.yml"

    log "Startup script completed successfully"
EOF
}

# Run the main function
main "$@" 2>&1 | tee -a "$LOG_FILE"