# 1. Create a Custom VPC (auto_create_subnetworks must be false)
resource "google_compute_network" "custom_vpc" {
  name                    = "main-vpc"
  auto_create_subnetworks = false # Disables default subnet creation
}

# 2. Create a Subnet (This is where you define and expand your range)
resource "google_compute_subnetwork" "custom_subnet" {
  name          = "app-subnet-us-central1"
  ip_cidr_range = "10.0.1.0/24" # Initial range (256 IPs)
  region        = "us-central1"
  network       = google_compute_network.custom_vpc.id
}

# 3. Update your Instance to use the new Custom Subnet
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-medium"
  zone         = "us-central1-c"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
    }
  }

  network_interface {
    network    = google_compute_network.custom_vpc.id
    subnetwork = google_compute_subnetwork.custom_subnet.id # Explicitly link the subnet
    
    access_config {
      # Adds a public IP
    }
  }
}