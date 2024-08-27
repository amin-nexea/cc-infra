# Compute Engine instance
resource "google_compute_instance" "cultcreative_instance" {
  name         = "cultcreative-instance"
  machine_type = "e2-micro"  # 1 vCPU, 1 GB RAM
  zone         = "asia-southeast1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 10  # 10 GB
      type  = "pd-ssd"
    }
  }

  network_interface {
    network = google_compute_network.cultcreative_vpc_network.name
    access_config {
      // Ephemeral public IP
    }
  }

  # inject configuration files into the instance
  provisioner "remote-exec" {
  inline = [
    # create a directory named 'nginx' in the /tmp folder
    "mkdir -p /tmp/nginx",
    # decode the base64-encoded Nginx config from instance metadata and save it to /tmp/nginx/default.conf
    "echo '${google_compute_instance.cultcreative_instance.metadata.nginx-config}' | base64 -d > /tmp/nginx/default.conf",
    # decode the base64-encoded Nginx Dockerfile from instance metadata and save it to /tmp/nginx/Dockerfile
    "echo '${google_compute_instance.cultcreative_instance.metadata.nginx-dockerfile}' | base64 -d > /tmp/nginx/Dockerfile",
    # decode the base64-encoded docker-compose.yml from instance metadata and save it to /tmp/docker-compose.yml
    "echo '${google_compute_instance.cultcreative_instance.metadata.docker-compose}' | base64 -d > /tmp/docker-compose.yml",
  ]
}

  metadata_startup_script = file("startup-script.sh")

  metadata = {
    nginx-config = filebase64("${path.module}/nginx/default.conf")
    nginx-dockerfile = filebase64("${path.module}/nginx/Dockerfile")
    docker-compose = filebase64("${path.module}/docker-compose.yml")
  }

  tags = ["http-server", "https-server", "ssh"]

  service_account {
    scopes = ["cloud-platform"]
  }
}

# Firewall rule to allow SSH, HTTP, and HTTPS traffic
resource "google_compute_firewall" "cultcreative_firewall_allow_ssh_http_https" {
  name    = "cultcreative-firewall-allow-ssh-http-https"
  network = google_compute_network.cultcreative_vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "https-server", "ssh"]
}

# Outputs
output "database_instance_name" {
  description = "The name of the database instance"
  value       = google_sql_database_instance.cultcreative_database_instance.name
}

output "database_connection_name" {
  description = "The connection name of the database instance"
  value       = google_sql_database_instance.cultcreative_database_instance.connection_name
}

output "database_public_ip_address" {
  description = "The public IP address of the database instance"
  value       = google_sql_database_instance.cultcreative_database_instance.public_ip_address
}

# Outputs
output "vpc_name" {
  description = "The name of the VPC"
  value       = google_compute_network.cultcreative_vpc_network.name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.cultcreative_vpc_network.id
}

output "firewall_rules" {
  description = "The names of the firewall rules"
  value = [
    google_compute_firewall.cultcreative_firewall_allow_ssh_http_https.name
  ]
}

output "instance_public_ip" {
  description = "The public IP address of the Compute Engine instance"
  value       = google_compute_instance.cultcreative_instance.network_interface[0].access_config[0].nat_ip
}









