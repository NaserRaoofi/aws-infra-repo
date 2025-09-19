 ################################################################################
# Development Environment Main Configuration
################################################################################

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}


# Local values for common configuration
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # Availability zones - first 2 AZs in the region
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # Common tags for all resources
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    CostCenter  = var.cost_center
    ManagedBy   = "terraform"
    Owner       = "Naser"
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

################################################################################
# Service Modules
################################################################################

# Networking Service (Always enabled - core infrastructure)
module "networking" {
  source = "./services/networking"

  # Environment configuration
  environment  = var.environment
  project_name = var.project_name
  name_prefix  = local.name_prefix
  azs          = local.azs
  common_tags  = local.common_tags

  # Networking configuration
  vpc_cidr = var.vpc_cidr
}


# Compute - EKS (enabled)

module "eks" {
  source = "./services/compute/eks"

  # Safety switch
  create = true

  # Env
  environment  = var.environment
  project_name = var.project_name
  name_prefix  = local.name_prefix
  common_tags  = local.common_tags
  region       = var.aws_region

  # Networking
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnets
  public_subnet_ids  = module.networking.public_subnets

  # Cluster settings
  cluster_version        = "1.33"
  enable_irsa            = true
  endpoint_public_access = true  # Enable both public and private access
  enabled_log_types      = []

  # Addons (can be overridden at call site)
  addons = null
}

# TODO: Add other services when ready (storage, monitoring, etc.)
