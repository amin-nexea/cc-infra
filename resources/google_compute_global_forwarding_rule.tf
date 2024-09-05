# HTTPS forwarding rule
resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name       = "https-global-rule"
  target     = google_compute_target_https_proxy.https_proxy.id
  port_range = "443"
}

# HTTP forwarding rule (optional, for redirection)
resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name       = "http-global-rule"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
}

resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "https-proxy"
  url_map          = google_compute_url_map.url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.http_redirect.id
}

resource "google_compute_url_map" "url_map" {
  name            = "url-map"
  default_service = google_compute_backend_service.backend_service.id

  host_rule {
    hosts        = ["cultcreative.famin.cloud"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.backend_service.id

    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.backend_service.id
    }
  }
}

resource "google_compute_url_map" "http_redirect" {
  name = "http-redirect"

  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

# Backend service
resource "google_compute_backend_service" "backend_service" {
  name        = "backend-service"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10
  health_checks = [google_compute_health_check.health_check.id]

  backend {
    group = google_compute_instance_group.instance_group.id
  }
}

# Health check
resource "google_compute_health_check" "health_check" {
  name               = "health-check"
  check_interval_sec = 5
  timeout_sec        = 5
  http_health_check {
    port = 80
  }
}

# Instance group
resource "google_compute_instance_group" "instance_group" {
  name        = "instance-group"
  description = "Web server instance group"
  zone        = var.instance_zone

  instances = [
    google_compute_instance.compute_engine_instance.id
  ]

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "cultcreative-managed-ssl-cert"

  managed {
    domains = ["cultcreative.famin.cloud"]
  }

  lifecycle {
    create_before_destroy = true
  }
}