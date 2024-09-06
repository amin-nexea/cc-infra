# Service account for the Compute Engine instance
resource "google_service_account" "monitoring_instance_service_account" {
  account_id   = var.monitoring_instance_sa_id
  display_name = var.monitoring_instance_sa_display_name
  depends_on   = [time_sleep.wait_20_seconds]
}