# Output for the bucket name
output "gcs_bucket_name" {
  description = "The name of the GCS bucket used for storing Terraform state"
  value       = "cultcreative-cloud-infra"
}

# Output for the project ID
output "project_id" {
  description = "The ID of the Google Cloud project"
  value       = var.project_id
}

# Output for the enabled APIs
output "api_statuses" {
  description = "The status of all enabled APIs"
  value       = module.resources.api_statuses
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.resources.vpc_network_id
}

output "db_instance_name" {
  description = "The name of the SQL instance"
  value       = module.resources.db_instance_name
}

output "db_connection_name" {
  description = "The connection name of the SQL instance"
  value       = module.resources.db_connection_name
}

output "db_public_ip_address" {
  description = "The public IP address of the SQL instance"
  value       = module.resources.db_public_ip_address
}

output "db_private_ip_address" {
  description = "The private IP address of the SQL instance"
  value       = module.resources.db_private_ip_address
}

output "db_version" {
  description = "The database version of the SQL instance"
  value       = module.resources.db_version
}

output "db_region" {
  description = "The region of the SQL instance"
  value       = module.resources.db_region
}

output "db_tier" {
  description = "The tier of the SQL instance"
  value       = module.resources.db_tier
}

# ... other existing outputs ...

