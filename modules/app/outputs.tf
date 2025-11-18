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
