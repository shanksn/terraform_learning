# Fetch latest Ubuntu image
data "google_compute_image" "ubuntu" {
  family  = var.image_family
  project = var.image_project
}

# VM Instance
resource "google_compute_instance" "instance" {
  name           = var.instance_name
  machine_type   = var.machine_type
  zone           = var.zone
  tags           = var.network_tags
  desired_status = var.desired_status

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  metadata = {
    startup-script = var.startup_script
  }

  network_interface {
    network    = var.network_id
    subnetwork = var.subnetwork_id

    dynamic "access_config" {
      for_each = var.enable_external_ip ? [1] : []
      content {
        # Ephemeral external IP
      }
    }
  }

  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }

  allow_stopping_for_update = var.allow_stopping_for_update

  labels = var.labels
}
