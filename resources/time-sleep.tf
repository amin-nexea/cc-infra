# Add a delay after enabling APIs
resource "time_sleep" "wait_30_seconds" {
  depends_on = [google_project_service.apis]
  create_duration = "20s"
}