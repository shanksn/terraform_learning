# Terraform Modules Documentation

This document explains the modular architecture of this Terraform project.

## Overview

The infrastructure has been organized into reusable modules for better maintainability, scalability, and reusability. Each module is self-contained with its own variables, resources, and outputs.

## Module Structure

```
modules/
├── networking/     # VPC, subnets, firewall, NAT gateway
├── storage/        # GCS buckets and objects
├── iam/           # Service accounts and IAM bindings
└── compute/       # VM instances
```

## Module Details

### 1. Networking Module (`modules/networking/`)

Manages all networking resources including VPC, subnets, firewall rules, and NAT gateway.

#### Resources Created:
- `google_compute_network` - VPC network
- `google_compute_subnetwork` - Subnet
- `google_compute_firewall` - IAP firewall rules
- `google_compute_router` - Cloud Router
- `google_compute_router_nat` - NAT Gateway

#### Input Variables:
| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `vpc_name` | string | Name of the VPC | Required |
| `region` | string | GCP region | Required |
| `subnet_cidr` | string | CIDR range for subnet | Required |
| `iap_network_range` | list(string) | IAP IP range | `["35.235.240.0/20"]` |
| `network_tags` | list(string) | Network tags | Required |
| `allowed_ports` | list(string) | Firewall allowed ports | `["22", "80", "443"]` |
| `nat_log_enable` | bool | Enable NAT logging | `true` |
| `nat_log_filter` | string | NAT log filter | `"ERRORS_ONLY"` |

#### Outputs:
- `vpc_id` - VPC identifier
- `vpc_name` - VPC name
- `subnet_id` - Subnet identifier
- `subnet_name` - Subnet name
- `router_name` - Cloud Router name
- `nat_name` - NAT gateway name

#### Usage Example:
```hcl
module "networking" {
  source = "./modules/networking"

  vpc_name          = "my-vpc"
  region            = "us-central1"
  subnet_cidr       = "10.0.1.0/24"
  network_tags      = ["allow-ssh"]
  allowed_ports     = ["22", "80", "443"]
}
```

### 2. Storage Module (`modules/storage/`)

Manages Google Cloud Storage buckets and objects.

#### Resources Created:
- `google_storage_bucket` - Storage bucket with versioning
- `google_storage_bucket_object` - Bucket objects (dynamic)

#### Input Variables:
| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `bucket_name` | string | Bucket name | Required |
| `location` | string | Bucket location | Required |
| `force_destroy` | bool | Allow deletion with contents | `false` |
| `versioning_enabled` | bool | Enable versioning | `true` |
| `lifecycle_rules` | list(object) | Lifecycle rules | `[]` |
| `bucket_objects` | map(object) | Objects to create | `{}` |

#### Outputs:
- `bucket_name` - Name of the bucket
- `bucket_url` - URL of the bucket
- `bucket_self_link` - Self link
- `object_names` - List of created objects

#### Usage Example:
```hcl
module "storage" {
  source = "./modules/storage"

  bucket_name        = "my-unique-bucket-name"
  location           = "us-central1"
  force_destroy      = true
  versioning_enabled = true

  bucket_objects = {
    "index.html" = {
      content      = "<h1>Hello World</h1>"
      content_type = "text/html"
    }
  }
}
```

### 3. IAM Module (`modules/iam/`)

Manages service accounts and IAM permissions.

#### Resources Created:
- `google_service_account` - Service account
- `google_project_iam_member` - Project-level IAM bindings
- `google_storage_bucket_iam_member` - Bucket-level IAM bindings

#### Input Variables:
| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `project_id` | string | GCP Project ID | Required |
| `account_id` | string | Service account ID | Required |
| `display_name` | string | Display name | Required |
| `description` | string | Description | `""` |
| `project_roles` | list(string) | Project IAM roles | `[]` |
| `bucket_iam_bindings` | map(object) | Bucket IAM bindings | `{}` |

#### Outputs:
- `service_account_email` - Service account email
- `service_account_id` - Service account ID
- `service_account_name` - Service account name
- `service_account_unique_id` - Unique ID

#### Usage Example:
```hcl
module "iam" {
  source = "./modules/iam"

  project_id   = "my-project"
  account_id   = "vm-service-account"
  display_name = "VM Service Account"

  bucket_iam_bindings = {
    web_assets = {
      bucket = module.storage.bucket_name
      role   = "roles/storage.objectViewer"
    }
  }
}
```

### 4. Compute Module (`modules/compute/`)

Manages VM instances with flexible configuration.

#### Resources Created:
- `google_compute_image` (data source) - Ubuntu image
- `google_compute_instance` - VM instance

#### Input Variables:
| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `instance_name` | string | Instance name | Required |
| `machine_type` | string | Machine type | `"e2-medium"` |
| `zone` | string | GCP zone | Required |
| `network_tags` | list(string) | Network tags | `[]` |
| `desired_status` | string | Instance status | `"RUNNING"` |
| `image_family` | string | Image family | `"ubuntu-2404-lts-amd64"` |
| `image_project` | string | Image project | `"ubuntu-os-cloud"` |
| `boot_disk_size` | number | Boot disk size (GB) | `10` |
| `boot_disk_type` | string | Boot disk type | `"pd-standard"` |
| `startup_script` | string | Startup script | `""` |
| `network_id` | string | Network ID | Required |
| `subnetwork_id` | string | Subnetwork ID | Required |
| `enable_external_ip` | bool | Enable external IP | `false` |
| `service_account_email` | string | Service account | Required |
| `service_account_scopes` | list(string) | SA scopes | `["cloud-platform"]` |
| `allow_stopping_for_update` | bool | Allow stopping | `true` |
| `labels` | map(string) | Instance labels | `{}` |

