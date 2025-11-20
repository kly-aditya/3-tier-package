# ==============================================================================
# MONITORING MODULE - VARIABLES
# ==============================================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region for CloudWatch dashboard"
  type        = string
  default     = "ap-southeast-1"
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
  description = "ARN suffix of the web ALB"
  type        = string
}

variable "app_alb_arn_suffix" {
  description = "ARN suffix of the app ALB"
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
# RDS
# ------------------------------------------------------------------------------

variable "rds_instance_id" {
  description = "RDS instance identifier"
  type        = string
}

# ------------------------------------------------------------------------------
# ALARM THRESHOLDS (for dashboard annotations)
# ------------------------------------------------------------------------------

variable "cpu_alarm_threshold" {
  description = "CPU threshold to show on dashboard"
  type        = number
  default     = 80
}
