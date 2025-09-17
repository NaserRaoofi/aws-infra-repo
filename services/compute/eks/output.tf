################################################################################
# EKS Service Outputs
################################################################################

output "cluster_name" {
	description = "EKS cluster name"
	value       = module.eks.cluster_name
}

output "cluster_arn" {
	description = "EKS cluster ARN"
	value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
	description = "Kubernetes API endpoint"
	value       = module.eks.cluster_endpoint
}

output "cluster_version" {
	description = "Kubernetes version"
	value       = module.eks.cluster_version
}

output "cluster_oidc_issuer_url" {
	description = "OIDC issuer URL"
	value       = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
	description = "IRSA OIDC provider ARN"
	value       = module.eks.oidc_provider_arn
}

output "node_security_group_id" {
	description = "Shared node security group ID"
	value       = module.eks.node_security_group_id
}

output "eks_managed_node_groups" {
	description = "Map of EKS managed node groups"
	value       = module.eks.eks_managed_node_groups
}
