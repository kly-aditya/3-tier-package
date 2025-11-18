# APP TIER MODULE - VARIABLES
# ==============================================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., production, staging)"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# NETWORKING
# ------------------------------------------------------------------------------

variable "private_app_subnet_ids" {
  description = "List of private app subnet IDs for app tier instances"
  type        = list(string)
}

variable "app_sg_id" {
  description = "Security group ID for app tier instances"
  type        = string
}

# ------------------------------------------------------------------------------
# DATABASE
# ------------------------------------------------------------------------------

variable "db_secret_name" {
  description = "Name of the Secrets Manager secret containing database password"
  type        = string
}

variable "db_endpoint" {
  description = "Database endpoint address"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

# ------------------------------------------------------------------------------
# INSTANCE CONFIGURATION
# ------------------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type for app tier"
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Size of root volume in GB"
  type        = number
  default     = 30
}

# ------------------------------------------------------------------------------
# AUTO SCALING
# ------------------------------------------------------------------------------

variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 3
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 6
}
