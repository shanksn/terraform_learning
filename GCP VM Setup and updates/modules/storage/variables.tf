variable "bucket_name" {
  description = "Name of the storage bucket"
  type        = string
}

variable "location" {
  description = "Location of the bucket"
  type        = string
}

variable "force_destroy" {
  description = "Allow deletion of bucket with contents"
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable bucket versioning"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for the bucket"
  type = list(object({
    action = object({
      type          = string
      storage_class = optional(string)
    })
    condition = object({
      age                = optional(number)
      num_newer_versions = optional(number)
      with_state         = optional(string)
    })
  }))
  default = []
}

variable "bucket_objects" {
  description = "Map of objects to create in the bucket"
  type = map(object({
    content      = string
    content_type = optional(string)
  }))
  default = {}
}
