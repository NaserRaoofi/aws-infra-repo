# Outputs for ALB Controller IAM Role

output "alb_controller_role_arn" {
  description = "ARN of the ALB Controller IAM role"
  value       = aws_iam_role.alb_controller.arn
}

output "alb_controller_role_name" {
  description = "Name of the ALB Controller IAM role"
  value       = aws_iam_role.alb_controller.name
}

output "alb_controller_policy_arn" {
  description = "ARN of the ALB Controller IAM policy"
  value       = aws_iam_policy.alb_controller.arn
}

output "alb_controller_policy_name" {
  description = "Name of the ALB Controller IAM policy"
  value       = aws_iam_policy.alb_controller.name
}

output "service_account_namespace" {
  description = "Namespace for the ALB Controller service account"
  value       = var.service_account_namespace
}

output "service_account_name" {
  description = "Name of the ALB Controller service account"
  value       = var.service_account_name
}
