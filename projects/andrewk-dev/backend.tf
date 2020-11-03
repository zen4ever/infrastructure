terraform {
  backend "gcs" {
    bucket = "andrewk-dev-terraform-state"
    prefix = "projects/andrewk-dev"
  }
}
