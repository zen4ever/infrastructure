
resource "google_project_service" "dns" {
  project = local.project
  service = "dns.googleapis.com"
}

resource "google_dns_managed_zone" "andrewkurin_com" {
  name        = "andrewkurin-com"
  dns_name    = "andrewkurin.com."
  description = "DNS for andrewkurin.com"
  project     = google_project_service.dns.project
}

resource "google_dns_record_set" "dev_instance" {
  name = "dev.andrewkurin.com."
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.andrewkurin_com.name

  rrdatas = [google_compute_address.dev_instance.address]
}

output "andrewkurin_com_nameservers" {
  value = google_dns_managed_zone.andrewkurin_com.name_servers
}
