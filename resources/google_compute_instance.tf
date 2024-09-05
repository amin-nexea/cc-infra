resource "google_compute_instance" "compute_engine_instance" {
  name         = var.instance_name
  machine_type = var.instance_machine_type
  zone         = var.instance_zone

  boot_disk {
    initialize_params {
      image = var.instance_image
      size  = var.instance_disk_size
      type  = var.instance_disk_type
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.id
    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = file("${path.module}/${var.instance_startup_script}")

  metadata = {
  nginx-config     = filebase64("${path.module}/${var.instance_nginx_config_path}")
  nginx-dockerfile = filebase64("${path.module}/${var.instance_nginx_dockerfile_path}")
  docker-compose   = filebase64("${path.module}/${var.instance_docker_compose_path}")
  }

  tags = var.instance_tags

  service_account {
    email  = google_service_account.instance_service_account.email
    scopes = var.instance_service_account_scopes
  }

  depends_on = [time_sleep.wait_20_seconds, google_service_account.instance_service_account, google_secret_manager_secret.db_secrets, google_secret_manager_secret_version.db_secrets, google_secret_manager_secret_iam_member.db_secrets_access]
}