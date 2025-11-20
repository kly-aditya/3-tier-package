# APP TIER MODULE - OUTPUTS
# ==============================================================================

output "launch_template_id" {
  description = "ID of the app tier launch template"
  value       = aws_launch_template.app.id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.app.latest_version
}

output "autoscaling_group_id" {
  description = "ID of the app tier Auto Scaling Group"
  value       = aws_autoscaling_group.app.id
}

output "autoscaling_group_name" {
  description = "Name of the app tier Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "autoscaling_group_arn" {
  description = "ARN of the app tier Auto Scaling Group"
  value       = aws_autoscaling_group.app.arn
}

output "iam_role_name" {
  description = "Name of the IAM role for app instances"
  value       = aws_iam_role.app.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role for app instances"
  value       = aws_iam_role.app.arn
}

output "ami_id" {
  description = "AMI ID used for app instances"
  value       = data.aws_ami.amazon_linux_2023.id
}


# ==============================================================================
# AUTO SCALING POLICY OUTPUTS - APP TIER
# ==============================================================================


output "autoscaling_policy_cpu_arn" {
  description = "ARN of the CPU target tracking scaling policy"
  value       = aws_autoscaling_policy.app_cpu_target_tracking.arn
}

output "autoscaling_policy_cpu_name" {
  description = "Name of the CPU target tracking scaling policy"
  value       = aws_autoscaling_policy.app_cpu_target_tracking.name
}

output "autoscaling_policy_alb_arn" {
  description = "ARN of the ALB request count scaling policy"
  value       = var.enable_alb_request_scaling ? aws_autoscaling_policy.app_alb_request_count[0].arn : null
}

output "autoscaling_policy_alb_name" {
  description = "Name of the ALB request count scaling policy"
  value       = var.enable_alb_request_scaling ? aws_autoscaling_policy.app_alb_request_count[0].name : null
}

output "scaling_configuration" {
  description = "Summary of auto scaling configuration"
  value = {
    min_size                 = var.min_size
    max_size                 = var.max_size
    desired_capacity         = var.desired_capacity
    target_cpu               = var.target_cpu_utilization
    target_requests          = var.target_requests_per_instance
    scale_out_cooldown_sec   = var.scale_out_cooldown
    scale_in_cooldown_sec    = var.scale_in_cooldown
    health_check_grace_sec   = var.health_check_grace_period
  }
}
