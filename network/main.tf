# Keep the existing auto-mode VPC. Google manages its regional subnets and routes.
resource "google_compute_network" "default" {
  project                                   = var.project_id
  name                                      = "default"
  description                               = "Default network for the project"
  auto_create_subnetworks                   = true
  routing_mode                              = "REGIONAL"
  mtu                                       = 1460
  network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"

  lifecycle {
    prevent_destroy = true
  }
}

data "google_compute_subnetwork" "default" {
  project = var.project_id
  name    = "default"
  region  = var.region

  depends_on = [google_compute_network.default]
}

resource "google_compute_address" "bt3" {
  project = var.project_id
  name    = "bt3-ip"
  region  = var.region
  # The address itself comes from the import (left computed, so it is not in the code).
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
  network_tier = "PREMIUM"

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  # Capture the current rules exactly; adoption does not alter network access.
  firewalls = {
    bt3-allow = {
      description   = "BT3 site (HTTPS), lobby (UDP for the PC version), deploy (SSH)"
      priority      = 1000
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["bt3"]
      allow = [
        { protocol = "tcp", ports = ["22"] },
        { protocol = "tcp", ports = ["80"] },
        { protocol = "tcp", ports = ["443"] },
        { protocol = "udp", ports = ["7780"] },
      ]
    }
    default-allow-icmp = {
      description   = "Allow ICMP from anywhere"
      priority      = 65534
      source_ranges = ["0.0.0.0/0"]
      target_tags   = []
      allow         = [{ protocol = "icmp", ports = [] }]
    }
    default-allow-internal = {
      description   = "Allow internal traffic on the default network"
      priority      = 65534
      source_ranges = ["10.128.0.0/9"]
      target_tags   = []
      allow = [
        { protocol = "tcp", ports = ["0-65535"] },
        { protocol = "udp", ports = ["0-65535"] },
        { protocol = "icmp", ports = [] },
      ]
    }
    default-allow-rdp = {
      description   = "Allow RDP from anywhere"
      priority      = 65534
      source_ranges = ["0.0.0.0/0"]
      target_tags   = []
      allow         = [{ protocol = "tcp", ports = ["3389"] }]
    }
    default-allow-ssh = {
      description   = "Allow SSH from anywhere"
      priority      = 65534
      source_ranges = ["0.0.0.0/0"]
      target_tags   = []
      allow         = [{ protocol = "tcp", ports = ["22"] }]
    }
  }
}

resource "google_compute_firewall" "existing" {
  for_each = local.firewalls

  project       = var.project_id
  name          = each.key
  network       = google_compute_network.default.self_link
  description   = each.value.description
  direction     = "INGRESS"
  priority      = each.value.priority
  disabled      = false
  source_ranges = each.value.source_ranges
  target_tags   = each.value.target_tags

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }
}
