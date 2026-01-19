output "instance_id" {
  description = "ID of the instance"
  value       = google_compute_instance.instance.id
}

output "instance_name" {
  description = "Name of the instance"
  value       = google_compute_instance.instance.name
}

output "instance_self_link" {
  description = "Self link of the instance"
  value       = google_compute_instance.instance.self_link
}

output "instance_internal_ip" {
  description = "Internal IP address of the instance"
  value       = google_compute_instance.instance.network_interface[0].network_ip
}

output "instance_external_ip" {
  description = "External IP address of the instance (if enabled)"
  value       = length(google_compute_instance.instance.network_interface[0].access_config) > 0 ? google_compute_instance.instance.network_interface[0].access_config[0].nat_ip : "No Public IP"
}

output "instance_zone" {
  description = "Zone of the instance"
  value       = google_compute_instance.instance.zone
}
