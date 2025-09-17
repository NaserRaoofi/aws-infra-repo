################################################################################
# Security Service - Main Configuration
################################################################################

# This service manages all security resources (NACLs and Security Groups)
# Processes JSON configuration and provides outputs for other services

# JSON-based Security Configuration
locals {
  # Read security rules from comprehensive JSON configuration file
  security_config = jsondecode(file("${path.module}/config/security-rules.json"))

  # ================================
  # PROCESS NETWORK ACL RULES FOR VPC MODULE
  # ================================

  # Default Network ACL Rules
  default_network_acl_ingress_processed = [
    for rule in local.security_config.network_acl_rules.default.ingress : {
      rule_number = rule.rule_no
      rule_action = rule.action
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      cidr_block  = rule.cidr_block == "VPC_CIDR" ? var.vpc_cidr : rule.cidr_block
    }
  ]

  default_network_acl_egress_processed = [
    for rule in local.security_config.network_acl_rules.default.egress : {
      rule_number = rule.rule_no
      rule_action = rule.action
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      cidr_block  = rule.cidr_block == "VPC_CIDR" ? var.vpc_cidr : rule.cidr_block
    }
  ]

  # Public Subnet NACL Rules
  public_inbound_acl_rules_processed = [
    for rule in local.security_config.network_acl_rules.public.inbound : {
      rule_number = rule.rule_number
      rule_action = rule.rule_action
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      cidr_block  = rule.cidr_block == "VPC_CIDR" ? var.vpc_cidr : rule.cidr_block
    }
  ]

  public_outbound_acl_rules_processed = [
    for rule in local.security_config.network_acl_rules.public.outbound : {
      rule_number = rule.rule_number
      rule_action = rule.rule_action
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      cidr_block  = rule.cidr_block == "VPC_CIDR" ? var.vpc_cidr : rule.cidr_block
    }
  ]

  # Private Subnet NACL Rules
  private_inbound_acl_rules_processed = [
    for rule in local.security_config.network_acl_rules.private.inbound : {
      rule_number = rule.rule_number
      rule_action = rule.rule_action
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      cidr_block  = rule.cidr_block == "VPC_CIDR" ? var.vpc_cidr : rule.cidr_block
    }
  ]

  private_outbound_acl_rules_processed = [
    for rule in local.security_config.network_acl_rules.private.outbound : {
      rule_number = rule.rule_number
      rule_action = rule.rule_action
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      cidr_block  = rule.cidr_block == "VPC_CIDR" ? var.vpc_cidr : rule.cidr_block
    }
  ]
}


locals {
  create_security_groups = true  # Always true since security service is only called when VPC exists
}
