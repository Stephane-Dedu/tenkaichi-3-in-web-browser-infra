# The default Compute Engine account is created and maintained by Google.
data "google_compute_default_service_account" "default" {
  project = var.project_id
}

resource "google_compute_disk" "boot" {
  project                   = var.project_id
  name                      = "bt3"
  zone                      = var.zone
  type                      = "pd-standard"
  size                      = 10
  image                     = var.boot_image
  physical_block_size_bytes = 4096

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_instance" "bt3" {
  project             = var.project_id
  name                = "bt3"
  zone                = var.zone
  machine_type        = var.machine_type
  can_ip_forward      = false
  deletion_protection = false
  tags                = ["bt3"]
  metadata            = var.metadata

  # No automatic stop is allowed for changes to the imported running VM.
  allow_stopping_for_update = false

  boot_disk {
    source      = google_compute_disk.boot.self_link
    auto_delete = true
    device_name = "persistent-disk-0"
    mode        = "READ_WRITE"
    interface   = "SCSI"
  }

  network_interface {
    network    = var.network_self_link
    subnetwork = var.subnetwork_self_link
    network_ip = "10.200.0.2"
    stack_type = "IPV4_ONLY"

    access_config {
      nat_ip       = var.public_ip
      network_tier = "PREMIUM"
    }
  }

  service_account {
    email = data.google_compute_default_service_account.default.email
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/pubsub",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
