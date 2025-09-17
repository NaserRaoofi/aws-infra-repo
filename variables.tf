################################################################################
# Environment Variables
################################################################################

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "my-project"
}

variable "cost_center" {
  description = "Cost center for billing and tagging"
  type        = string
  default     = "engineering"
}

################################################################################
# Networking Variables
################################################################################

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

################################################################################
# Security Configuration Variables
################################################################################

variable "create_alb_sg" {
  description = "Create Application Load Balancer security group"
  type        = bool
  default     = false
}

variable "create_eks_nodes_sg" {
  description = "Create EKS worker nodes security group"
  type        = bool
  default     = false
}

variable "create_bastion_sg" {
  description = "Create bastion host security group"
  type        = bool
  default     = false
}

variable "create_database_sg" {
  description = "Create database security group"
  type        = bool
  default     = false
}

variable "create_vpc_endpoints_sg" {
  description = "Create VPC endpoints security group"
  type        = bool
  default     = false
}

variable "create_default_nacl" {
  description = "Create and manage default NACL rules"
  type        = bool
  default     = false
}

variable "create_public_nacl" {
  description = "Create dedicated NACL for public subnets"
  type        = bool
  default     = false
}

variable "create_private_nacl" {
  description = "Create dedicated NACL for private subnets"
  type        = bool
  default     = false
}

variable "create_database_nacl" {
  description = "Create dedicated NACL for database subnets"
  type        = bool
  default     = false
}

variable "database_subnet_ids" {
  description = "List of database subnet IDs for NACL association"
  type        = list(string)
  default     = []
}

