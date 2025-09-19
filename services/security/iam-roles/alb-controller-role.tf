# IAM Role for AWS Load Balancer Controller Service Account

# Data source to get the current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# IAM policy document for the trust relationship
data "aws_iam_policy_document" "alb_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_arn, "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/", "")}:sub"
      values   = ["system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_arn, "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [var.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

# IAM role for AWS Load Balancer Controller
resource "aws_iam_role" "alb_controller" {
  name               = "${var.environment}-${var.project_name}-alb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.alb_controller_assume_role_policy.json

  tags = {
    Name        = "${var.environment}-${var.project_name}-alb-controller-role"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Component   = "alb-controller"
  }
}

# IAM policy for AWS Load Balancer Controller
resource "aws_iam_policy" "alb_controller" {
  name        = "${var.environment}-${var.project_name}-alb-controller-policy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/policy/alb-controller-policy.json")

  tags = {
    Name        = "${var.environment}-${var.project_name}-alb-controller-policy"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Component   = "alb-controller"
  }
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}
