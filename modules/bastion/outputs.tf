# ==============================================================================
# BASTION MODULE OUTPUTS
# ==============================================================================

output "bastion_instance_id" {
  description = "ID of the bastion EC2 instance"
  value       = aws_instance.bastion.id
}

output "bastion_eip" {
  description = "Elastic IP address of bastion host"
  value       = aws_eip.bastion.public_ip
}

output "bastion_eip_id" {
  description = "Allocation ID of bastion Elastic IP"
  value       = aws_eip.bastion.id
}

output "bastion_private_ip" {
  description = "Private IP address of bastion instance"
  value       = aws_instance.bastion.private_ip
}

output "bastion_iam_role_arn" {
  description = "ARN of bastion IAM role"
  value       = aws_iam_role.bastion.arn
}

output "bastion_iam_role_name" {
  description = "Name of bastion IAM role"
  value       = aws_iam_role.bastion.name
}

output "bastion_security_group_id" {
  description = "Security group ID used by bastion"
  value       = var.bastion_security_group_id
}

output "ssh_command" {
  description = "SSH command to connect to bastion"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_eip.bastion.public_ip}"
}

output "bastion_ami_id" {
  description = "AMI ID used for bastion instance"
  value       = data.aws_ami.amazon_linux_2023.id
}
