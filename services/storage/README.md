# Storage Service Module

This module will contain:

- RDS databases
- S3 buckets
- EFS file systems
- ElastiCache clusters
- DynamoDB tables

## Usage

Uncomment the storage module in `main.tf` and set `enable_storage = true` in `terraform.tfvars`

```hcl
module "storage" {
  source = "./services/storage"

  # Dependencies
  vpc_id                    = module.networking.vpc_id
  database_subnet_group_name = module.networking.database_subnet_group_name

  # Common variables
  environment = local.environment
  name_prefix = local.name_prefix
  common_tags = local.common_tags
}
```
