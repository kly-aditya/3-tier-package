# Security Module - Variables
# ==============================================================================
# Purpose: Define all input variables for security groups
# Phase: 3 - Security Groups (Structure Only)
# ==============================================================================

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (production, staging, dev)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH to bastion (your IP)"
  type        = string
  default     = "0.0.0.0/0"  # CHANGE THIS TO YOUR IP!
}

variable "tags" {
  description = "Common tags to apply to all security group resources"
  type        = map(string)
  default     = {}
}

# WAF VARIABLES
# ==============================================================================

# ------------------------------------------------------------------------------
# WAF ENABLE/DISABLE
# ------------------------------------------------------------------------------

variable "enable_waf" {
  description = "Enable AWS WAF for web ALB protection"
  type        = bool
  default     = true  # Recommended for production
}

# ------------------------------------------------------------------------------
# WAF CONFIGURATION
# ------------------------------------------------------------------------------

variable "waf_rate_limit" {
  description = "Maximum number of requests allowed from single IP in 5 minutes"
  type        = number
  default     = 2000  # Adjust based on legitimate traffic patterns
  
  validation {
    condition     = var.waf_rate_limit >= 100 && var.waf_rate_limit <= 20000000
    error_message = "WAF rate limit must be between 100 and 20,000,000 requests per 5 minutes"
  }
}

# ------------------------------------------------------------------------------
# WAF LOGGING
# ------------------------------------------------------------------------------

variable "enable_waf_logging" {
  description = "Enable WAF request logging to CloudWatch (can be expensive)"
  type        = bool
  default     = false  # Keep disabled by default to control costs
}

variable "waf_log_retention_days" {
  description = "Number of days to retain WAF logs in CloudWatch"
  type        = number
  default     = 7  # 7 days is sufficient for most cases
}

# ------------------------------------------------------------------------------

