output "base_save_manifest_url" {
  value       = "https://storage.googleapis.com/${google_storage_bucket.base_save.name}/${google_storage_bucket_object.manifest.name}"
  description = "Set site.json baseSaveManifest to this public URL."
}

output "base_save_sha256" {
  value = local.save_sha256
}

output "site_config" {
  value = { baseSaveManifest = "https://storage.googleapis.com/${google_storage_bucket.base_save.name}/${google_storage_bucket_object.manifest.name}" }
}

output "state_bucket" {
  value = google_storage_bucket.terraform_state.name
}
