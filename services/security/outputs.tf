################################################################################
# Security Service Outputs
################################################################################

################################################################################
# Processed NACL Rules for VPC Module
################################################################################

output "default_network_acl_ingress" {
  description = "Processed default network ACL ingress rules"
  value       = local.default_network_acl_ingress_processed
}

output "default_network_acl_egress" {
  description = "Processed default network ACL egress rules"
  value       = local.default_network_acl_egress_processed
}

output "public_inbound_acl_rules" {
  description = "Processed public subnet inbound ACL rules"
  value       = local.public_inbound_acl_rules_processed
}

output "public_outbound_acl_rules" {
  description = "Processed public subnet outbound ACL rules"
  value       = local.public_outbound_acl_rules_processed
}

output "private_inbound_acl_rules" {
  description = "Processed private subnet inbound ACL rules"
  value       = local.private_inbound_acl_rules_processed
}

output "private_outbound_acl_rules" {
  description = "Processed private subnet outbound ACL rules"
  value       = local.private_outbound_acl_rules_processed
}

################################################################################
# Security Group Outputs
################################################################################

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = var.create_alb_sg ? try(aws_security_group.alb[0].id, null) : null
}

output "eks_nodes_security_group_id" {
  description = "ID of the EKS nodes security group"
  value       = var.create_eks_nodes_sg ? try(aws_security_group.eks_nodes[0].id, null) : null
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = var.create_bastion_sg ? try(aws_security_group.bastion[0].id, null) : null
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = var.create_database_sg ? try(aws_security_group.database[0].id, null) : null
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the VPC endpoints security group"
  value       = var.create_vpc_endpoints_sg ? try(aws_security_group.vpc_endpoints[0].id, null) : null
}

################################################################################
# Security Group ARNs
################################################################################

output "alb_security_group_arn" {
  description = "ARN of the ALB security group"
  value       = try(aws_security_group.alb[0].arn, null)
}

output "eks_nodes_security_group_arn" {
  description = "ARN of the EKS nodes security group"
  value       = try(aws_security_group.eks_nodes[0].arn, null)
}

output "bastion_security_group_arn" {
  description = "ARN of the bastion security group"
  value       = try(aws_security_group.bastion[0].arn, null)
}

output "database_security_group_arn" {
  description = "ARN of the database security group"
  value       = try(aws_security_group.database[0].arn, null)
}

output "vpc_endpoints_security_group_arn" {
  description = "ARN of the VPC endpoints security group"
  value       = try(aws_security_group.vpc_endpoints[0].arn, null)
}

################################################################################
# NACL Outputs
################################################################################

output "database_nacl_id" {
  description = "ID of the database NACL"
  value       = try(aws_network_acl.database[0].id, null)
}

output "database_nacl_arn" {
  description = "ARN of the database NACL"
  value       = try(aws_network_acl.database[0].arn, null)
}
