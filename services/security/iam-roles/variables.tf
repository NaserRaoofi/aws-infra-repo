# Variables for ALB Controller IAM Role

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "my-project"
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  type        = string
  # This should be provided or retrieved from the EKS cluster configuration
}

variable "service_account_namespace" {
  description = "Namespace for the AWS Load Balancer Controller service account"
  type        = string
  default     = "aws-load-balancer-system"
}

variable "service_account_name" {
  description = "Name of the AWS Load Balancer Controller service account"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
  }
}
