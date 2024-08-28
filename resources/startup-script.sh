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

    USER_HOME=$(eval echo ~$USER)
    log "User home directory: $USER_HOME"

    log "Updating package lists"
    run_command sudo apt-get update

    log "Installing prerequisites"
    run_command sudo apt-get install -y ca-certificates curl

    log "Setting up Docker repository"
    run_command sudo install -m 0755 -d /etc/apt/keyrings
    run_command sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    run_command sudo chmod a+r /etc/apt/keyrings/docker.asc

    log "Adding Docker repository to Apt sources"
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      run_command sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    log "Updating package lists again"
    run_command sudo apt-get update

    log "Installing NVM"
    run_command curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

    log "Sourcing NVM"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    log "Installing Node.js v20.17.0"
    run_command nvm install v20.17.0

    log "Setting Node.js v20.17.0 as default"
    run_command nvm use 20.17.0

    log "Installing Yarn globally"
    run_command npm install -g yarn

    log "Starting Docker service"
    run_command sudo systemctl start docker

    log "Enabling Docker service"
    run_command sudo systemctl enable docker

    log "Checking Docker service status"
    run_command sudo systemctl status docker

    log "Changing to user home directory"
    cd "$USER_HOME" || {
        log "Failed to change to $USER_HOME"
        exit 1
    }

    log "Startup script completed successfully"
}

# Run the main function
main "$@" 2>&1 | tee -a "$LOG_FILE"