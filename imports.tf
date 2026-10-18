# One-time adoption of existing resources. These blocks are inert after import.
# For a different/new project, remove this file before the initial plan.
import {
  to = module.project.google_project.bt3
  id = var.project_id
}

import {
  for_each = local.enabled_services
  to       = module.project.google_project_service.enabled[each.key]
  id       = "${var.project_id}/${each.value}"
}

import {
  to = module.project.google_compute_project_default_network_tier.default
  id = var.project_id
}

import {
  for_each = local.iam_grants
  to       = google_project_iam_member.existing[each.key]
  id       = "${var.project_id} ${each.value.role} ${each.value.member}"
}

import {
  to = module.network.google_compute_network.default
  id = "projects/${var.project_id}/global/networks/default"
}

import {
  for_each = toset(["bt3-allow", "default-allow-icmp", "default-allow-internal", "default-allow-rdp", "default-allow-ssh"])
  to       = module.network.google_compute_firewall.existing[each.key]
  id       = "projects/${var.project_id}/global/firewalls/${each.value}"
}

import {
  to = module.network.google_compute_address.bt3
  id = "projects/${var.project_id}/regions/${var.region}/addresses/bt3-ip"
}

import {
  to = module.compute.google_compute_disk.boot
  id = "projects/${var.project_id}/zones/${var.zone}/disks/bt3"
}

import {
  to = module.compute.google_compute_instance.bt3
  id = "projects/${var.project_id}/zones/${var.zone}/instances/bt3"
}

import {
  to = module.dns.aws_route53_record.bt3
  id = "${var.route53_zone_id}_${var.site_hostname}_CNAME"
}
