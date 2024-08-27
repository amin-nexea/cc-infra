# Database user
resource "google_sql_user" "cultcreative_db_user" {
  name     = var.db_user
  instance = google_sql_database_instance.cultcreative_database_instance.name
  password = var.db_password
}