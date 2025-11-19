# ============================================================================
# KEY MANAGEMENT MODULE - VARIABLES
# ============================================================================

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for storing private keys"
  type        = string
}

variable "s3_key_prefix" {
  description = "S3 key prefix for organizing keys"
  type        = string
  default     = "ssh-keys"
}


variable "bastion_iam_role_arn" {
  description = "IAM role ARN of bastion host (for S3  bucket policy)"
  type        = string
}

