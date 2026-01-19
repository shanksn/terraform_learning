variable "instance_name" {
  description = "Name of the VM instance"
  type        = string
}

variable "machine_type" {
  description = "Machine type for the instance"
  type        = string
  default     = "e2-medium"
}

variable "zone" {
  description = "Zone where the instance will be created"
  type        = string
}

variable "network_tags" {
  description = "Network tags for the instance"
  type        = list(string)
  default     = []
}

variable "desired_status" {
  description = "Desired status of the instance (RUNNING or TERMINATED)"
  type        = string
  default     = "RUNNING"
}

variable "image_family" {
  description = "Image family to use"
  type        = string
  default     = "ubuntu-2404-lts-amd64"
}

variable "image_project" {
  description = "Project containing the image"
  type        = string
  default     = "ubuntu-os-cloud"
}

variable "boot_disk_size" {
  description = "Size of boot disk in GB"
  type        = number
  default     = 10
}

variable "boot_disk_type" {
  description = "Type of boot disk"
  type        = string
  default     = "pd-standard"
}

variable "startup_script" {
  description = "Startup script for the instance"
  type        = string
  default     = ""
}

variable "network_id" {
  description = "ID of the network"
  type        = string
}

variable "subnetwork_id" {
  description = "ID of the subnetwork"
  type        = string
}

variable "enable_external_ip" {
  description = "Enable external IP for the instance"
  type        = bool
  default     = false
}

variable "service_account_email" {
  description = "Email of the service account to attach"
  type        = string
}

variable "service_account_scopes" {
  description = "Scopes for the service account"
  type        = list(string)
  default     = ["cloud-platform"]
}

variable "allow_stopping_for_update" {
  description = "Allow stopping the instance to update it"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels to apply to the instance"
  type        = map(string)
  default     = {}
}
