# Service Account
resource "google_service_account" "sa" {
  account_id   = var.account_id
  display_name = var.display_name
  description  = var.description
}

# Project-level IAM bindings
resource "google_project_iam_member" "project_roles" {
  for_each = toset(var.project_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.sa.email}"
}

# Storage bucket IAM bindings
resource "google_storage_bucket_iam_member" "bucket_roles" {
  for_each = var.bucket_iam_bindings

  bucket = each.value.bucket
  role   = each.value.role
  member = "serviceAccount:${google_service_account.sa.email}"
}
