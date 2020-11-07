locals {
  ssh-keys = [
    {
      username = "me"
      key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDmGBrqoRZKnrnUT1b7XxCie5QHmAQEQazkmAWPU0yaLwvogdkzvEYrccfYe4q1g4+O4nUOG5HxseLDfBeP++JJaq9cNbAxAiQ8SKF6m77+cLnYwr01enfcScJdGmYczZWD0eCVDi2HbUyHeAUabLSjjoWaHzY1QBvw4BNeuJFjUL+8B7Gye3Q76JFrmnJ0ZoKwDPoEboJ9Sk1bXxljVqcquo628IYjxs53oa04miRDJVwPxFp80pPQqOqxmgnb32WNuDXsWiGyLxAzKJ8xRwS3XVnjsMm/VCMJxoy4Jr0RgA0/afrqKTNjqbvs18wNaReCR5GAJcsUUKxWZgB4oYySUBBCiUiHya4GjvYnlutCTJ2nvN7F1btlsn8hRozDp673Pa1owfYkZSiFCGDhUpOy1TlzCtQSOhfZXUeZbG98EoEUsKzIrUXkc6PQsDBFiR3zDG+v64f5nwnNnYDKK3GJcqBC2CM3EBZMmbzYvTcA6Lu3cPeSIT+ylzDOJxD4wZDhanhIn27lAQQhjcKwNDOsg0nsX1aGtRTze+0l7zM9pocc/R0sAezS1SlJWp2Op+XKhR1GumA3btWhvtX8RmrJPS4IYLcYfxJ0KmTVLbenDUKgU5vJQmTwBPIxSJ2z9lHRP12eL48EpSCuD1jC8Jj7FeGYIWqfXjp0ouY68+t2dQ=="
    },
    {
      username = "me"
      key      = "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAHiJpS5qhhy5U/rfJWD/BdoglZUO/qPwYGlrReSN8YDAUfA58qR67pPTw8rMj8+FMNDAJYGiro490Xx3Hb4TdY7yAFsv4JSnNvdMOYIR7QaH2fYC9iPfZl/tZ4L8E1OVpgp51muKL3n+GVQ6yJE3xb12vt4zZJiaHyQMr8hzlIehxpq8w=="
    },
    {
      username = "me"
      key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDa3mGIOFrBPYcj97R8PhoF5g6xNv5EtGAQ8uXqPanI3JRexGur+3ziAlRKkxuBW30kJ/h35cY/hdD9U3lnfre+dLGaXu5JyKL2HVGx6b55Q9gwQUnTTkd2IU2IwgSJm+LgfliIH44PtZvlxcszW7ZAVICqPQ+sDaTqSjDu8hRXA3iSZ+zM+VSBgMcNxOYd0w3uJziwF8W6TKt3lDGfzPTPawNP0MXYtydWOc5tKwkY/+nZ5F3VIVfthhWNRmOd9FtnXIGikXoKbl6kvuvwBQQLecwVYt40ke5OKhNIDwlm09/zlISZ+AozcAzIP5VTWkjweSvmVLr1AN2sYnuyQPZMlIRIkWzZfDDDu3HmKNk2gea4zgNBY+KOlGdAYpSjMizxWDsN0pte4v1ZARSF1bYUPKJi6hma+83FoCZbkV2WzjHBar48lDrUNtv4/pSe6qcioNsqmZtdkJ/06pBIL7lk5Fc+LomNSzGoppr7HXg24lnubhevYgVUJa3ilq9gNpMwU83ELOP0I2Cb1fDF1/GAWwxqITDQrHFMKz/bZzsjU+aVJOzs+INQmqOgquIX+xZ1PdByFlvC+1PHeIeWmX2tO1t7GmtANfgRjl5RMYDR+QSfFIwx1484L+fwaJbmKttgvfpFTdG/Q7NPM6NwiA1dR/Q0lQ5qmFzNyy1qKWRZkw=="
    }
  ]
}

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

  metadata = {
    ssh-keys = join("\n", [for each in local.ssh-keys : "${each["username"]}:${each["key"]}"])
  }

  service_account {
    email  = google_service_account.dev_instance.email
    scopes = ["cloud-platform"]
  }
  project = local.project
}

output "dev_instance_ip_address" {
  value = google_compute_address.dev_instance.address
}
