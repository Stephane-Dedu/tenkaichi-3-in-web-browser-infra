variable "project_id" {
  type        = string
  description = "GCP project that owns the save and Terraform state buckets."
}

variable "location" {
  type        = string
  description = "Cloud Storage location. Matches the existing BT3 VM region."
  default     = "europe-west9"
}

variable "save_path" {
  type        = string
  description = "Local BT3 USA PSV file to upload. The file stays outside Git."
  validation {
    condition     = fileexists(var.save_path) && can(regex("(?i)\\.psv$", var.save_path))
    error_message = "save_path must point to an existing PSV file."
  }
}

variable "allowed_origins" {
  type        = list(string)
  description = "Browser origins allowed to download the public base save. No credentials are sent."
  default     = ["*"]
}
