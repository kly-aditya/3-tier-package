# ============================================================================
# PHASE 0: Essential Variables
# ============================================================================
# These are the minimum variables needed to get started.
# We'll add more variables as we progress through each phase.

# ----------------------------------------------------------------------------
# Project Configuration
# ----------------------------------------------------------------------------

variable "project_name" {
  description = "Name of the project (used in resource naming and tags)"
  type        = string

  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 20
    error_message = "Project name must be between 1 and 20 characters."
  }
}

variable "environment" {
  description = "Environment name (e.g., production, staging, development)"
  type        = string

  validation {
    condition     = contains(["production", "staging", "development", "test"], var.environment)
    error_message = "Environment must be one of: production, staging, development, test."
  }
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-southeast-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in valid format (e.g., ap-southeast-1)."
  }
}

# variable "owner_email" {
#description = "Email address of the infrastructure owner (for tagging and notifications)"
#type        = string
#default     = "devops@example.com"

#validation {
# condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner_email))
#error_message = "Owner email must be a valid email address."
# }
#}

# ----------------------------------------------------------------------------
# Network Configuration (for Phase 1)
# ----------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones_count" {
  description = "Number of availability zones to use (must be 3 for this architecture)"
  type        = number
  default     = 3

  validation {
    condition     = var.availability_zones_count == 3
    error_message = "This architecture requires exactly 3 availability zones."
  }
}

# ----------------------------------------------------------------------------
# Feature Flags (we'll use these to enable/disable components during testing)
# ----------------------------------------------------------------------------

variable "enable_nat_gateway" {
  description = "Enable NAT Gateways (WARNING: Costs ~$100/month). Set to false for Phase 1 testing."
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

# Variables - Bastion Host (AUTOMATED KEY PAIR!)
# ==============================================================================

# Only need your IP - key pair is automatic!
variable "my_ip" {
  description = "Your IP address for SSH access to bastion (format: x.x.x.x/32)"
  type        = string
}

# NO NEED for bastion_key_name variable - it's created automatically!



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

variable "db_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Maximum storage for autoscaling"
  type        = number
  default     = 100
}

variable "db_storage_type" {
  description = "Storage type (gp3, gp2, io1)"
  type        = string
  default     = "gp3"
}

# ------------------------------------------------------------------------------
# High Availability
# ------------------------------------------------------------------------------

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# Backup Configuration
# ------------------------------------------------------------------------------

variable "db_backup_retention_days" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 7
}

variable "db_backup_window" {
  description = "Daily backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "db_maintenance_window" {
  description = "Weekly maintenance window (UTC)"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot when destroying (set to false for production)"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# Monitoring Configuration
# ------------------------------------------------------------------------------

variable "db_monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 60
}

variable "db_performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "db_performance_insights_retention" {
  description = "Performance Insights retention period in days (7 or 731)"
  type        = number
  default     = 7
}

variable "db_log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

# ------------------------------------------------------------------------------
# Database Parameter Group Settings
# ------------------------------------------------------------------------------

variable "db_max_connections" {
  description = "Maximum number of database connections"
  type        = string
  default     = "100"
}

variable "db_log_statement" {
  description = "Log statement type (none, ddl, mod, all)"
  type        = string
  default     = "ddl"
}

variable "db_log_min_duration_ms" {
  description = "Log queries taking longer than this (ms, -1 to disable)"
  type        = string
  default     = "1000"
}

# ------------------------------------------------------------------------------
# Protection
# ------------------------------------------------------------------------------

variable "db_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "db_auto_minor_version_upgrade" {
  description = "Automatically upgrade minor versions"
  type        = bool
  default     = true
}


# ------------------------------------------------------------------------------
# PHASE 6: WEB TIER
# ------------------------------------------------------------------------------

variable "web_instance_type" {
  description = "Instance type for web tier instances"
  type        = string
  default     = "t3.small"
}

variable "web_root_volume_size" {
  description = "Size of root volume for web instances in GB"
  type        = number
  default     = 30
}

variable "web_asg_min_size" {
  description = "Minimum number of instances in web tier ASG"
  type        = number
  default     = 3
}

variable "web_asg_desired_capacity" {
  description = "Desired number of instances in web tier ASG"
  type        = number
  default     = 3
}

variable "web_asg_max_size" {
  description = "Maximum number of instances in web tier ASG"
  type        = number
  default     = 6
}

# PHASE 7: WEB APPLICATION LOAD BALANCER
# ==============================================================================

variable "alb_enable_deletion_protection" {
  description = "Enable deletion protection for Web ALB"
  type        = bool
  default     = false
}

variable "alb_health_check_path" {
  description = "Health check path for target group"
  type        = string
  default     = "/health"
}

variable "alb_health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "alb_health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "alb_health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks before marking instance healthy"
  type        = number
  default     = 2
}

variable "alb_health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks before marking instance unhealthy"
  type        = number
  default     = 3
}

variable "alb_deregistration_delay" {
  description = "Time in seconds to wait before deregistering a target"
  type        = number
  default     = 30
}

variable "alb_enable_stickiness" {
  description = "Enable sticky sessions on target group"
  type        = bool
  default     = false
}

variable "alb_stickiness_duration" {
  description = "Stickiness duration in seconds (1-604800)"
  type        = number
  default     = 86400
}


# PHASE 8: APPLICATION TIER
# ==============================================================================

variable "app_instance_type" {
  description = "Instance type for app tier instances"
  type        = string
  default     = "t3.small"
}

variable "app_root_volume_size" {
  description = "Size of root volume for app instances in GB"
  type        = number
  default     = 30
}

variable "app_asg_min_size" {
  description = "Minimum number of instances in app tier ASG"
  type        = number
  default     = 3
}

variable "app_asg_desired_capacity" {
  description = "Desired number of instances in app tier ASG"
  type        = number
  default     = 3
}

variable "app_asg_max_size" {
  description = "Maximum number of instances in app tier ASG"
  type        = number
  default     = 6
}