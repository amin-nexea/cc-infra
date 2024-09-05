resource "google_compute_firewall" "monitoring_firewall" {
  name    = "allow-monitoring"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "9090", "3000"]
  }

  source_ranges = ["0.0.0.0/0"]  // Consider restricting this in production
  target_tags   = ["monitoring"]
}