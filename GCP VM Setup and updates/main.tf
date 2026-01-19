# 1. Fetch the latest Ubuntu image
data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}

# 2. Custom VPC
resource "google_compute_network" "custom_vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

# 3. Custom Subnet
resource "google_compute_subnetwork" "custom_subnet" {
  name          = "${var.vpc_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.custom_vpc.id
}

# 1. The Versioned Bucket
resource "google_storage_bucket" "web_assets" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true

  versioning {
    enabled = true
  }
}

# 2. The HTML File
resource "google_storage_bucket_object" "index_html" {
  name    = "index.html"
  bucket  = google_storage_bucket.web_assets.name
  content = <<-EOT
    <h1>Welcome to Terraform. This is dynamic123</h1>
    <p>Live Clock: <span id="clock"></span></p>
    <script>
      setInterval(() => { document.getElementById('clock').innerText = new Date().toLocaleTimeString(); }, 1000);
    </script>
  EOT
}

# 1. Define the Service Account Identity
resource "google_service_account" "vm_sa" {
  account_id   = "biotech-vm-sa"
  display_name = "Service Account for Biotech VM"
}

# 2. Assign the "Storage Object Viewer" role to this Service Account
# This specifically allows the identity to read files from your bucket
resource "google_storage_bucket_iam_member" "viewer" {
  bucket = google_storage_bucket.web_assets.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.vm_sa.email}"
}

# 3. The VM Instance
resource "google_compute_instance" "vm_instance" {
  name         = var.instance_name
  machine_type = var.instance_type
  zone         = var.zone
  tags         = [var.network_tag_ssh]
  desired_status = "TERMINATED"
  
  boot_disk {
    initialize_params { image = data.google_compute_image.ubuntu.self_link }
  }

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      # Install Nginx
      apt-get update && apt-get install -y nginx

      # Initial pull of the content
      gsutil cp gs://${google_storage_bucket.web_assets.name}/index.html /var/www/html/index.html

      # SCRIPT-LESS SYNC: Add a direct command to crontab
      # This runs every minute: downloads file and ensures permissions are correct
      (crontab -l 2>/dev/null; echo "* * * * * gsutil cp gs://${google_storage_bucket.web_assets.name}/index.html /var/www/html/index.html") | crontab -
      
      systemctl restart nginx
    EOT
  }

  network_interface {
    network    = google_compute_network.custom_vpc.id
    subnetwork = google_compute_subnetwork.custom_subnet.id
  }

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["cloud-platform"]
  }
}

# 1. Firewall Rule: Allow ONLY IAP to hit Port 80 and Port 22
resource "google_compute_firewall" "allow_iap_traffic" {
  name    = "allow-iap-to-web-and-ssh"
  network = google_compute_network.custom_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  # Only allow Google's IAP proxy range
  source_ranges = var.iap_network_range
  target_tags   = [var.network_tag_ssh]
}


# 1. Create a Cloud Router (Required for NAT)
resource "google_compute_router" "router" {
  name    = "biotech-router"
  network = google_compute_network.custom_vpc.id
  region  = var.region
}

# 2. Create the NAT Gateway
resource "google_compute_router_nat" "nat" {
  name                               = "biotech-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

