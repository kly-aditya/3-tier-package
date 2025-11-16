# ============================================================================
# PACKAGE 3: Production-Standard (3-AZ) Infrastructure
# ============================================================================
# This is the main Terraform configuration file.
# Resources will be added phase by phase.
# ============================================================================

# ----------------------------------------------------------------------------
# Data Sources
# ----------------------------------------------------------------------------

# Get available availability zones in the region
data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# ----------------------------------------------------------------------------
# Local Variables
# ----------------------------------------------------------------------------

locals {
  # Select first 3 availability zones
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.availability_zones_count)

  # Common tags for all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }

  # Naming prefix
  name_prefix = "${var.project_name}-${var.environment}"
}

# ============================================================================
# PHASE 0: SETUP COMPLETE
# ============================================================================
# Next step: Run 'terraform init' to verify backend connection
# ============================================================================

# ============================================================================
# Resources to add in subsequent phases:
# ============================================================================
# Phase 1: VPC, Subnets, Internet Gateway, Route Tables
# Phase 2: NAT Gateways, Elastic IPs, Private Route Tables
# Phase 3: Security Groups (empty, no rules)
# Phase 4: Bastion Host module
# Phase 5: RDS Database module
# Phase 6: Web Tier module (without ALB)
# Phase 7: Web ALB
# Phase 8: App Tier module + App ALB
# Phase 9: Auto-Scaling Policies
# Phase 10: AWS WAF
# Phase 11: CloudWatch Monitoring
# Phase 12: VPC Flow Logs
# Phase 13: RDS Read Replica
# ============================================================================
