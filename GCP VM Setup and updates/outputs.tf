# The internal IP address (This is now your primary way to identify the VM)
output "instance_internal_ip" {
  description = "The internal IP address of the instance"
  value       = google_compute_instance.vm_instance.network_interface[0].network_ip
}

# The external IP address (Using a conditional to avoid the error)
output "instance_external_ip" {
  description = "The external IP address (if assigned)"
  # This syntax checks if access_config exists before trying to read the IP
  value       = length(google_compute_instance.vm_instance.network_interface[0].access_config) > 0 ? google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip : "No Public IP"
}