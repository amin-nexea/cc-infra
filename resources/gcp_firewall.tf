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

resource "google_compute_firewall" "lb_firewall" {
  name    = "allow-lb-traffic"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["http-server", "https-server"]
}

