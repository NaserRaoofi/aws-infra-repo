################################################################################
# EKS Service - Cluster and Node Groups
################################################################################

locals {
	name = "${var.name_prefix}-eks"

	# Default addons (minimal built-ins). Keep null to let caller decide; else provide sane defaults
	default_addons = {
		# Core EKS managed addons
		vpc-cni = {
			most_recent    = true
			before_compute = true
		}
		kube-proxy = {
			most_recent    = true
			before_compute = true
		}
		coredns = {
			most_recent    = true
			before_compute = true
		}
		# Storage driver - recommended for dynamic PVs
		aws-ebs-csi-driver = {
			most_recent = true
		}
	}
}

module "eks" {
	source = "github.com/NaserRaoofi/terraform-aws-modules//modules/eks?ref=main"

	# Safety switch
	create = var.create

	# Global
	region = var.region
	tags   = var.common_tags

	# Cluster
	name                = local.name
	kubernetes_version  = coalesce(var.cluster_version, "1.33")
	vpc_id              = var.vpc_id
	control_plane_subnet_ids = var.private_subnet_ids
	subnet_ids               = var.private_subnet_ids

	# Endpoints
	endpoint_private_access = true
	endpoint_public_access  = var.endpoint_public_access

	# Logging - off by default per requirement
	enabled_log_types           = var.enabled_log_types
	create_cloudwatch_log_group = false

	# Security groups
	create_security_group        = true
	create_node_security_group   = true

	# IRSA
	enable_irsa = var.enable_irsa

	# Access control - grant admin access to cluster creator
	enable_cluster_creator_admin_permissions = true

	# Addons - install core addons BEFORE nodegroups to prevent chicken-and-egg problem
	addons = coalesce(var.addons, local.default_addons)

	# Force addons to be created before nodegroups with longer timeouts
	addons_timeouts = {
		create = "20m"
		update = "20m"
		delete = "20m"
	}

	##############################################################################
	# Node groups (EKS managed)
	# These will be created AFTER cluster and addons are ready
	##############################################################################

eks_managed_node_groups = {
	system = {
    desired_size = 1
    min_size     = 1
    max_size     = 1
    instance_types = ["t3.medium", "t3a.medium", "t3.small", "t3a.small"]
    labels = { role = "system" }

    taints = {
      CriticalAddonsOnly = {
        key    = "systempods"
        value  = "true"
        effect = "NO_SCHEDULE"
      }
    }
    subnet_ids = var.private_subnet_ids
    enable_bootstrap_user_data = true
  }

  database = {
    desired_size = 1
    min_size     = 1
    max_size     = 1
    instance_types = ["t3.medium", "t3a.medium", "t3.small", "t3a.small"]
    labels = { role = "database" }

    taints = {
      dedicated = {
        key    = "dedicated"
        value  = "database"
        effect = "NO_SCHEDULE"
      }
    }
    subnet_ids = var.private_subnet_ids
    enable_bootstrap_user_data = true
  }

	# General-purpose pool (untainted) in private subnets so core addons can schedule
	general = {
		desired_size = 1
		min_size     = 1
		max_size     = 1
		instance_types = ["t3.small", "t3a.small", "t3.medium", "t3a.medium"]
		labels = { role = "general" }

		subnet_ids = var.private_subnet_ids
		enable_bootstrap_user_data = true
	}
}
}
