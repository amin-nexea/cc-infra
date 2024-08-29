resource "google_secret_manager_secret_version" "db_secrets" {
  for_each = google_secret_manager_secret.db_secrets
  secret   = each.value.id
  secret_data = (
    each.key == "db-host" ? google_sql_database_instance.cultcreative_database_instance.public_ip_address :
    each.key == "db-user" ? var.db_user :
    each.key == "db-password" ? var.db_password :
    var.db_name
  )
}