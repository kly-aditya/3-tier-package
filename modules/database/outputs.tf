# ==============================================================================
# Database Module - Outputs
# ==============================================================================
# Purpose: Export database connection details and resource information


output "db_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "Connection endpoint (host:port)"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "Hostname of the RDS instance"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Name of the default database"
  value       = aws_db_instance.main.db_name
}

output "db_master_username" {
  description = "Master username for the database"
  value       = aws_db_instance.main.username
  sensitive   = true
}

# ------------------------------------------------------------------------------
# Secrets Manager
# ------------------------------------------------------------------------------

output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret containing DB credentials"
  value       = aws_secretsmanager_secret.db_master_password.arn
}

output "db_secret_name" {
  description = "Name of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.db_master_password.name
}

# ------------------------------------------------------------------------------
# Subnet Group
# ------------------------------------------------------------------------------

output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.main.name
}

output "db_subnet_group_arn" {
  description = "ARN of the DB subnet group"
  value       = aws_db_subnet_group.main.arn
}

# ------------------------------------------------------------------------------
# Parameter Group
# ------------------------------------------------------------------------------

output "db_parameter_group_name" {
  description = "Name of the DB parameter group"
  value       = "default.postgres15"  # Using default parameter group
}

# ------------------------------------------------------------------------------
# Connection String
# ------------------------------------------------------------------------------

output "connection_string_template" {
  description = "PostgreSQL connection string template (password in Secrets Manager)"
  value       = "postgresql://${aws_db_instance.main.username}:<PASSWORD_FROM_SECRETS_MANAGER>@${aws_db_instance.main.address}:${aws_db_instance.main.port}/${aws_db_instance.main.db_name}"
}

# ------------------------------------------------------------------------------
# Monitoring
# ------------------------------------------------------------------------------

output "enhanced_monitoring_role_arn" {
  description = "ARN of the enhanced monitoring IAM role"
  value       = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null
}
/*
output "postgresql_log_group_name" {
  description = "Name of the PostgreSQL CloudWatch log group"
  value       = aws_cloudwatch_log_group.postgresql.name
}

output "upgrade_log_group_name" {
  description = "Name of the upgrade CloudWatch log group"
  value       = aws_cloudwatch_log_group.postgresql_upgrade.name
}
*/

# ------------------------------------------------------------------------------
# High Availability
# ------------------------------------------------------------------------------

output "multi_az" {
  description = "Whether the RDS instance is Multi-AZ"
  value       = aws_db_instance.main.multi_az
}

output "availability_zone" {
  description = "Primary availability zone of the RDS instance"
  value       = aws_db_instance.main.availability_zone
}

# ------------------------------------------------------------------------------
# Backup Information
# ------------------------------------------------------------------------------

output "backup_retention_period" {
  description = "Backup retention period in days"
  value       = aws_db_instance.main.backup_retention_period
}

output "backup_window" {
  description = "Daily backup window"
  value       = aws_db_instance.main.backup_window
}

output "maintenance_window" {
  description = "Weekly maintenance window"
  value       = aws_db_instance.main.maintenance_window
}

output "latest_restorable_time" {
  description = "Latest time to which the database can be restored with point-in-time restore"
  value       = aws_db_instance.main.latest_restorable_time
}
