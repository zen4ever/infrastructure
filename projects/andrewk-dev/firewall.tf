resource "google_compute_firewall" "mosh" {
  name    = "mosh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "udp"
    ports    = ["60000-65535"]
  }

  target_tags = ["mosh"]
}
