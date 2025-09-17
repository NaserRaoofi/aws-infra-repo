################################################################################
# Networking Service - Main Configuration
################################################################################

# This service manages all networking resources for the environment
# It calls the VPC module with environment-specific configuration



module "vpc" {
  source = "github.com/NaserRaoofi/terraform-aws-modules//modules/networking?ref=main"

  # ================================
  # ✅ ENABLED RESOURCES
  # ================================

  # Basic VPC Configuration
  name = var.name_prefix
  cidr = var.vpc_cidr

  # Availability Zones - Multiple AZs required for EKS
  azs = [var.azs[0], var.azs[1]]  # Use first two AZs

  # Subnets - Two public and two private subnets for EKS
  public_subnets  = [cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 3)]   # e.g., 10.0.1.0/24, 10.0.3.0/24
  private_subnets = [cidrsubnet(var.vpc_cidr, 8, 2), cidrsubnet(var.vpc_cidr, 8, 4)]   # e.g., 10.0.2.0/24, 10.0.4.0/24

  # Internet connectivity - Essential for public subnet
  map_public_ip_on_launch = true  # Auto-assign public IPs in public subnet

  # Internet Gateway - Required for public subnet internet access
  create_igw = true
    # NAT Gateway disabled; rely on VPC endpoints + bastion for private access
  single_nat_gateway = true
  # DNS - Essential for proper hostname resolution
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Route tables - Best practice configuration
  manage_default_route_table = true
  default_route_table_tags = {
    Name = "${var.name_prefix}-default-rt"
  }



  # Tags
  tags = var.common_tags
  vpc_tags = {
    Name = "${var.name_prefix}-vpc"
  }

  public_subnet_tags = {
    Name = "${var.name_prefix}-public-subnet"
    Type = "public"
    Tier = "public"
    "kubernetes.io/role/elb" = "1"  # For future ALB use
  }

  private_subnet_tags = {
    Name = "${var.name_prefix}-private-subnet"
    Type = "private"
    Tier = "private"
    "kubernetes.io/role/internal-elb" = "1"  # For future internal LB use
  }

  public_route_table_tags = {
    Name = "${var.name_prefix}-public-rt"
  }

  private_route_table_tags = {
    Name = "${var.name_prefix}-private-rt"
  }

  # ================================
  # ❌ EXPLICITLY DISABLED RESOURCES
  # ================================
  create_egress_only_igw = false
  create_elasticache_subnet_group = false  # Default: true
  create_redshift_subnet_group = false
  # NAT Gateway - ENABLED (single NAT for cost optimization)
  enable_nat_gateway = true

  # ================================
  # 🛡️ SECURITY FLAGS
  # ================================
  putin_khuylo = true  # Required for module to work
}

################################################################################
# VPC Endpoints for EKS without NAT Gateway
################################################################################

module "vpc_endpoints" {
  source = "github.com/NaserRaoofi/terraform-aws-modules//modules/networking/modules/vpc-endpoints?ref=main"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Use centralized security group from security service
  create_security_group      = true
  security_group_ids         = [module.security.vpc_endpoints_security_group_id]

  # Essential endpoints for EKS
  endpoints = {
    # S3 Gateway endpoint for ECR images (free)
    s3 = {
      service = "s3"
      service_type = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags = { Name = "${var.name_prefix}-s3-gateway" }
    }

    # Interface endpoints (cost money but necessary for EKS)
    ec2 = {
      service = "ec2"
      private_dns_enabled = true
      tags = { Name = "${var.name_prefix}-ec2" }
    }

    ecr_api = {
      service = "ecr.api"
      private_dns_enabled = true
      tags = { Name = "${var.name_prefix}-ecr-api" }
    }

    ecr_dkr = {
      service = "ecr.dkr"
      private_dns_enabled = true
      tags = { Name = "${var.name_prefix}-ecr-dkr" }
    }

    eks = {
      service = "eks"
      private_dns_enabled = true
      tags = { Name = "${var.name_prefix}-eks" }
    }




  }

  tags = var.common_tags
}

################################################################################
# Security Groups from Security Service
################################################################################

# Call security service to create security groups with VPC ID
module "security" {
  source = "../security"

  # Pass required variables to security service
  name_prefix = var.name_prefix
  vpc_id      = module.vpc.vpc_id  # Now VPC is created
  vpc_cidr    = var.vpc_cidr
  common_tags = var.common_tags

  # ================================
  # 🛡️ NETWORK ACL CONFIGURATION
  # ================================
  # NACL Controls - Set to true/false as needed (these are processed from JSON)
  create_default_nacl  = false     # Enable for default NACL management
  create_public_nacl   = false     # Enable for public subnet dedicated NACLs
  create_private_nacl  = false     # Enable for private subnet dedicated NACLs
  create_database_nacl = false     # Enable for database subnet NACLs
  database_subnet_ids  = []        # Pass database subnet IDs when enabled

  # ================================
  # 🛡️ SECURITY GROUP CONFIGURATION
  # ================================
  # Individual Security Group Controls - Set to true/false as needed
  create_alb_sg           = false   # Enable for Application Load Balancer
  create_eks_nodes_sg     = true    # Enable for EKS worker nodes
  create_bastion_sg       = false   # Enable for bastion host
  create_database_sg      = false   # Enable for RDS databases
  create_vpc_endpoints_sg = true    # Enable for VPC endpoints (needed for current setup)
}
