# Database
resource "google_sql_database" "cultcreative_db_2" {
  name     = var.db_name
  instance = google_sql_database_instance.cultcreative_db_instance_2.name
}