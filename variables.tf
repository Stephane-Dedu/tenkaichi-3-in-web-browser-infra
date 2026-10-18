variable "project_id" {
  description = "Existing GCP project containing BT3."
  type        = string
}

variable "project_name" {
  description = "Current project display name (kept as is on import)."
  type        = string
}

variable "organization_id" {
  description = "Existing parent organization; this stack does not manage the organization."
  type        = string
}

variable "billing_account_id" {
  description = "Existing billing association; no billing account is created."
  type        = string
}

variable "project_owner" {
  description = "Existing IAM principal with the project Owner grant."
  type        = string
}

variable "region" {
  description = "GCP region for the VM's subnet and reserved IP."
  type        = string
  default     = "europe-west9"
}

variable "zone" {
  description = "GCP zone for the VM and boot disk."
  type        = string
  default     = "europe-west9-a"

  validation {
    condition     = startswith(var.zone, "${var.region}-")
    error_message = "The VM zone must belong to the configured region."
  }
}

variable "machine_type" {
  description = "Existing VM machine type. Changing it requires a separate reviewed stop/start."
  type        = string
  default     = "e2-micro"
}

variable "boot_image" {
  description = "Pinned image used to create the existing boot disk."
  type        = string
  default     = "projects/debian-cloud/global/images/debian-12-bookworm-v20261014"
}

variable "aws_region" {
  description = "AWS provider region; Route 53 records themselves are global."
  type        = string
  default     = "eu-west-3"
}

variable "route53_zone_id" {
  description = "Existing Route 53 hosted zone ID. Other records remain outside this stack."
  type        = string
}

variable "site_hostname" {
  description = "Site hostname, a CNAME in that zone (e.g. bt3.example.com)."
  type        = string
}
