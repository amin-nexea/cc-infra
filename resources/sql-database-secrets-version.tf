resource "google_secret_manager_secret_version" "db_secrets" {
  for_each = google_secret_manager_secret.cultcreative_database_secrets
  secret   = each.value.id
  secret_data = (
    each.key == "db-host" ? google_sql_database_instance.cultcreative_database_instance.public_ip_address :
    each.key == "db-user" ? var.cultcreative_database_user :
    each.key == "db-password" ? var.cultcreative_database_password :
    var.cultcreative_database_name
  )