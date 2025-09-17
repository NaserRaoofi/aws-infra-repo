################################################################################
# Security Groups Service - Fixed Circular Dependency
################################################################################

# This service manages all custom security groups for the environment
# Security groups are created first, then rules are added separately to avoid cycles

################################################################################
# Security Groups (Base Resources)
################################################################################

# Application Load Balancer Security Group
resource "aws_security_group" "alb" {
  count = local.create_security_groups && var.create_alb_sg ? 1 : 0

  name_prefix = "${var.name_prefix}-alb-"
  description = local.security_config.security_groups.alb.description
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-alb-sg"
    Type = "ALB"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# EKS Nodes Security Group
resource "aws_security_group" "eks_nodes" {
  count = local.create_security_groups && var.create_eks_nodes_sg ? 1 : 0

  name_prefix = "${var.name_prefix}-eks-nodes-"
  description = local.security_config.security_groups.eks_nodes.description
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-eks-nodes-sg"
    Type = "EKS-Nodes"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Bastion Host Security Group
resource "aws_security_group" "bastion" {
  count = local.create_security_groups && var.create_bastion_sg ? 1 : 0

  name_prefix = "${var.name_prefix}-bastion-"
  description = local.security_config.security_groups.bastion.description
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-bastion-sg"
    Type = "Bastion"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Database Security Group
resource "aws_security_group" "database" {
  count = local.create_security_groups && var.create_database_sg ? 1 : 0

  name_prefix = "${var.name_prefix}-database-"
  description = local.security_config.security_groups.database.description
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-database-sg"
    Type = "Database"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# VPC Endpoints Security Group
resource "aws_security_group" "vpc_endpoints" {
  count = local.create_security_groups && var.create_vpc_endpoints_sg ? 1 : 0

  name_prefix = "${var.name_prefix}-vpc-endpoints-"
  description = local.security_config.security_groups.vpc_endpoints.description
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpc-endpoints-sg"
    Type = "VPC-Endpoints"
  })

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Security Groups Map (After resources are created)
################################################################################

locals {
  # Security Groups map for cross-references (created after SGs exist)
  security_groups_map = {
    alb           = var.create_alb_sg && local.create_security_groups ? aws_security_group.alb[0].id : null
    eks_nodes     = var.create_eks_nodes_sg && local.create_security_groups ? aws_security_group.eks_nodes[0].id : null
    bastion       = var.create_bastion_sg && local.create_security_groups ? aws_security_group.bastion[0].id : null
    database      = var.create_database_sg && local.create_security_groups ? aws_security_group.database[0].id : null
    vpc_endpoints = var.create_vpc_endpoints_sg && local.create_security_groups ? aws_security_group.vpc_endpoints[0].id : null
  }
}

################################################################################
# Security Group Rules (Separate Resources)
################################################################################

# ALB Ingress Rules
resource "aws_security_group_rule" "alb_ingress" {
  for_each = {
    for idx, rule in local.security_config.security_groups.alb.ingress : "${idx}" => rule
    if local.create_security_groups && var.create_alb_sg && (
      (lookup(rule, "cidr_blocks", null) != null && length(rule.cidr_blocks) > 0) ||
      (lookup(rule, "source_security_group", null) != null && try(local.security_groups_map[rule.source_security_group] != null, false))
    )
  }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = each.value.description
  security_group_id = aws_security_group.alb[0].id

  # Handle CIDR blocks
  cidr_blocks = lookup(each.value, "cidr_blocks", null) != null ? [
    for cidr in each.value.cidr_blocks : cidr == "VPC_CIDR" ? var.vpc_cidr : cidr
  ] : null

  # Handle source security group
  source_security_group_id = lookup(each.value, "source_security_group", null) != null ? local.security_groups_map[each.value.source_security_group] : null
}

# ALB Egress Rules
resource "aws_security_group_rule" "alb_egress" {
  for_each = {
    for idx, rule in local.security_config.security_groups.alb.egress : "${idx}" => rule
    if local.create_security_groups && var.create_alb_sg && (
      (lookup(rule, "cidr_blocks", null) != null && length(rule.cidr_blocks) > 0) ||
      (lookup(rule, "source_security_group", null) != null && try(local.security_groups_map[rule.source_security_group] != null, false))
    )
  }

  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = each.value.description
  security_group_id = aws_security_group.alb[0].id

  cidr_blocks = lookup(each.value, "cidr_blocks", null) != null ? [
    for cidr in each.value.cidr_blocks : cidr == "VPC_CIDR" ? var.vpc_cidr : cidr
  ] : null

  source_security_group_id = lookup(each.value, "source_security_group", null) != null ? local.security_groups_map[each.value.source_security_group] : null
}

# EKS Nodes Ingress Rules
resource "aws_security_group_rule" "eks_nodes_ingress" {
  for_each = {
    for idx, rule in local.security_config.security_groups.eks_nodes.ingress : "${idx}" => rule
    if var.create_eks_nodes_sg && (
      (lookup(rule, "cidr_blocks", null) != null && length(rule.cidr_blocks) > 0) ||
      (lookup(rule, "source_security_group", null) != null && try(local.security_groups_map[rule.source_security_group] != null, false))
    )
  }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = each.value.description
  security_group_id = aws_security_group.eks_nodes[0].id

  cidr_blocks = lookup(each.value, "cidr_blocks", null) != null ? [
    for cidr in each.value.cidr_blocks : cidr == "VPC_CIDR" ? var.vpc_cidr : cidr
  ] : null

  source_security_group_id = lookup(each.value, "source_security_group", null) != null ? local.security_groups_map[each.value.source_security_group] : null
}

# EKS Nodes Egress Rules
resource "aws_security_group_rule" "eks_nodes_egress" {
  for_each = {
    for idx, rule in local.security_config.security_groups.eks_nodes.egress : "${idx}" => rule
    if var.create_eks_nodes_sg && (
      (lookup(rule, "cidr_blocks", null) != null && length(rule.cidr_blocks) > 0) ||
      (lookup(rule, "source_security_group", null) != null && try(local.security_groups_map[rule.source_security_group] != null, false))
    )
  }

  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = each.value.description
  security_group_id = aws_security_group.eks_nodes[0].id

  cidr_blocks = lookup(each.value, "cidr_blocks", null) != null ? [
    for cidr in each.value.cidr_blocks : cidr == "VPC_CIDR" ? var.vpc_cidr : cidr
  ] : null

  source_security_group_id = lookup(each.value, "source_security_group", null) != null ? local.security_groups_map[each.value.source_security_group] : null
}

# Bastion Ingress Rules
resource "aws_security_group_rule" "bastion_ingress" {
  for_each = {
    for idx, rule in local.security_config.security_groups.bastion.ingress : "${idx}" => rule
    if local.create_security_groups && var.create_bastion_sg && (
      (lookup(rule, "cidr_blocks", null) != null && length(rule.cidr_blocks) > 0) ||
      (lookup(rule, "source_security_group", null) != null && try(local.security_groups_map[rule.source_security_group] != null, false))
    )
  }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = each.value.description
  security_group_id = aws_security_group.bastion[0].id

  cidr_blocks = lookup(each.value, "cidr_blocks", null) != null ? [
    for cidr in each.value.cidr_blocks : cidr == "VPC_CIDR" ? var.vpc_cidr : cidr
  ] : null

  source_security_group_id = lookup(each.value, "source_security_group", null) != null ? local.security_groups_map[each.value.source_security_group] : null
}

# Bastion Egress Rules
resource "aws_security_group_rule" "bastion_egress" {
  for_each = {
    for idx, rule in local.security_config.security_groups.bastion.egress : "${idx}" => rule
    if local.create_security_groups && var.create_bastion_sg && (
      (lookup(rule, "cidr_blocks", null) != null && length(rule.cidr_blocks) > 0) ||
      (lookup(rule, "source_security_group", null) != null && try(local.security_groups_map[rule.source_security_group] != null, false))
    )
  }

  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = each.value.description
  security_group_id = aws_security_group.bastion[0].id

  cidr_blocks = lookup(each.value, "cidr_blocks", null) != null ? [
    for cidr in each.value.cidr_blocks : cidr == "VPC_CIDR" ? var.vpc_cidr : cidr
  ] : null

  source_security_group_id = lookup(each.value, "source_security_group", null) != null ? local.security_groups_map[each.value.source_security_group] : null
}

# Database Ingress Rules
resource "aws_security_group_rule" "database_ingress" {
  for_each = {
    for idx, rule in local.security_config.security_groups.database.ingress : "${idx}" => rule
    if local.create_security_groups && var.create_database_sg && (
      (lookup(rule, "cidr_blocks", null) != null && length(rule.cidr_blocks) > 0) ||
      (lookup(rule, "source_security_group", null) != null && try(local.security_groups_map[rule.source_security_group] != null, false))
    )
  }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = each.value.description
  security_group_id = aws_security_group.database[0].id

  cidr_blocks = lookup(each.value, "cidr_blocks", null) != null ? [
    for cidr in each.value.cidr_blocks : cidr == "VPC_CIDR" ? var.vpc_cidr : cidr
  ] : null

  source_security_group_id = lookup(each.value, "source_security_group", null) != null ? local.security_groups_map[each.value.source_security_group] : null
}

# Database Egress Rules
resource "aws_security_group_rule" "database_egress" {
  for_each = {
    for idx, rule in local.security_config.security_groups.database.egress : "${idx}" => rule
    if local.create_security_groups && var.create_database_sg && (
      (lookup(rule, "cidr_blocks", null) != null && length(rule.cidr_blocks) > 0) ||
      (lookup(rule, "source_security_group", null) != null && try(local.security_groups_map[rule.source_security_group] != null, false))
    )
  }

  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = each.value.description
  security_group_id = aws_security_group.database[0].id

  cidr_blocks = lookup(each.value, "cidr_blocks", null) != null ? [
    for cidr in each.value.cidr_blocks : cidr == "VPC_CIDR" ? var.vpc_cidr : cidr
  ] : null

  source_security_group_id = lookup(each.value, "source_security_group", null) != null ? local.security_groups_map[each.value.source_security_group] : null
}

# VPC Endpoints Ingress Rules
resource "aws_security_group_rule" "vpc_endpoints_ingress" {
  for_each = {
    for idx, rule in local.security_config.security_groups.vpc_endpoints.ingress : "${idx}" => rule
    if var.create_vpc_endpoints_sg && (
      (lookup(rule, "cidr_blocks", null) != null && length(rule.cidr_blocks) > 0) ||
      (lookup(rule, "source_security_group", null) != null && try(local.security_groups_map[rule.source_security_group] != null, false))
    )
  }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = each.value.description
  security_group_id = aws_security_group.vpc_endpoints[0].id

  cidr_blocks = lookup(each.value, "cidr_blocks", null) != null ? [
    for cidr in each.value.cidr_blocks : cidr == "VPC_CIDR" ? var.vpc_cidr : cidr
  ] : null

  source_security_group_id = lookup(each.value, "source_security_group", null) != null ? local.security_groups_map[each.value.source_security_group] : null
}

# VPC Endpoints Egress Rules
resource "aws_security_group_rule" "vpc_endpoints_egress" {
  for_each = {
    for idx, rule in local.security_config.security_groups.vpc_endpoints.egress : "${idx}" => rule
    if var.create_vpc_endpoints_sg && (
      (lookup(rule, "cidr_blocks", null) != null && length(rule.cidr_blocks) > 0) ||
      (lookup(rule, "source_security_group", null) != null && try(local.security_groups_map[rule.source_security_group] != null, false))
    )
  }

  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = each.value.description
  security_group_id = aws_security_group.vpc_endpoints[0].id

  cidr_blocks = lookup(each.value, "cidr_blocks", null) != null ? [
    for cidr in each.value.cidr_blocks : cidr == "VPC_CIDR" ? var.vpc_cidr : cidr
  ] : null

  source_security_group_id = lookup(each.value, "source_security_group", null) != null ? local.security_groups_map[each.value.source_security_group] : null
}
