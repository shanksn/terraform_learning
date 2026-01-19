variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "account_id" {
  description = "Service account ID"
  type        = string
}

variable "display_name" {
  description = "Display name for the service account"
  type        = string
}

variable "description" {
  description = "Description for the service account"
  type        = string
  default     = ""
}

variable "project_roles" {
  description = "List of project-level IAM roles to assign"
  type        = list(string)
  default     = []
}

variable "bucket_iam_bindings" {
  description = "Map of bucket IAM bindings"
  type = map(object({
    bucket = string
    role   = string
  }))
  default = {}
}
