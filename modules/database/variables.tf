# ==============================================================================
# Database Module - Variables
# ==============================================================================
# Purpose: Define all input variables for RDS PostgreSQL database


variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (production, staging, development)"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all database resources"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# Network Configuration
# ------------------------------------------------------------------------------

variable "db_subnet_ids" {
  description = "List of subnet IDs for the DB subnet group (3 private DB subnets)"
  type        = list(string)
}

variable "database_security_group_id" {
  description = "Security group ID for the database"
  type        = string
}

# ------------------------------------------------------------------------------
# Database Instance Configuration
# ------------------------------------------------------------------------------

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Name of the default database to create"
  type        = string
  default     = "appdb"
}

variable "db_master_username" {
  description = "Master username for the database"
  type        = string
  default     = "dbadmin"
}

# ------------------------------------------------------------------------------
# PostgreSQL Version
# ------------------------------------------------------------------------------

variable "postgres_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.8"
}

variable "postgres_major_version" {
  description = "PostgreSQL major version for parameter group"
  type        = string
  default     = "15"
}

# ------------------------------------------------------------------------------
# Storage Configuration
# ------------------------------------------------------------------------------

variable "allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage for autoscaling (0 to disable)"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type (gp3, gp2, io1)"
  type        = string
  default     = "gp3"
}

variable "kms_key_id" {
  description = "KMS key ID for storage encryption (null = use AWS managed key)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# High Availability
# ------------------------------------------------------------------------------

variable "multi_az" {
  description = "Enable Multi-AZ deployment for high availability"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# Backup Configuration
# ------------------------------------------------------------------------------

variable "backup_retention_days" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Daily backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Weekly maintenance window (UTC)"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying (set to false for production)"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# Monitoring Configuration
# ------------------------------------------------------------------------------

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 60
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention" {
  description = "Performance Insights retention period in days (7 or 731)"
  type        = number
  default     = 7
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

# ------------------------------------------------------------------------------
# Database Parameter Group Settings
# ------------------------------------------------------------------------------

variable "max_connections" {
  description = "Maximum number of database connections"
  type        = string
  default     = "100"
}

variable "log_statement" {
  description = "Log statement type (none, ddl, mod, all)"
  type        = string
  default     = "ddl"
}

variable "log_min_duration_ms" {
  description = "Log queries taking longer than this (ms, -1 to disable)"
  type        = string
  default     = "1000"
}

# ------------------------------------------------------------------------------
# Upgrades
# ------------------------------------------------------------------------------

variable "auto_minor_version_upgrade" {
  description = "Automatically upgrade minor versions during maintenance window"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# Protection
# ------------------------------------------------------------------------------

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# Secrets Manager
# ------------------------------------------------------------------------------

variable "secret_recovery_days" {
  description = "Number of days to retain secret after deletion (0 to delete immediately)"
  type        = number
  default     = 7
}
