# Remote backend for storing Terraform states
terraform {
  backend "gcs" {
    bucket  = "cultcreative-infra"
    prefix  = "terraform/state"
    credentials = "C:/Users/famintech/Documents/NEXEA/Repo/CultCreative/cc-infra/credentials/cultcreative-serviceaccount-keyfile.json"
  }
}

# Include all .tf files in the resources directory
module "resources" {
  source = "./resources"

  project_id                  = var.project_id
  region                      = var.region
  apis_to_enable              = var.apis_to_enable
  vpc_name                    = var.vpc_name
  vpc_auto_create_subnetworks = var.vpc_auto_create_subnetworks
  vpc_description             = var.vpc_description
  db_instance_name                      = var.db_instance_name     
  db_version                            = var.db_version 
  db_edition                            = var.db_edition  
  db_availability_type                  = var.db_availability_type  
  db_tier                               = var.db_tier     
  db_disk_size                          = var.db_disk_size  
  db_disk_type                          = var.db_disk_type    
  db_zone                               = var.db_zone         
  db_ipv4_enabled                       = var.db_ipv4_enabled  
  db_authorized_network_name            = var.db_authorized_network_name 
  db_authorized_network_value           = var.db_authorized_network_value  
  db_deletion_protection                = var.db_deletion_protection     
  db_backup                             = var.db_backup  
  db_backup_point_in_time_recovery      = var.db_backup_point_in_time_recovery
  db_backup_start_time                  = var.db_backup_start_time
  db_retained_backups                   = var.db_retained_backups
  db_maintenance_day                    = var.db_maintenance_day   
  db_maintenance_hour                   = var.db_maintenance_hour 
  db_flags_log_name                     = var.db_flags_log_name
  db_flags_log_query_time               = var.db_flags_log_query_time
  db_query_insights                     = var.db_query_insights
  db_query_string_length                = var.db_query_string_length  
  db_record_application_tags            = var.db_record_application_tags 
  db_record_client_address              = var.db_record_client_address
  db_name                               = var.db_name
  db_user                               = var.db_user
  db_password                           = var.db_password
  instance_name                         = var.instance_name
  instance_machine_type                 = var.instance_machine_type
  instance_zone                         = var.instance_zone
  instance_image                        = var.instance_image
  instance_disk_size                    = var.instance_disk_size
  instance_disk_type                    = var.instance_disk_type
  instance_startup_script               = var.instance_startup_script
  instance_nginx_config_path            = var.instance_nginx_config_path
  instance_nginx_dockerfile_path        = var.instance_nginx_dockerfile_path
  instance_docker_compose_path          = var.instance_docker_compose_path
  instance_tags                         = var.instance_tags
  instance_service_account_scopes       = var.instance_service_account_scopes
}









