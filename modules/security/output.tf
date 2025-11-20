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


# WAF OUTPUTS
# ==============================================================================
# Add these to modules/security/outputs.tf

output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = var.enable_waf ? aws_wafv2_web_acl.web_alb[0].id : null
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = var.enable_waf ? aws_wafv2_web_acl.web_alb[0].arn : null
}

output "waf_web_acl_capacity" {
  description = "Web ACL capacity units used (max 1500)"
  value       = var.enable_waf ? aws_wafv2_web_acl.web_alb[0].capacity : null
}

output "waf_enabled" {
  description = "Whether WAF is enabled"
  value       = var.enable_waf
}

output "waf_rate_limit" {
  description = "Configured rate limit for WAF"
  value       = var.enable_waf ? var.waf_rate_limit : null
}

output "waf_log_group_name" {
  description = "CloudWatch Log Group name for WAF logs"
  value       = var.enable_waf && var.enable_waf_logging ? aws_cloudwatch_log_group.waf[0].name : null
}
