# ==============================================================================
# FLEXIBLE ALB MODULE - VARIABLES
# ==============================================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., production, staging)"
  type        = string
}

variable "tier_name" {
  description = "Tier name (e.g., web, app) - used in resource naming"
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

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ALB (public for web, private for app)"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security group ID for ALB"
  type        = string
}

# ------------------------------------------------------------------------------
# AUTO SCALING GROUP
# ------------------------------------------------------------------------------

variable "asg_name" {
  description = "Name of the Auto Scaling Group to attach"
  type        = string
}

# ------------------------------------------------------------------------------
# ALB CONFIGURATION
# ------------------------------------------------------------------------------

variable "internal" {
  description = "Whether the ALB is internal (true) or internet-facing (false)"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# TARGET GROUP & PORTS
# ------------------------------------------------------------------------------

variable "target_port" {
  description = "Port on which targets receive traffic"
  type        = number
}

variable "listener_port" {
  description = "Port on which the ALB listens"
  type        = number
  default     = 80
}

# ------------------------------------------------------------------------------
# HEALTH CHECK
# ------------------------------------------------------------------------------

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive health checks before instance is healthy"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures before instance is unhealthy"
  type        = number
  default     = 3
}

variable "deregistration_delay" {
  description = "Time to wait before deregistering target"
  type        = number
  default     = 30
}

# ------------------------------------------------------------------------------
# STICKINESS
# ------------------------------------------------------------------------------

variable "enable_stickiness" {
  description = "Enable sticky sessions"
  type        = bool
  default     = false
}

variable "stickiness_duration" {
  description = "Stickiness duration in seconds"
  type        = number
  default     = 86400
}
