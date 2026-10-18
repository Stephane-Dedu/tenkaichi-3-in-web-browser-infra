provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

  # Preserve the labels of imported resources during adoption.
  add_terraform_attribution_label = false
}

# Route 53 is global. Authentication uses the normal AWS credential chain.
provider "aws" {
  region = var.aws_region
}
