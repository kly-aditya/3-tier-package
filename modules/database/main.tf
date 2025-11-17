# ==============================================================================
# Database Module - Main Configuration
# ==============================================================================
# Purpose: RDS PostgreSQL Multi-AZ with AWS Secrets Manager
# Phase: 5 - Database Tier
# ==============================================================================

# ------------------------------------------------------------------------------
# Random Password Generation
# ------------------------------------------------------------------------------

resource "random_password" "master_password" {
  length  = 32
  special = true
  # Exclude characters that might cause issues in connection strings
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ------------------------------------------------------------------------------
# AWS Secrets Manager - Store Database Credentials
# ------------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "db_master_password" {
  name_prefix             = "${var.project_name}-${var.environment}-rds-master-"
  description             = "Master password for ${var.project_name} RDS PostgreSQL instance"
  recovery_window_in_days = var.secret_recovery_days

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-rds-master-password"
      Component = "database"
      Phase     = "5"
    }
  )
}

resource "aws_secretsmanager_secret_version" "db_master_password" {
  secret_id = aws_secretsmanager_secret.db_master_password.id
  secret_string = jsonencode({
    username = var.db_master_username
    password = random_password.master_password.result
    engine   = "postgres"
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
    dbname   = var.db_name
  })
}

# ------------------------------------------------------------------------------
# DB Subnet Group
# ------------------------------------------------------------------------------

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-db-subnet-group"
      Component = "database"
      Phase     = "5"
    }
  )
}

# ------------------------------------------------------------------------------
# DB Parameter Group
# ------------------------------------------------------------------------------
/*
resource "aws_db_parameter_group" "main" {
  name   = "${var.project_name}-${var.environment}-postgres-params"
  family = "postgres${var.postgres_major_version}"

  # Connection settings
  parameter {
    name  = "max_connections"
    value = var.max_connections
    apply_method = "immediate"
  }


  # Logging for troubleshooting
  parameter {
    name  = "log_statement"
    value = var.log_statement
    apply_method = "immediate"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = var.log_min_duration_ms
    apply_method = "immediate"
  }

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-postgres-params"
      Component = "database"
      Phase     = "5"
    }
  )
}
*/
# ------------------------------------------------------------------------------
# RDS PostgreSQL Instance (Multi-AZ)
# ------------------------------------------------------------------------------

resource "aws_db_instance" "main" {
  # Instance identification
  identifier = "${var.project_name}-${var.environment}-postgres"

  # Engine configuration
  engine               = "postgres"
  engine_version       = var.postgres_version
  instance_class       = var.db_instance_class
  db_name              = var.db_name
  username             = var.db_master_username
  password             = random_password.master_password.result
  parameter_group_name = "default.postgres15"

  # Storage configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true
  kms_key_id            = var.kms_key_id # Optional: use default AWS managed key if null

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.database_security_group_id]
  publicly_accessible    = false
  port                   = 5432

  # High Availability
  multi_az = var.multi_az

  # Backup configuration
  backup_retention_period  = var.backup_retention_days
  backup_window            = var.backup_window
  maintenance_window       = var.maintenance_window
  delete_automated_backups = true
  copy_tags_to_snapshot    = true
  skip_final_snapshot      = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project_name}-${var.environment}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Monitoring
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention : null

  # Upgrades
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  allow_major_version_upgrade = false

  # Deletion protection
  deletion_protection = var.deletion_protection

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-postgres"
      Component = "database"
      Phase     = "5"
      Engine    = "PostgreSQL"
      MultiAZ   = var.multi_az
    }
  )

  lifecycle {
    ignore_changes = [
      password,
      final_snapshot_identifier
    ]
  }
}

# ------------------------------------------------------------------------------
# IAM Role for Enhanced Monitoring
# ------------------------------------------------------------------------------

resource "aws_iam_role" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  name_prefix = "${var.project_name}-${var.environment}-rds-mon-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-rds-monitoring-role"
      Component = "database"
      Phase     = "5"
    }
  )
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ------------------------------------------------------------------------------
# CloudWatch Log Groups
# ------------------------------------------------------------------------------
/*

resource "aws_cloudwatch_log_group" "postgresql" {
  name              = "/aws/rds/instance/${aws_db_instance.main.identifier}/postgresql"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-rds-postgresql-logs"
      Component = "database"
      Phase     = "5"
    }
  )
}

resource "aws_cloudwatch_log_group" "postgresql_upgrade" {
  name              = "/aws/rds/instance/${aws_db_instance.main.identifier}/upgrade"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-rds-upgrade-logs"
      Component = "database"
      Phase     = "5"
    }
  )
}

*/
