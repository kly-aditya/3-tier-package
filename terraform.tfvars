
# IMPORTANT: This file contains your actual configuration values.
# DO NOT commit this file to Git (it's in .gitignore)
# ============================================================================

# ----------------------------------------------------------------------------
# Project Configuration
# ----------------------------------------------------------------------------

project_name = "package3-demo"
environment  = "production"
aws_region   = "ap-southeast-1"
#owner_email  = "your-email@example.com"  # TODO: Replace with your email

# ----------------------------------------------------------------------------
# Network Configuration
# ----------------------------------------------------------------------------

vpc_cidr                 = "10.0.0.0/16"
availability_zones_count = 3

# ----------------------------------------------------------------------------
# Feature Flags (for phased development)
# ----------------------------------------------------------------------------

# Phase 1: VPC only (no NAT gateways yet - they cost money!)
enable_nat_gateway = true
enable_flow_logs   = true

# ============================================================================

# ----------------------------------------------------------------------------
# TODO: Add these variables in later phases
# ----------------------------------------------------------------------------
# Phase 4: Bastion Host
# key_name = "your-ssh-key-name"
# admin_ip = "YOUR_IP_ADDRESS/32"



# Phase 6-8: Compute Tiers
# web_tier_instance_type = "t3.medium"
# app_tier_instance_type = "t3.medium"

my_ip = "49.249.69.254/32"

# Phase 5: Database Configuration
# ============================================================================

db_instance_class               = "db.t3.micro"
db_name                         = "appdb"
db_master_username              = "dbadmin"
postgres_version                = "15"  # Use latest 15.x
postgres_major_version          = "15"
db_allocated_storage            = 20
db_max_allocated_storage        = 100
db_storage_type                 = "gp3"
db_multi_az                     = true
db_backup_retention_days        = 7
db_backup_window                = "03:00-04:00"
db_maintenance_window           = "Mon:04:00-Mon:05:00"
db_skip_final_snapshot          = true
db_monitoring_interval          = 60
db_performance_insights_enabled = true
db_performance_insights_retention = 7
db_log_retention_days           = 7
db_max_connections              = "100"
db_log_statement                = "ddl"
db_log_min_duration_ms          = "1000"
db_deletion_protection          = false
db_auto_minor_version_upgrade   = true



# PHASE 6: WEB TIER
# ------------------------------------------------------------------------------

# Instance Configuration
web_instance_type    = "t3.small"
web_root_volume_size = 30

# Auto Scaling Configuration
web_asg_min_size         = 3
web_asg_desired_capacity = 3
web_asg_max_size         = 6

