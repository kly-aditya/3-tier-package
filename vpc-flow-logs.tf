# ============================================================================
# VPC Flow Logs - Simple S3-Only Configuration
# ============================================================================
# Purpose: Network traffic logging directly to S3
# ============================================================================

# ----------------------------------------------------------------------------
# S3 Bucket for VPC Flow Logs
# ----------------------------------------------------------------------------
resource "aws_s3_bucket" "vpc_flow_logs" {
  bucket = "${var.project_name}-${var.environment}-vpc-flow-logs-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    local.common_tags,
    {
      Name    = "${var.project_name}-${var.environment}-vpc-flow-logs"
      Purpose = "VPC Flow Logs Long-term Storage"
      Phase   = "10"
    }
  )
}

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle - Delete after 90 days
resource "aws_s3_bucket_lifecycle_configuration" "vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    filter {
      prefix = ""  # Apply to all objects
    }

    expiration {
      days = 90
    }
  }
}

# ----------------------------------------------------------------------------
# VPC Flow Log to S3
# ----------------------------------------------------------------------------
resource "aws_flow_log" "vpc_s3" {
  log_destination      = aws_s3_bucket.vpc_flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name    = "${var.project_name}-${var.environment}-vpc-flow-log"
      Purpose = "Network Traffic Monitoring"
      Phase   = "10"
    }
  )
}

# ----------------------------------------------------------------------------
# Data Source
# ----------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# ----------------------------------------------------------------------------
# Outputs
# ----------------------------------------------------------------------------
output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = aws_flow_log.vpc_s3.id
}

output "vpc_flow_logs_s3_bucket" {
  description = "S3 bucket for VPC Flow Logs storage"
  value       = aws_s3_bucket.vpc_flow_logs.id
}

output "vpc_flow_logs_s3_arn" {
  description = "ARN of the S3 bucket for VPC Flow Logs"
  value       = aws_s3_bucket.vpc_flow_logs.arn
}
