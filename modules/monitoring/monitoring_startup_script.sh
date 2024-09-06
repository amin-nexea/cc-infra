#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/monitoring-startup-script.log"

log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

main() {
    log "Starting monitoring startup script"

    log "Fetching and decoding Prometheus config"
    curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/prometheus-config" | base64 -d > /tmp/prometheus.yml 2>> "$LOG_FILE" || log "Failed to fetch/decode Prometheus config"

    log "Fetching and decoding Prometheus service file"
    curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/prometheus-service" | base64 -d > /tmp/prometheus.service 2>> "$LOG_FILE" || log "Failed to fetch/decode Prometheus service file"

    # Update and install dependencies
    log "Updating package lists and installing dependencies"
    sudo apt-get update
    sudo apt-get install -y apt-transport-https software-properties-common wget

    # Install Prometheus
    log "Installing Prometheus"
    wget https://github.com/prometheus/prometheus/releases/download/v2.37.0/prometheus-2.37.0.linux-amd64.tar.gz
    tar xvfz prometheus-*.tar.gz
    cd prometheus-2.37.0.linux-amd64
    sudo mv prometheus /usr/local/bin/
    sudo mv promtool /usr/local/bin/
    sudo mkdir /etc/prometheus
    sudo mv consoles/ console_libraries/ prometheus.yml /etc/prometheus/
    cd ..
    rm -rf prometheus-*

    # Configure Prometheus
    log "Configuring Prometheuss"
    sudo cp /tmp/prometheus.yml /etc/prometheus/prometheus.yml

    # Create Prometheus systemd service
    log "Creating Prometheus systemd service"
    sudo cp /tmp/prometheus.service /etc/systemd/system/prometheus.service

    # Create Prometheus user and set permissions
    sudo useradd --no-create-home --shell /bin/false prometheus
    sudo mkdir -p /var/lib/prometheus
    sudo chown prometheus:prometheus /var/lib/prometheus
    sudo chown -R prometheus:prometheus /etc/prometheus

    # Start Prometheus service
    sudo systemctl daemon-reload
    sudo systemctl enable prometheus
    sudo systemctl start prometheus

    # Install Grafana
    log "Installing Grafana"
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
    sudo apt-get update
    sudo apt-get install -y grafana

    # Start Grafana service
    sudo systemctl daemon-reload
    sudo systemctl enable grafana-server
    sudo systemctl start grafana-server

    log "Monitoring startup script completed successfully"
}

# Run the main function
main "$@" 2>&1 | tee -a "$LOG_FILE"