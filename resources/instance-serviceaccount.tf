# Service account for the Compute Engine instance
resource "google_service_account" "instance_service_account" {
  account_id   = var.instance_service_account_id
  display_name = "CultCreative Instance Service Account"
  depends_on   = [time_sleep.wait_30_seconds]
}