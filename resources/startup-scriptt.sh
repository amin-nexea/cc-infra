log "Fetching secrets"
DB_USER=$(gcloud secrets versions access latest --secret=db-user 2>> /var/log/startup-script.log) || log "Failed to fetch DB_USER secret"
DB_PASSWORD=$(gcloud secrets versions access latest --secret=db-password 2>> /var/log/startup-script.log) || log "Failed to fetch DB_PASSWORD secret"
DB_HOST=$(gcloud secrets versions access latest --secret=db-host 2>> /var/log/startup-script.log) || log "Failed to fetch DB_HOST secret"
DB_NAME=$(gcloud secrets versions access latest --secret=db-name 2>> /var/log/startup-script.log) || log "Failed to fetch DB_NAME secret"

log "Setting environment variables"
export DB_USER DB_PASSWORD DB_HOST DB_NAME

log "Processing docker-compose.yml"
envsubst < docker-compose.yml > docker-compose.processed.yml || log "Failed to process docker-compose.yml"

log "Starting Docker Compose"
docker-compose -f docker-compose.processed.yml up -d >> /var/log/startup-script.log 2>&1 || {
  log "Failed to start Docker Compose. Error: $?"
  docker-compose -f docker-compose.processed.yml config >> /var/log/startup-script.log 2>&1
  log "Docker Compose configuration check output above"
}

