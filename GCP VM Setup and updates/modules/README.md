# Terraform Modules

This directory contains reusable Terraform modules for GCP infrastructure.

## Available Modules

- **[networking](./networking/)** - VPC, subnets, firewall rules, and NAT gateway
- **[storage](./storage/)** - Google Cloud Storage buckets and objects
- **[iam](./iam/)** - Service accounts and IAM bindings
- **[compute](./compute/)** - VM instances with flexible configuration

## Quick Start

Each module can be used independently in your Terraform configuration:

```hcl
module "example" {
  source = "./modules/module_name"

  # Required variables
  # ...
}
```

See each module's directory for detailed documentation and usage examples.

## Module Structure

Each module follows this standard structure:

```
module_name/
├── main.tf       # Resource definitions
├── variables.tf  # Input variables
└── outputs.tf    # Output values
```

## Documentation

For comprehensive documentation on using these modules, see [../MODULES.md](../MODULES.md).
