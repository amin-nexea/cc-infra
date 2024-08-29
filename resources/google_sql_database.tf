# Database
resource "google_sql_database" "cultcreative_db" {
  name     = var.db_name
  instance = google_sql_database_instance.cultcreative_database_instance.name
}