output "network_self_link" { value = google_compute_network.default.self_link }
output "subnetwork_self_link" { value = data.google_compute_subnetwork.default.self_link }
output "public_ip" { value = google_compute_address.bt3.address }
