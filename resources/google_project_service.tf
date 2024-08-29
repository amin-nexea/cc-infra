resource "google_project_service" "apis" {
  for_each = toset(var.apis_to_enable)
  project  = var.project_id
  service  = each.key

  disable_on_destroy = true
}

data "google_project_service" "api_status" {
  for_each = toset(var.apis_to_enable)
  project  = var.project_id
  service  = each.key

  depends_on = [google_project_service.apis]
}

output "api_statuses" {
  description = "The status of all enabled APIs"
  value = {
    for api in var.apis_to_enable :
    api => data.google_project_service.api_status[api].project != "" ? "Enabled" : "Disabled"
  }
}