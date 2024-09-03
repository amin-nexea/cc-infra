# Database user
resource "google_sql_user" "cultcreative_db_user_2" {
  name     = var.db_user
  instance = google_sql_database_instance.cultcreative_db_instance_2.name
  password = var.db_password
}