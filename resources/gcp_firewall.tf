resource "google_compute_firewall" "firewall" {
  name    = var.firewall_name
  network = google_compute_network.vpc_network.id

  allow {
    protocol = var.firewall_protocol
    ports    = var.firewall_ports
  }

  source_ranges = var.firewall_source_ranges
  target_tags   = var.instance_tags
}