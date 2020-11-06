
resource "google_service_account" "dev_instance" {
  account_id   = "dev-instance"
  display_name = "Dev Instance"
  project      = local.project
}

resource "google_project_iam_member" "dev_instance" {
  for_each = toset([
    "roles/storage.objectAdmin",
  ])
  project = local.project
  role    = each.key
  member  = "serviceAccount:${google_service_account.dev_instance.email}"
}

resource "google_compute_address" "dev_instance" {
  name    = "dev-instance"
  region  = "us-west1"
  project = local.project
}

resource "google_compute_instance" "dev_instance" {
  name         = "dev-instance01"
  machine_type = "f1-micro"
  zone         = "us-west1-a"

  tags = ["mosh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"

    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.dev_instance.address
    }
  }

  labels = {
    role = "development"
  }

  metadata_startup_script = "apt-get update && apt-get install -y mosh"

  service_account {
    email  = google_service_account.dev_instance.email
    scopes = ["cloud-platform"]
  }
  project = local.project
}

output "dev_instance_ip_address" {
  value = google_compute_address.dev_instance.address
}
