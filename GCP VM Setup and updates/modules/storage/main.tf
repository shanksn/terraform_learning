# Versioned Storage Bucket
resource "google_storage_bucket" "bucket" {
  name          = var.bucket_name
  location      = var.location
  force_destroy = var.force_destroy

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }
      condition {
        age                   = lookup(lifecycle_rule.value.condition, "age", null)
        num_newer_versions    = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
        with_state            = lookup(lifecycle_rule.value.condition, "with_state", null)
      }
    }
  }
}

# Bucket Objects
resource "google_storage_bucket_object" "objects" {
  for_each = var.bucket_objects

  name    = each.key
  bucket  = google_storage_bucket.bucket.name
  content = each.value.content

  content_type = lookup(each.value, "content_type", null)
}
