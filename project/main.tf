resource "google_project" "bt3" {
  project_id          = var.project_id
  name                = var.project_name
  org_id              = var.organization_id
  billing_account     = var.billing_account_id
  auto_create_network = true
  deletion_policy     = "PREVENT"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_project_service" "enabled" {
  for_each = var.enabled_services

  project                    = google_project.bt3.project_id
  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_compute_project_default_network_tier" "default" {
  project      = google_project.bt3.project_id
  network_tier = "PREMIUM"
}
