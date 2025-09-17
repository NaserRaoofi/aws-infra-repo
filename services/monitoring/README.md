# Monitoring Service Module

This module will contain:

- CloudWatch dashboards
- CloudWatch alarms
- SNS topics
- Log Groups
- X-Ray tracing

## Usage

Uncomment the monitoring module in `main.tf` and set `enable_monitoring = true` in `terraform.tfvars`

```hcl
module "monitoring" {
  source = "./services/monitoring"

  # Common variables
  environment = local.environment
  name_prefix = local.name_prefix
  common_tags = local.common_tags
}
```
