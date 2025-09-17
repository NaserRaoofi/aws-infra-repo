################################################################################
# Security Service Variables
################################################################################

variable "name_prefix" {
  description = "Name prefix for all security resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block for security group rules"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# NACL Variables
################################################################################

variable "create_default_nacl" {
  description = "Whether to manage default NACL rules"
  type        = bool
  default     = false
}

variable "create_public_nacl" {
  description = "Whether to create dedicated public subnet NACLs"
  type        = bool
  default     = false
}

variable "create_private_nacl" {
  description = "Whether to create dedicated private subnet NACLs"
  type        = bool
  default     = false
}

variable "create_database_nacl" {
  description = "Whether to create custom database NACL"
  type        = bool
  default     = false
}

variable "database_subnet_ids" {
  description = "List of database subnet IDs for NACL association"
  type        = list(string)
  default     = []
}

################################################################################
# Security Group Enable/Disable Flags
################################################################################

variable "create_alb_sg" {
  description = "Whether to create ALB security group"
  type        = bool
  default     = true
}

variable "create_eks_nodes_sg" {
  description = "Whether to create EKS nodes security group"
  type        = bool
  default     = true
}

variable "create_bastion_sg" {
  description = "Whether to create bastion security group"
  type        = bool
  default     = true
}

variable "create_database_sg" {
  description = "Whether to create database security group"
  type        = bool
  default     = true
}

variable "create_vpc_endpoints_sg" {
  description = "Whether to create VPC endpoints security group"
  type        = bool
  default     = true
}
