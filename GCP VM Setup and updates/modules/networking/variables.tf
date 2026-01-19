variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
}

variable "iap_network_range" {
  description = "Google's IAP IP range for tunneling"
  type        = list(string)
  default     = ["35.235.240.0/20"]
}

variable "network_tags" {
  description = "Network tags for firewall rules"
  type        = list(string)
}

variable "allowed_ports" {
  description = "List of ports to allow through firewall"
  type        = list(string)
  default     = ["22", "80", "443"]
}

variable "nat_ip_allocate_option" {
  description = "NAT IP allocation option"
  type        = string
  default     = "AUTO_ONLY"
}

variable "source_subnetwork_ip_ranges_to_nat" {
  description = "How NAT should be configured per subnetwork"
  type        = string
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

variable "nat_log_enable" {
  description = "Enable NAT logging"
  type        = bool
  default     = true
}

variable "nat_log_filter" {
  description = "NAT log filter"
  type        = string
  default     = "ERRORS_ONLY"
}
