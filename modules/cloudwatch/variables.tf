# ==============================================================================
# CLOUDWATCH ALARMS MODULE - VARIABLES
# ==============================================================================


variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# AUTO SCALING GROUP NAMES
# ------------------------------------------------------------------------------

variable "web_asg_name" {
  description = "Name of the web tier Auto Scaling Group"
  type        = string
}

variable "app_asg_name" {
  description = "Name of the app tier Auto Scaling Group"
  type        = string
}

# ------------------------------------------------------------------------------
# ALB ARN SUFFIXES
# ------------------------------------------------------------------------------

variable "web_alb_arn_suffix" {
  description = "ARN suffix of the web ALB (for CloudWatch metrics)"
  type        = string
}

variable "app_alb_arn_suffix" {
  description = "ARN suffix of the app ALB (for CloudWatch metrics)"
  type        = string
}

variable "web_target_group_arn_suffix" {
  description = "ARN suffix of the web target group"
  type        = string
}

variable "app_target_group_arn_suffix" {
  description = "ARN suffix of the app target group"
  type        = string
}

# ------------------------------------------------------------------------------
# RDS (OPTIONAL)
# ------------------------------------------------------------------------------

variable "enable_rds_alarms" {
  description = "Enable RDS CloudWatch alarms"
  type        = bool
  default     = false
}

variable "rds_instance_id" {
  description = "RDS instance identifier (required if enable_rds_alarms is true)"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# ALARM THRESHOLDS
# ------------------------------------------------------------------------------

variable "high_cpu_threshold" {
  description = "CPU utilization threshold for high CPU alarm (%)"
  type        = number
  default     = 80
}

variable "response_time_threshold" {
  description = "Target response time threshold (seconds)"
  type        = number
  default     = 2
}

variable "error_5xx_threshold" {
  description = "Number of 5xx errors before alarming"
  type        = number
  default     = 10
}

# ------------------------------------------------------------------------------
# ALARM ACTIONS
# ------------------------------------------------------------------------------

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers (e.g., SNS topic ARNs)"
  type        = list(string)
  default     = []
}
