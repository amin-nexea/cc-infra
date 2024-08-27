# Virtual Private Cloud (VPC)
resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_name
  auto_create_subnetworks = var.vpc_auto_create_subnetworks
  description             = var.vpc_description
}

output "vpc_network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc_network.id
}