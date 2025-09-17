################################################################################
# EKS Service Variables
################################################################################

variable "create" {
  description = "Controls if the EKS resources should be created (safety default: false)"
  type        = bool
  default     = false
}

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

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

variable "region" {
  description = "AWS region for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the cluster will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for control plane and nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs (optional, for public nodegroup if desired)"
  type        = list(string)
  default     = []
}

variable "cluster_version" {
  description = "Kubernetes version for the cluster"
  type        = string
  default     = null
}

variable "enable_irsa" {
  description = "Enable IRSA (OIDC provider)"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether to enable the public Kubernetes API endpoint"
  type        = bool
  default     = true
}

variable "enabled_log_types" {
  description = "Control plane log types to enable (empty disables logging to honor 'no logs' default)"
  type        = list(string)
  default     = []
}

variable "addons" {
  description = "Map of EKS addons configuration"
  type        = any
  default     = null
}
