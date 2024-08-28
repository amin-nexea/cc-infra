# Grant the service account access to Secret Manager
resource "google_project_iam_member" "db_secret_accessor" {
  project = "my-project-nexea"
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cultcreative_instance_sa.email}"
}
