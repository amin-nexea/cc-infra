resource "google_secret_manager_secret_iam_member" "db_secrets_access" {
  for_each  = google_secret_manager_secret.cultcreative_database_secrets
  secret_id = each.value.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cultcreative_instance_sa.email}"
}