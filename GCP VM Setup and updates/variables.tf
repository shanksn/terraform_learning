variable "project_id" {
  description = "The GCP Project ID"
  type        = string
  default     = "biotechproject-483505"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-c"
}

variable "instance_name" {
  description = "Name of the VM instance"
  type        = string
  default     = "biotech-app-server"
}

variable "instance_type" {
  description = "The machine type for the VM"
  type        = string
  default     = "e2-standard-2"
}

variable "vpc_name" {
  type    = string
  default = "biotech-main-vpc"
}

variable "subnet_cidr" {
  description = "CIDR range for the custom subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "network_tag_ssh" {
  description = "The network tag used to identify VMs that allow SSH"
  type        = string
  default     = "allow-ssh-iap"
}

variable "iap_network_range" {
  description = "Google's internal IP range for IAP tunneling"
  type        = list(string)
  default     = ["35.235.240.0/20"]
}

variable "bucket_name" {
  description = "Unique name for the GCS bucket"
  type        = string
  default     = "biotech-web-assets-4835051234" # Change this to something unique
}