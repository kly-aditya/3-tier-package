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

variable "tags" {
  description = "Common tags to apply to all security group resources"
  type        = map(string)
  default     = {}
}