#### Outputs:
- `instance_id` - Instance ID
- `instance_name` - Instance name
- `instance_self_link` - Self link
- `instance_internal_ip` - Internal IP
- `instance_external_ip` - External IP (or "No Public IP")
- `instance_zone` - Instance zone

#### Usage Example:
```hcl
module "compute" {
  source = "./modules/compute"

  instance_name         = "my-vm"
  machine_type          = "e2-standard-2"
  zone                  = "us-central1-c"
  network_tags          = ["allow-ssh"]
  desired_status        = "RUNNING"

  network_id            = module.networking.vpc_id
  subnetwork_id         = module.networking.subnet_id
  enable_external_ip    = false

  service_account_email = module.iam.service_account_email

  startup_script = <<-EOT
    #!/bin/bash
    apt-get update && apt-get install -y nginx
  EOT

  labels = {
    environment = "prod"
    managed_by  = "terraform"
  }
}
```

## Benefits of This Modular Architecture

### 1. **Reusability**
Modules can be reused across different projects or environments:
```hcl
# Dev Environment
module "networking_dev" {
  source      = "./modules/networking"
  vpc_name    = "dev-vpc"
  subnet_cidr = "10.0.1.0/24"
  region      = "us-central1"
}

# Prod Environment
module "networking_prod" {
  source      = "./modules/networking"
  vpc_name    = "prod-vpc"
  subnet_cidr = "10.1.1.0/24"
  region      = "us-east1"
}
```

### 2. **Maintainability**
Changes are isolated to specific modules, reducing the risk of breaking changes.

### 3. **Scalability**
Easy to add new instances or environments:
```hcl
# Add multiple VMs easily
module "web_server_1" {
  source = "./modules/compute"
  instance_name = "web-1"
  # ... other config
}

module "web_server_2" {
  source = "./modules/compute"
  instance_name = "web-2"
  # ... other config
}
```

### 4. **Testing**
Modules can be tested independently before integration.

### 5. **Clear Dependencies**
Module outputs and inputs make dependencies explicit:
```hcl
network_id = module.networking.vpc_id  # Clear dependency
```

## Extending the Modules

### Adding a New Module

1. Create directory: `modules/new_module/`
2. Add files:
   - `main.tf` - Resources
   - `variables.tf` - Input variables
   - `outputs.tf` - Output values
3. Use in main.tf:
```hcl
module "new_module" {
  source = "./modules/new_module"
  # variables
}
```

### Enhancing Existing Modules

#### Add Optional Features
Use dynamic blocks and conditionals:
```hcl
dynamic "access_config" {
  for_each = var.enable_external_ip ? [1] : []
  content {
    # Configuration
  }
}
```

#### Add More Variables
Make modules more configurable by adding variables with sensible defaults.

#### Add Validation
```hcl
variable "instance_type" {
  type = string
  validation {
    condition     = contains(["e2-micro", "e2-small", "e2-medium"], var.instance_type)
    error_message = "Instance type must be e2-micro, e2-small, or e2-medium."
  }
}
```

## Best Practices

1. **Version Your Modules**: Use git tags for module versioning
2. **Document Everything**: Add descriptions to all variables and outputs
3. **Use Defaults Wisely**: Provide sensible defaults but make critical values required
4. **Keep Modules Focused**: Each module should have a single responsibility
5. **Test Modules**: Test modules independently before integration
6. **Use Data Sources**: Fetch existing resources when needed
7. **Output Important Values**: Make module outputs comprehensive
8. **Use Variables for Everything**: Avoid hardcoded values

## Migration from Monolithic to Modular

If you have existing infrastructure:

1. **Create modules** while keeping old code
2. **Test modules** independently with `terraform plan`
3. **Import existing resources** if needed
4. **Gradual migration** - move one resource type at a time
5. **Use terraform state mv** to reorganize state if needed

## Common Patterns

### Multi-Environment Setup
```hcl
# environments/dev/main.tf
module "infrastructure" {
  source = "../../"

  environment = "dev"
  vpc_name    = "dev-vpc"
  # ... dev-specific configs
}

# environments/prod/main.tf
module "infrastructure" {
  source = "../../"

  environment = "prod"
  vpc_name    = "prod-vpc"
  # ... prod-specific configs
}
```

### Count and For_Each with Modules
```hcl
# Create multiple VMs
module "web_servers" {
  source   = "./modules/compute"
  for_each = toset(["web-1", "web-2", "web-3"])

  instance_name = each.key
  # ... other config
}
```

## Troubleshooting

### Module Not Found
```bash
terraform init  # Re-initialize after adding modules
```

### Circular Dependencies
Avoid modules depending on each other. Use outputs and inputs to pass data.

### State Issues
```bash
terraform state list  # List resources
terraform state show module.compute.google_compute_instance.instance
```

## Additional Resources

- [Terraform Module Documentation](https://www.terraform.io/docs/language/modules/index.html)
- [Module Best Practices](https://www.terraform.io/docs/language/modules/develop/index.html)
- [Module Registry](https://registry.terraform.io/)
