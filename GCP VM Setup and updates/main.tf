# Networking Module
module "networking" {
  source = "./modules/networking"

  vpc_name           = var.vpc_name
  region             = var.region
  subnet_cidr        = var.subnet_cidr
  iap_network_range  = var.iap_network_range
  network_tags       = [var.network_tag_ssh]
  allowed_ports      = ["22", "80", "443"]

  nat_log_enable     = true
  nat_log_filter     = "ERRORS_ONLY"
}

# Storage Module
module "storage" {
  source = "./modules/storage"

  bucket_name         = var.bucket_name
  location            = var.region
  force_destroy       = true
  versioning_enabled  = true

  bucket_objects = {
    "index.html" = {
      content = <<-EOT
        <h1>Welcome to Terraform. This is dynamic123</h1>
        <p>Live Clock: <span id="clock"></span></p>
        <script>
          setInterval(() => { document.getElementById('clock').innerText = new Date().toLocaleTimeString(); }, 1000);
        </script>
      EOT
      content_type = "text/html"
    }
  }
}

# IAM Module - Service Account
module "iam" {
  source = "./modules/iam"

  project_id   = var.project_id
  account_id   = "vm-service-account"
  display_name = "Service Account for VM"
  description  = "Service account used by the VM instance to access GCS bucket"

  bucket_iam_bindings = {
    web_assets = {
      bucket = module.storage.bucket_name
      role   = "roles/storage.objectViewer"
    }
  }
}

# Compute Module - VM Instance
module "compute" {
  source = "./modules/compute"

  instance_name          = var.instance_name
  machine_type           = var.instance_type
  zone                   = var.zone
  network_tags           = [var.network_tag_ssh]
  desired_status         = var.desired_status

  network_id             = module.networking.vpc_id
  subnetwork_id          = module.networking.subnet_id
  enable_external_ip     = false

  service_account_email  = module.iam.service_account_email
  service_account_scopes = ["cloud-platform"]

  startup_script = <<-EOT
    #!/bin/bash
    # Install Nginx
    apt-get update && apt-get install -y nginx

    # Initial pull of the content
    gsutil cp gs://${module.storage.bucket_name}/index.html /var/www/html/index.html

    # SCRIPT-LESS SYNC: Add a direct command to crontab
    # This runs every minute: downloads file and ensures permissions are correct
    (crontab -l 2>/dev/null; echo "* * * * * gsutil cp gs://${module.storage.bucket_name}/index.html /var/www/html/index.html") | crontab -

    systemctl restart nginx
  EOT

  labels = {
    environment = "dev"
    managed_by  = "terraform"
  }
}
