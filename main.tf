# Google Cloud Provider
provider "google" {
  project = "my-project-nexea"
  region  = "asia-southeast1-a"
}

# CultCreative Virtual Private Cloud (VPC)
resource "google_compute_network" "cc_network" {
  name                    = "cc-network"
  auto_create_subnetworks = true
  description             = "VPC network for CultCreative"
}

