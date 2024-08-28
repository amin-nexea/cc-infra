# Service account for the Compute Engine instance
resource "google_service_account" "instance_serviceaccount" {
  account_id   = "cultcreative-instance-sa"
  display_name = "CultCreative Instance Service Account"
  depends_on   = [time_sleep.wait_30_seconds]
}