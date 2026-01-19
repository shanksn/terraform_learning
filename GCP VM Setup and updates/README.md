# GCP VM Setup and Updates

A comprehensive Terraform configuration for deploying and managing Google Cloud Platform (GCP) virtual machines with custom networking, web hosting capabilities, and secure access controls.

## Overview

This Terraform project creates a complete GCP infrastructure including:
- Custom VPC network with subnet
- Ubuntu-based Compute Engine VM instance
- Google Cloud Storage bucket for web assets
- Nginx web server with auto-sync capabilities
- IAP (Identity-Aware Proxy) secured access
- Cloud NAT for outbound internet connectivity
- Service Account with appropriate permissions

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    GCP Project                       │
│                                                      │
│  ┌────────────────────────────────────────────┐    │
│  │          Custom VPC Network                 │    │
│  │                                              │    │
│  │  ┌──────────────────────────────────────┐  │    │
│  │  │    Custom Subnet (10.0.1.0/24)       │  │    │
│  │  │                                        │  │    │
│  │  │  ┌─────────────────────────────────┐ │  │    │
│  │  │  │  VM Instance (Ubuntu 24.04 LTS) │ │  │    │
│  │  │  │  - Nginx Web Server             │ │  │    │
│  │  │  │  - No Public IP                 │ │  │    │
│  │  │  │  - IAP Access Only              │ │  │    │
│  │  │  └─────────────────────────────────┘ │  │    │
│  │  └──────────────────────────────────────┘  │    │
│  │                                              │    │
│  │  Cloud Router + NAT Gateway                 │    │
│  └────────────────────────────────────────────┘    │
│                                                      │
│  ┌────────────────────────────────────────────┐    │
│  │   Cloud Storage Bucket (Versioned)         │    │
│  │   - Web Assets (index.html)                 │    │
│  └────────────────────────────────────────────┘    │
│                                                      │
│  IAP Firewall Rules (35.235.240.0/20)              │
│  - SSH (Port 22)                                    │
│  - HTTP (Port 80)                                   │
└─────────────────────────────────────────────────────┘
```

## Features

### Security
- **IAP-Only Access**: VM has no public IP; accessible only through Google's Identity-Aware Proxy
- **Firewall Rules**: Restricted to IAP source ranges (35.235.240.0/20)
- **Service Account**: Dedicated service account with minimal permissions (Storage Object Viewer)
- **Cloud NAT**: Enables outbound internet access without exposing the VM

### Web Hosting
- **Nginx Server**: Automatically installed and configured
- **Auto-Sync**: Content syncs from GCS bucket every minute via cron
- **Version Control**: GCS bucket versioning enabled for web assets
- **Dynamic Content**: Includes a live JavaScript clock in the default page

### Infrastructure
- **Custom Networking**: Dedicated VPC with custom subnet
- **Latest Ubuntu**: Uses Ubuntu 24.04 LTS from official Google images
- **Configurable**: Fully parameterized through variables

## Prerequisites

1. **Google Cloud Platform Account**
2. **GCP Project** with billing enabled
3. **Terraform** installed (v1.0 or later)
4. **gcloud CLI** installed and authenticated
5. **Required GCP APIs** enabled:
   - Compute Engine API
   - Cloud Storage API
   - IAM API
   - Cloud Resource Manager API

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/shanksn/terraform_learning.git
cd terraform_learning/GCP\ VM\ Setup\ and\ updates/
```

### 2. Configure Variables

Edit `variables.tf` or create a `terraform.tfvars` file:

```hcl
project_id    = "your-project-id"
region        = "us-central1"
zone          = "us-central1-c"
instance_name = "your-vm-name"
bucket_name   = "your-unique-bucket-name"
```

### 3. Authenticate with GCP

```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Plan the Deployment

```bash
terraform plan
```

### 6. Apply the Configuration

```bash
terraform apply
```

### 7. Access the VM

Using IAP tunnel:
```bash
gcloud compute ssh biotech-app-server --zone=us-central1-c --tunnel-through-iap
```

Access the web server through IAP:
```bash
gcloud compute start-iap-tunnel biotech-app-server 80 --local-host-port=localhost:8080 --zone=us-central1-c
```

Then visit `http://localhost:8080` in your browser.

