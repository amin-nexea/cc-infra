resource "google_secret_manager_secret_iam_member" "db_secrets_access" {
  for_each  = google_secret_manager_secret.db_secrets
  secret_id = each.value.id
  role      = var.db_secret_accessor_role
  member    = "serviceAccount:${google_service_account.instance_service_account.email}"
}