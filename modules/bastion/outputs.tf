output "bastion_eip" {
  description = "Elastic IP address of bastion host"
  value       = aws_eip.bastion.public_ip
}

output "bastion_eip_id" {
  description = "Allocation ID of bastion Elastic IP"
  value       = aws_eip.bastion.id
}

output "bastion_launch_template_id" {
  description = "ID of bastion launch template"
  value       = aws_launch_template.bastion.id
}

output "bastion_asg_name" {
  description = "Name of bastion Auto Scaling Group"
  value       = aws_autoscaling_group.bastion.name
}

output "bastion_iam_role_arn" {
  description = "ARN of bastion IAM role"
  value       = aws_iam_role.bastion.arn
}

output "bastion_security_group_id" {
  description = "Security group ID used by bastion"
  value       = var.bastion_security_group_id
}

output "ssh_command" {
  description = "SSH command to connect to bastion"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_eip.bastion.public_ip}"
}

output "bastion_summary" {
  description = "Summary of bastion deployment"
  value = {
    public_ip        = aws_eip.bastion.public_ip
    instance_type    = var.instance_type
    ami_id           = data.aws_ami.amazon_linux_2023.id
    key_name         = var.key_name
    asg_name         = aws_autoscaling_group.bastion.name
    allowed_ssh_cidr = var.allowed_ssh_cidr
  }
}
