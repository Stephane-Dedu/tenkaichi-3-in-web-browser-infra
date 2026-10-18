provider "google" {
  project = var.project_id
  region  = var.location
}

locals {
  save_sha256 = filesha256(var.save_path)
  save_name   = "base-saves/${local.save_sha256}.psv"
}

# This dedicated bucket contains only the shared public base save and its manifest.
resource "google_storage_bucket" "base_save" {
  name                        = "${var.project_id}-bt3-base-save"
  project                     = var.project_id
  location                    = var.location
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "inherited"
  force_destroy               = false

  versioning { enabled = true }
  cors {
    origin          = var.allowed_origins
    method          = ["GET", "HEAD"]
    response_header = ["Content-Type", "Content-Length", "ETag"]
    max_age_seconds = 3600
  }
  lifecycle_rule {
    condition { days_since_noncurrent_time = 30 }
    action { type = "Delete" }
  }
  labels = { application = "bt3", purpose = "public-base-save", managed_by = "terraform" }
  lifecycle { prevent_destroy = true }
}

resource "google_storage_bucket_iam_member" "public_save_reader" {
  bucket = google_storage_bucket.base_save.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_object" "base_save" {
  bucket        = google_storage_bucket.base_save.name
  name          = local.save_name
  source        = var.save_path
  content_type  = "application/octet-stream"
  cache_control = "public, max-age=31536000, immutable"
  metadata      = { sha256 = local.save_sha256, game = "SLUS-21678" }
  lifecycle { create_before_destroy = true }
}

resource "google_storage_bucket_object" "manifest" {
  bucket        = google_storage_bucket.base_save.name
  name          = "base-save.json"
  content_type  = "application/json"
  cache_control = "public, max-age=60, must-revalidate"
  content = jsonencode({
    version       = 1
    game          = "SLUS-21678"
    resetOnLaunch = true
    sha256        = local.save_sha256
    url           = "https://storage.googleapis.com/${google_storage_bucket.base_save.name}/${google_storage_bucket_object.base_save.name}"
  })
}

# State is kept separately from public game data, with public access prevention enforced.
resource "google_storage_bucket" "terraform_state" {
  name                        = "${var.project_id}-bt3-tfstate"
  project                     = var.project_id
  location                    = var.location
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false
  versioning { enabled = true }
  lifecycle_rule {
    condition { days_since_noncurrent_time = 90 }
    action { type = "Delete" }
  }
  labels = { application = "bt3", purpose = "terraform-state", managed_by = "terraform" }
  lifecycle { prevent_destroy = true }
}
