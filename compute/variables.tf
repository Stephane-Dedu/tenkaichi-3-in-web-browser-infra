variable "project_id" { type = string }
variable "zone" { type = string }
variable "machine_type" { type = string }
variable "boot_image" { type = string }
variable "network_self_link" { type = string }
variable "subnetwork_self_link" { type = string }
variable "public_ip" { type = string }
variable "metadata" { type = map(string) }
