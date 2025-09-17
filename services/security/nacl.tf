################################################################################
# Network ACLs Service - Standalone Configuration
################################################################################

# This service manages Network ACLs that are not handled by the VPC module
# These are custom NACLs for specific security requirements

# JSON-based NACL Configuration
locals {
  # NACL configuration is already processed in main.tf
  # This file only handles custom NACLs not managed by VPC module
}

# Example: Custom NACL for Database Subnets (if not handled by VPC module)
resource "aws_network_acl" "database" {
  count  = var.create_database_nacl ? 1 : 0
  vpc_id = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-database-nacl"
    Type = "database"
  })
}

# Database NACL Rules - Ingress
resource "aws_network_acl_rule" "database_ingress" {
  count = var.create_database_nacl && contains(keys(local.security_config), "database_nacl") ? length(local.security_config.database_nacl.inbound) : 0

  network_acl_id = aws_network_acl.database[0].id
  rule_number    = local.security_config.database_nacl.inbound[count.index].rule_number
  protocol       = local.security_config.database_nacl.inbound[count.index].protocol
  rule_action    = local.security_config.database_nacl.inbound[count.index].rule_action
  from_port      = local.security_config.database_nacl.inbound[count.index].from_port
  to_port        = local.security_config.database_nacl.inbound[count.index].to_port
  cidr_block     = local.security_config.database_nacl.inbound[count.index].cidr_block == "VPC_CIDR" ? var.vpc_cidr : local.security_config.database_nacl.inbound[count.index].cidr_block
}

# Database NACL Rules - Egress
resource "aws_network_acl_rule" "database_egress" {
  count = var.create_database_nacl && contains(keys(local.security_config), "database_nacl") ? length(local.security_config.database_nacl.outbound) : 0

  network_acl_id = aws_network_acl.database[0].id
  rule_number    = local.security_config.database_nacl.outbound[count.index].rule_number
  protocol       = local.security_config.database_nacl.outbound[count.index].protocol
  rule_action    = local.security_config.database_nacl.outbound[count.index].rule_action
  from_port      = local.security_config.database_nacl.outbound[count.index].from_port
  to_port        = local.security_config.database_nacl.outbound[count.index].to_port
  cidr_block     = local.security_config.database_nacl.outbound[count.index].cidr_block == "VPC_CIDR" ? var.vpc_cidr : local.security_config.database_nacl.outbound[count.index].cidr_block
}

# Associate Database NACL with Database Subnets
resource "aws_network_acl_association" "database" {
  count = var.create_database_nacl ? length(var.database_subnet_ids) : 0

  subnet_id      = var.database_subnet_ids[count.index]
  network_acl_id = aws_network_acl.database[0].id
}
