################################################################################
# Networking Service Variables
################################################################################

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "name_prefix" {
  description = "Naming prefix for resources"
  type        = string
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway"
  type        = bool
  default     = true
}

variable "enable_flow_log" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

################################################################################
# Security Group Control Variables
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

################################################################################
# Network ACL Control Variables
################################################################################

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
