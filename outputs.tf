# ============================================================================
# PHASE 0: Outputs
# ============================================================================
# We'll add more outputs as we create resources in each phase

# ----------------------------------------------------------------------------
# Project Information
# ----------------------------------------------------------------------------

output "project_name" {
  description = "Name of the project"
  value       = var.project_name
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "aws_region" {
  description = "AWS region being used"
  value       = var.aws_region
}

# ============================================================================
# Outputs to add in subsequent phases:
# ============================================================================
# Phase 1: VPC ID, subnet IDs, IGW ID
# Phase 2: NAT Gateway IDs, Elastic IPs
# Phase 4: Bastion public IP
# Phase 5: RDS endpoint, read replica endpoint
# Phase 7: Web ALB DNS name
# Phase 8: App ALB DNS name
# Phase 11: CloudWatch dashboard URLs
# ============================================================================
