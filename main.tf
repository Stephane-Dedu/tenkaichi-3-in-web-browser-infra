locals {
  # This is the complete list enabled when the existing project was adopted.
  enabled_services = toset([
    "analyticshub.googleapis.com",
    "apptopology.googleapis.com",
    "bigquery.googleapis.com",
    "bigqueryconnection.googleapis.com",
    "bigquerydatapolicy.googleapis.com",
    "bigquerydatatransfer.googleapis.com",
    "bigquerymigration.googleapis.com",
    "bigqueryreservation.googleapis.com",
    "bigquerystorage.googleapis.com",
    "cloudapis.googleapis.com",
    "cloudtrace.googleapis.com",
    "compute.googleapis.com",
    "dataform.googleapis.com",
    "dataplex.googleapis.com",
    "datastore.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "sql-component.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
    "storage.googleapis.com",
    "telemetry.googleapis.com",
  ])

  iam_grants = {
    owner = {
      role   = "roles/owner"
      member = var.project_owner
    }
    compute_service_agent = {
      role   = "roles/compute.serviceAgent"
      member = "serviceAccount:service-${module.project.project_number}@compute-system.iam.gserviceaccount.com"
    }
    google_apis_service_agent = {
      role   = "roles/compute.instanceGroupManagerServiceAgent"
      member = "serviceAccount:${module.project.project_number}@cloudservices.gserviceaccount.com"
    }
  }
}

module "project" {
  source = "./project"

  project_id         = var.project_id
  project_name       = var.project_name
  organization_id    = var.organization_id
  billing_account_id = var.billing_account_id
  enabled_services   = local.enabled_services
}

# Manage only these existing grants; never replace the project's entire policy.
resource "google_project_iam_member" "existing" {
  for_each = local.iam_grants

  project = var.project_id
  role    = each.value.role
  member  = each.value.member

  lifecycle {
    prevent_destroy = true
  }
}

module "network" {
  source = "./network"

  project_id = var.project_id
  region     = var.region

  depends_on = [module.project]
}

module "compute" {
  source = "./compute"

  project_id           = var.project_id
  zone                 = var.zone
  machine_type         = var.machine_type
  boot_image           = var.boot_image
  network_self_link    = module.network.network_self_link
  subnetwork_self_link = module.network.subnetwork_self_link
  public_ip            = module.network.public_ip
  metadata = {
    # Public keys only, in a gitignored file (compute/ssh-keys.txt.example). Copy the VM's current
    # ssh-keys metadata there exactly, or the import would rewrite it.
    "ssh-keys" = file("${path.module}/compute/ssh-keys.txt")
  }
}

module "dns" {
  source = "./dns"

  zone_id  = var.route53_zone_id
  hostname = var.site_hostname
  target   = "${replace(module.network.public_ip, ".", "-")}.sslip.io"
}
