resource "google_secret_manager_secret" "db_secrets" {
  for_each  = toset(var.db_secret_names)
  secret_id = each.key
  
  replication {
    auto {
      // This block enables automatic replication
    }
  }

  depends_on   = [time_sleep.wait_20_seconds]
}