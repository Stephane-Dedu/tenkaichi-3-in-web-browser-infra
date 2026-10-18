output "project_id" {
  description = "Managed GCP project."
  value       = module.project.project_id
}

output "vm_name" {
  value = module.compute.name
}

output "vm_zone" {
  value = var.zone
}

output "public_ip" {
  value = module.network.public_ip
}

output "site_url" {
  description = "Custom DNS name. HTTPS also requires this host in the VM's Caddy configuration."
  value       = "https://${module.dns.hostname}"
}

output "origin_url" {
  value = "https://${replace(module.network.public_ip, ".", "-")}.sslip.io"
}

output "base_save_manifest_url" {
  description = "Public manifest managed by the independent storage/ stack."
  value       = "https://storage.googleapis.com/${var.project_id}-bt3-base-save/base-save.json"
}
