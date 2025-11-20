# ------------------------------------------------------------------------------
# Security Group IDs
# ------------------------------------------------------------------------------

output "web_alb_security_group_id" {
  description = "ID of the Web ALB security group"
  value       = aws_security_group.web_alb.id
}

output "web_security_group_id" {
  description = "ID of the Web Tier security group"
  value       = aws_security_group.web.id
}

output "app_alb_security_group_id" {
  description = "ID of the App ALB security group"
  value       = aws_security_group.app_alb.id
}

output "app_security_group_id" {
  description = "ID of the App Tier security group"
  value       = aws_security_group.app.id
}

output "database_security_group_id" {
  description = "ID of the Database security group"
  value       = aws_security_group.database.id
}

output "bastion_security_group_id" {
  description = "ID of the Bastion security group"
  value       = aws_security_group.bastion.id
}

# ------------------------------------------------------------------------------
# Security Group Names
# ------------------------------------------------------------------------------

output "web_alb_security_group_name" {
  description = "Name of the Web ALB security group"
  value       = aws_security_group.web_alb.name
}

output "web_security_group_name" {
  description = "Name of the Web Tier security group"
  value       = aws_security_group.web.name
}

output "app_alb_security_group_name" {
  description = "Name of the App ALB security group"
  value       = aws_security_group.app_alb.name
}

output "app_security_group_name" {
  description = "Name of the App Tier security group"
  value       = aws_security_group.app.name
}

output "database_security_group_name" {
  description = "Name of the Database security group"
  value       = aws_security_group.database.name
}

output "bastion_security_group_name" {
  description = "Name of the Bastion security group"
  value       = aws_security_group.bastion.name
}




# ------------------------------------------------------------------------------
# Summary Output
# ------------------------------------------------------------------------------

output "security_groups_summary" {
  description = "Summary of all security groups created"
  value = {
    total_security_groups = 6
    web_alb_sg_id        = aws_security_group.web_alb.id
    web_sg_id            = aws_security_group.web.id
    app_alb_sg_id        = aws_security_group.app_alb.id
    app_sg_id            = aws_security_group.app.id
    database_sg_id       = aws_security_group.database.id
    bastion_sg_id        = aws_security_group.bastion.id
  }
}
