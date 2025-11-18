# ==============================================================================
# WEB TIER MODULE - OUTPUTS
# ==============================================================================

output "launch_template_id" {
  description = "ID of the web tier launch template"
  value       = aws_launch_template.web.id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.web.latest_version
}

output "autoscaling_group_id" {
  description = "ID of the web tier Auto Scaling Group"
  value       = aws_autoscaling_group.web.id
}

output "autoscaling_group_name" {
  description = "Name of the web tier Auto Scaling Group"
  value       = aws_autoscaling_group.web.name
}

output "autoscaling_group_arn" {
  description = "ARN of the web tier Auto Scaling Group"
  value       = aws_autoscaling_group.web.arn
}

output "iam_role_name" {
  description = "Name of the IAM role for web instances"
  value       = aws_iam_role.web.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role for web instances"
  value       = aws_iam_role.web.arn
}

output "ami_id" {
  description = "AMI ID used for web instances"
  value       = data.aws_ami.amazon_linux_2023.id
}