## Configuration

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_id` | GCP Project ID | `biotechproject-483505` |
| `region` | GCP Region | `us-central1` |
| `zone` | GCP Zone | `us-central1-c` |
| `instance_name` | VM instance name | `biotech-app-server` |
| `instance_type` | Machine type | `e2-standard-2` |
| `vpc_name` | VPC network name | `biotech-main-vpc` |
| `subnet_cidr` | Subnet CIDR range | `10.0.1.0/24` |
| `network_tag_ssh` | Network tag for SSH access | `allow-ssh-iap` |
| `iap_network_range` | IAP source IP range | `["35.235.240.0/20"]` |
| `bucket_name` | GCS bucket name | `biotech-web-assets-4835051234` |

### Outputs

| Output | Description |
|--------|-------------|
| `instance_internal_ip` | Internal IP address of the VM |
| `instance_external_ip` | External IP (shows "No Public IP" in this config) |

## File Structure

```
.
├── main.tf              # Main infrastructure resources
├── variables.tf         # Input variables
├── outputs.tf          # Output values
├── terraform.tf        # Terraform and provider configuration
├── updatevpc/
│   └── update_vpc.tf   # Alternative VPC configuration example
└── README.md           # This file
```

## Resources Created

1. **Networking**
   - `google_compute_network` - Custom VPC
   - `google_compute_subnetwork` - Custom subnet
   - `google_compute_router` - Cloud Router
   - `google_compute_router_nat` - NAT Gateway
   - `google_compute_firewall` - IAP firewall rules

2. **Compute**
   - `google_compute_instance` - VM instance with Ubuntu 24.04 LTS

3. **Storage**
   - `google_storage_bucket` - Versioned bucket for web assets
   - `google_storage_bucket_object` - HTML file

4. **IAM**
   - `google_service_account` - VM service account
   - `google_storage_bucket_iam_member` - Storage permissions

## Web Content Management

The VM automatically syncs content from the GCS bucket:

### Update Web Content

1. Update the content in `main.tf` under `google_storage_bucket_object.index_html`
2. Apply changes: `terraform apply`
3. Wait up to 1 minute for the cron job to sync

### Manual Sync

SSH into the VM and run:
```bash
gsutil cp gs://YOUR_BUCKET_NAME/index.html /var/www/html/index.html
```

## VM Status Management

The VM is configured with `desired_status = "TERMINATED"` by default (line 65 in main.tf). To start the VM:

```bash
# Start the VM
gcloud compute instances start biotech-app-server --zone=us-central1-c

# Or change desired_status to "RUNNING" in main.tf and apply
```

## Troubleshooting

### VM Not Accessible
- Ensure IAP tunnel is established
- Verify firewall rules are applied
- Check VM is in RUNNING state

### Web Server Not Responding
- SSH to VM and check nginx status: `sudo systemctl status nginx`
- Check nginx logs: `sudo tail -f /var/log/nginx/error.log`
- Verify cron job: `crontab -l`

### Content Not Syncing
- Verify service account has Storage Object Viewer role
- Check cron logs: `grep CRON /var/log/syslog`
- Manually test: `gsutil cp gs://BUCKET_NAME/index.html /tmp/test.html`

### NAT Issues
- Check NAT configuration: `gcloud compute routers get-status biotech-router --region=us-central1`
- Verify Cloud Router is in the correct region

## Cost Considerations

Estimated monthly costs (as of 2025):
- VM Instance (e2-standard-2): ~$48/month
- Cloud Storage: ~$0.02/GB/month
- NAT Gateway: ~$0.044/hour + data processing charges
- Network egress: Variable based on usage

Use the [GCP Pricing Calculator](https://cloud.google.com/products/calculator) for accurate estimates.

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

Note: The storage bucket is configured with `force_destroy = true`, so it will be deleted with all contents.

## Security Best Practices

1. Never commit service account keys to version control
2. Use least privilege IAM roles
3. Regularly rotate service account keys
4. Enable VPC Flow Logs for network monitoring
5. Use Secret Manager for sensitive data
6. Review IAM policies regularly
7. Enable GCP Security Command Center

## Additional Resources

- [Terraform GCP Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GCP IAP Documentation](https://cloud.google.com/iap/docs)
- [GCP Cloud NAT Documentation](https://cloud.google.com/nat/docs)
- [GCP Compute Engine Documentation](https://cloud.google.com/compute/docs)

## License

This project is provided as-is for educational purposes.

## Contributing

Feel free to submit issues and enhancement requests!

## Author

Created as part of Terraform learning journey.
