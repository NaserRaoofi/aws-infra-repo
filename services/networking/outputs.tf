################################################################################
# VPC Endpoints
################################################################################

output "vpc_endpoints" {
  description = "VPC endpoints information"
  value       = module.vpc_endpoints.endpoints
}

################################################################################
# Security Groups (from Security Service)
################################################################################

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = module.security.alb_security_group_id
}

output "eks_nodes_security_group_id" {
  description = "ID of the EKS nodes security group"
  value       = module.security.eks_nodes_security_group_id
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = module.security.bastion_security_group_id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = module.security.database_security_group_id
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the VPC endpoints security group"
  value       = module.security.vpc_endpoints_security_group_id
}

################################################################################
# VPC
################################################################################

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.vpc.vpc_arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

################################################################################
# Subnets
################################################################################

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
}

output "database_subnet_group_name" {
  description = "Name of database subnet group"
  value       = module.vpc.database_subnet_group_name
}

################################################################################
# Internet Gateway
################################################################################

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.igw_id
}

################################################################################
# NAT Gateway
################################################################################

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

################################################################################
# Route Tables
################################################################################

output "private_route_table_ids" {
  description = "List of IDs of the private route tables"
  value       = module.vpc.private_route_table_ids
}

output "public_route_table_ids" {
  description = "List of IDs of the public route tables"
  value       = module.vpc.public_route_table_ids
}
