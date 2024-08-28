resource "google_secret_manager_secret" "db_secrets" {
  for_each  = toset(["db-user", "db-password", "db-host", "db-name"])
  secret_id = each.key
  
  replication {
    auto {
      // This block enables automatic replication
    }
  }

  depends_on   = [time_sleep.wait_30_seconds]
}