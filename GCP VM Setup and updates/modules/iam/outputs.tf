output "service_account_email" {
  description = "Email of the service account"
  value       = google_service_account.sa.email
}

output "service_account_id" {
  description = "ID of the service account"
  value       = google_service_account.sa.id
}

output "service_account_name" {
  description = "Name of the service account"
  value       = google_service_account.sa.name
}

output "service_account_unique_id" {
  description = "Unique ID of the service account"
  value       = google_service_account.sa.unique_id
}
