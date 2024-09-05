resource "google_compute_instance" "gcp_instance_prometheus_grafana" {
  name         = var.monitoring_instance_name
  machine_type = var.monitoring_instance_machine_type
  zone         = var.monitoring_instance_zone

  boot_disk {
    initialize_params {
      image = var.monitoring_instance_image
      size  = var.monitoring_instance_disk_size
      type  = var.monitoring_instance_disk_type
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.id
    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = file("${path.module}/${var.monitoring_instance_startup_script}")

  metadata = {
  
  }

  tags = var.monitoring_instance_tags

  service_account {
    email  = google_service_account.monitoring_instance_service_account.email
    scopes = var.instance_service_account_scopes
  }

  depends_on = [time_sleep.wait_20_seconds, google_service_account.monitoring_instance_service_account]
}