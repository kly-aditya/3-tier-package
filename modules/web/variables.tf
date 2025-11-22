# ==============================================================================
# WEB TIER MODULE - VARIABLES
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

variable "public_subnet_ids" {
  description = "List of public subnet IDs for web tier instances"
  type        = list(string)
}

variable "web_sg_id" {
  description = "Security group ID for web tier instances"
  type        = string
}

# ------------------------------------------------------------------------------
# INSTANCE CONFIGURATION
# ------------------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type for web tier"
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Size of root volume in GB"
  type        = number
  default     = 20
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

# SSH KEY VARIABLE
# ============================================================================

variable "ssh_key_name" {
  description = "SSH key name for web tier instances"
  type        = string
}

# ==============================================================================
# AUTO SCALING VARIABLES
# ==============================================================================

# SCALING LIMITS
# ------------------------------------------------------------------------------

variable "min_size" {
  description = "Minimum number of instances in Auto Scaling Group"
  type        = number
  default     = 3
}

variable "max_size" {
  description = "Maximum number of instances in Auto Scaling Group"
  type        = number
  default     = 6
}

variable "desired_capacity" {
  description = "Desired number of instances in Auto Scaling Group"
  type        = number
  default     = 3
}

# ------------------------------------------------------------------------------
# TARGET TRACKING CONFIGURATION
# ------------------------------------------------------------------------------

variable "target_cpu_utilization" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 70
}

variable "target_requests_per_instance" {
  description = "Target number of requests per instance (for ALB-based scaling)"
  type        = number
  default     = 1000
}

variable "enable_alb_request_scaling" {
  description = "Enable ALB request count based scaling (in addition to CPU)"
  type        = bool
  default     = false  # Disabled by default, CPU scaling is usually sufficient
}

# ------------------------------------------------------------------------------
# COOLDOWN PERIODS
# ------------------------------------------------------------------------------

variable "scale_out_cooldown" {
  description = "Time (seconds) before another scale out activity can start"
  type        = number
  default     = 180  # 3 minutes - aggressive scale up
}

variable "scale_in_cooldown" {
  description = "Time (seconds) before another scale in activity can start"
  type        = number
  default     = 900  # 15 minutes - conservative scale down
}

# ------------------------------------------------------------------------------
# HEALTH CHECK
# ------------------------------------------------------------------------------

variable "health_check_grace_period" {
  description = "Time (seconds) after instance launch before health checks start"
  type        = number
  default     = 300  # 5 minutes - allows time for user_data to complete
}

# ------------------------------------------------------------------------------
# ALB TARGET GROUP (for request-based scaling)
# ------------------------------------------------------------------------------

variable "alb_target_group_arn_suffix" {
  description = "ARN suffix of the ALB target group (for request count scaling)"
  type        = string
  default     = ""
}

