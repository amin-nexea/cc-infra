# Remote backend for storing Terraform states
terraform {
  backend "gcs" {
  bucket  = "cultcreative-infra"
  prefix  = "terraform/state"
  credentials = "C:/Users/famintech/Documents/NEXEA/Repo/CultCreative/cc-infra/keyfile.json"
  }
}

# Provider
provider "google" {
  project = "my-project-nexea"
  region  = "asia-southeast1-a"
  credentials = "C:/Users/famintech/Documents/NEXEA/Repo/CultCreative/cc-infra/keyfile.json"
}

# CultCreative Virtual Private Cloud (VPC)
resource "google_compute_network" "cultcreative_vpc_network" {
  name                    = "cultcreative-vpc-network"
  auto_create_subnetworks = true
  description             = "VPC network for CultCreative"
}

# Firewall rule for HTTP
resource "google_compute_firewall" "cultcreative_firewall_allow_http" {
  name    = "cultcreative-firewall-allow-http"
  network = google_compute_network.cultcreative_vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Firewall rule for HTTPS
resource "google_compute_firewall" "cultcreative_firewall_allow_https" {
  name    = "cultcreative-firewall-allow-https"
  network = google_compute_network.cultcreative_vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Firewall rule for SSH
resource "google_compute_firewall" "cultcreative_firewall_allow_ssh" {
  name    = "cultcreative-firewall-allow-ssh"
  network = google_compute_network.cultcreative_vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
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
    google_compute_firewall.cultcreative_firewall_allow_http.name,
    google_compute_firewall.cultcreative_firewall_allow_https.name,
    google_compute_firewall.cultcreative_firewall_allow_ssh.name
  ]
}







