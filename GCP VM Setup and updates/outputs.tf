# Networking Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = module.networking.subnet_id
}

# Storage Outputs
output "bucket_name" {
  description = "The name of the storage bucket"
  value       = module.storage.bucket_name
}

output "bucket_url" {
  description = "The URL of the storage bucket"
  value       = module.storage.bucket_url
}

# IAM Outputs
output "service_account_email" {
  description = "Email of the service account"
  value       = module.iam.service_account_email
}

# Compute Outputs
output "instance_name" {
  description = "Name of the VM instance"
  value       = module.compute.instance_name
}

output "instance_internal_ip" {
  description = "The internal IP address of the instance"
  value       = module.compute.instance_internal_ip
}

output "instance_external_ip" {
  description = "The external IP address (if assigned)"
  value       = module.compute.instance_external_ip
}

output "instance_zone" {
  description = "Zone where the instance is deployed"
  value       = module.compute.instance_zone
}
