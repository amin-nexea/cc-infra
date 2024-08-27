# Cloud SQL instance
resource "google_sql_database_instance" "cultcreative_database_instance" {
  name             = var.db_instance_name
  database_version = var.db_version
  region           = var.region

  settings {
    tier = var.db_tier
    disk_size = var.db_disk_size
    disk_type = var.db_disk_type
    edition = var.db_edition
    availability_type = var.db_availability_type

    location_preference {
      zone = var.db_zone
    }

    backup_configuration {
      enabled                        = var.db_backup
      point_in_time_recovery_enabled = var.db_backup_point_in_time_recovery
      start_time                     = var.db_backup_start_time
      backup_retention_settings {
        retained_backups = var.db_retained_backups 
      }
    }

    maintenance_window {
      day  = var.db_maintenance_day  # Sunday
      hour = var.db_maintenance_hour  # 3 AM
    }

    ip_configuration {
      ipv4_enabled = var.db_ipv4_enabled
      authorized_networks {
        name  = var.db_authorized_network_name
        value = var.db_authorized_network_value
      }
    }

    database_flags {
      name  = var.db_flags_log_name
      value = var.db_flags_log_query_time
    }

    insights_config {
      query_insights_enabled  = var.db_query_insights
      query_string_length     = var.db_query_string_length
      record_application_tags = var.db_record_application_tags
      record_client_address   = var.db_record_client_address
    }
  }

  deletion_protection = var.db_deletion_protection
  depends_on = [google_project_service.apis]
}

# Outputs for SQL instance
output "db_instance_name" {
  description = "The name of the SQL instance"
  value       = google_sql_database_instance.cultcreative_database_instance.name
}

output "db_connection_name" {
  description = "The connection name of the SQL instance"
  value       = google_sql_database_instance.cultcreative_database_instance.connection_name
}

output "db_public_ip_address" {
  description = "The public IP address of the SQL instance"
  value       = google_sql_database_instance.cultcreative_database_instance.public_ip_address
}

output "db_private_ip_address" {
  description = "The private IP address of the SQL instance"
  value       = google_sql_database_instance.cultcreative_database_instance.private_ip_address
}

output "db_version" {
  description = "The database version of the SQL instance"
  value       = google_sql_database_instance.cultcreative_database_instance.database_version
}

output "db_region" {
  description = "The region of the SQL instance"
  value       = google_sql_database_instance.cultcreative_database_instance.region
}

output "db_tier" {
  description = "The tier of the SQL instance"
  value       = google_sql_database_instance.cultcreative_database_instance.settings[0].tier
}