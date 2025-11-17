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

# ============================================================================
# More variables will be added in subsequent phases:
# - Phase 3: Security Group variables
# - Phase 4: Bastion Host variables
# - Phase 5: RDS Database variables
# - Phase 6-8: Compute tier variables
# - Phase 10: WAF variables
# - Phase 11: Monitoring variables
# ============================================================================
