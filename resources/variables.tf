variable "project_id" {}
variable "region" {}
variable "apis_to_enable" {}
variable "vpc_name" {}
variable "vpc_auto_create_subnetworks" {}
variable "vpc_description" {}
variable "db_instance_name" {}                   
variable "db_version" {}                
variable "db_edition" {}        
variable "db_availability_type" {} 
variable "db_tier" {}                
variable "db_disk_size" {}                     
variable "db_disk_type" {}                
variable "db_zone" {}                
variable "db_ipv4_enabled" {}                  
variable "db_authorized_network_name" {}
variable "db_authorized_network_value" {} 
variable "db_deletion_protection" {} 
variable "db_backup" {}     
variable "db_backup_point_in_time_recovery" {} 
variable "db_backup_start_time" {} 
variable "db_maintenance_day" {}
variable "db_maintenance_hour" {} 
variable "db_retained_backups" {} 
variable "db_flags_log_name" {} 
variable "db_flags_log_query_time" {} 
variable "db_query_insights" {} 
variable "db_query_string_length" {} 
variable "db_record_application_tags" {} 
variable "db_record_client_address" {} 
variable "db_name" {} 
variable "db_user" {} 
variable "db_password" {} 
variable "instance_name"{}                         
variable "instance_machine_type"{}                 
variable "instance_zone"{}                         
variable "instance_image"{}                        
variable "instance_disk_size"{}                    
variable "instance_disk_type"{}                    
variable "instance_startup_script"{}               
variable "instance_nginx_config_path"{}            
variable "instance_nginx_dockerfile_path"{}        
variable "instance_docker_compose_path"{}          
variable "instance_tags"{}                         
variable "instance_service_account_scopes"{}       
variable "firewall_name"{}       
variable "firewall_protocol"{}       
variable "firewall_ports"{}       
variable "firewall_source_ranges"{}       