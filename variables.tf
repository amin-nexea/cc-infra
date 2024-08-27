variable "project_id" {
  description = "The ID of the Google Cloud project"
  type        = string
}

variable "region" {
  description = "The region to use for Google Cloud resources"
  type        = string
}

variable "credentials_file" {
  description = "The path to the Google Cloud credentials file"
  type        = string
}

variable "apis_to_enable" {
  description = "List of APIs to enable in the project"
  type        = list(string)
}

variable "vpc_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "vpc_auto_create_subnetworks" {
  description = "Whether to create subnetworks automatically"
  type        = bool
}

variable "vpc_description" {
  description = "Description of the VPC network"
  type        = string
}

variable "db_instance_name" {
  description = "The name of the Cloud SQL instance"
  type        = string
}

variable "db_version" {
  description = "The database version for the Cloud SQL instance"
  type        = string
}

variable "db_tier" {
  description = "The machine type for the Cloud SQL instance"
  type        = string
}

variable "db_disk_size" {
  description = "The disk size for the Cloud SQL instance in GB"
  type        = number
}

variable "db_disk_type" {
  description = "The disk type for the Cloud SQL instance"
  type        = string
}

variable "db_zone" {
  description = "The zone for the Cloud SQL instance"
  type        = string
}

variable "db_ipv4_enabled" {
  description = "Whether to enable IPv4 for the Cloud SQL instance"
  type        = bool
}

variable "db_authorized_network_name" {
  description = "The name of the authorized network for the Cloud SQL instance"
  type        = string
}

variable "db_authorized_network_value" {
  description = "The CIDR range of the authorized network for the Cloud SQL instance"
  type        = string
}

variable "db_deletion_protection" {
  description = "Whether to enable deletion protection for the Cloud SQL instance"
  type        = bool
}

variable "db_edition" {
  type        = string
  description = "The edition of the database instance (e.g., 'ENTERPRISE')"
}

variable "db_availability_type" {
  type        = string
  description = "The availability type of the database instance (e.g., 'REGIONAL')"
}

variable "db_backup" {
  type        = bool
  description = "Whether to enable backups for the database instance"
}

variable "db_backup_point_in_time_recovery" {
  type        = bool
  description = "Whether to enable point-in-time recovery for the database instance"
}

variable "db_backup_start_time" {
  type        = string
  description = "The start time for the daily backup (in UTC)"
}

variable "db_maintenance_day" {
  type        = number
  description = "The day of the week for maintenance (1-7 for Monday-Sunday)"
}

variable "db_maintenance_hour" {
  type        = number
  description = "The hour of the day for maintenance (0-23)"
}

variable "db_flags_log_name" {
  type        = string
  description = "The name of the database flag for logging"
}

variable "db_retained_backups" {
  type        = number
  description = "The number of backups to retain"
}

variable "db_flags_log_query_time" {
  type        = string
  description = "The minimum duration of a query to be logged"
}

variable "db_query_insights" {
  type        = bool
  description = "Whether to enable query insights"
}

variable "db_query_string_length" {
  type        = number
  description = "The maximum length of the query string to be stored"
}

variable "db_record_application_tags" {
  type        = bool
  description = "Whether to record application tags"
}

variable "db_record_client_address" {
  type        = bool
  description = "Whether to record client address"
}

variable "db_user" {
  description = "CultCreative Database User"
  type        = string
}

variable "db_password" {
  description = "CultCreative Database Password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "CultCreative Database Name"
  type        = string
}

variable "instance_name" {
  type        = string
  description = "The name of the compute instance"
}

variable "instance_machine_type" {
  type        = string
  description = "The machine type of the compute instance"
}

variable "instance_zone" {
  type        = string
  description = "The zone where the compute instance will be created"
}

variable "instance_image" {
  type        = string
  description = "The boot disk image for the compute instance"
}

variable "instance_disk_size" {
  type        = number
  description = "The size of the boot disk in GB"
}

variable "instance_disk_type" {
  type        = string
  description = "The type of the boot disk"
}

variable "instance_startup_script" {
  type        = string
  description = "The path to the startup script file"
}

variable "instance_nginx_config_path" {
  type        = string
  description = "The path to the Nginx config file"
}

variable "instance_nginx_dockerfile_path" {
  type        = string
  description = "The path to the Nginx Dockerfile"
}

variable "instance_docker_compose_path" {
  type        = string
  description = "The path to the docker-compose.yml file"
}

variable "instance_tags" {
  type        = list(string)
  description = "The network tags to apply to the instance"
}

variable "instance_service_account_scopes" {
  type        = list(string)
  description = "The service account scopes for the instance"
}


