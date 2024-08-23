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
resource "google_compute_network" "cc_network" {
  name                    = "cultcreative-vpc"
  auto_create_subnetworks = true
  description             = "VPC network for CultCreative"
}







