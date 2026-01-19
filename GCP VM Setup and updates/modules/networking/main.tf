# Custom VPC
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

# Custom Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.vpc_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Firewall Rule: Allow IAP traffic
resource "google_compute_firewall" "allow_iap_traffic" {
  name    = "${var.vpc_name}-allow-iap"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = var.allowed_ports
  }

  source_ranges = var.iap_network_range
  target_tags   = var.network_tags
}

# Cloud Router (Required for NAT)
resource "google_compute_router" "router" {
  name    = "${var.vpc_name}-router"
  network = google_compute_network.vpc.id
  region  = var.region
}

# NAT Gateway
resource "google_compute_router_nat" "nat" {
  name                               = "${var.vpc_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat

  log_config {
    enable = var.nat_log_enable
    filter = var.nat_log_filter
  }
}
