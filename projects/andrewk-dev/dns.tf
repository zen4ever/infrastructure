
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

output "andrewkurin_com_nameservers" {
  value = google_dns_managed_zone.andrewkurin_com.name_servers
}
