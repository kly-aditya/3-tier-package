# ============================================================================
# PHASE 1: Outputs
# ============================================================================

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

# ----------------------------------------------------------------------------
# PHASE 1: VPC Outputs
# ----------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "availability_zones" {
  description = "List of availability zones being used"
  value       = local.availability_zones
}

# ----------------------------------------------------------------------------
# Internet Gateway
# ----------------------------------------------------------------------------

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# ----------------------------------------------------------------------------
# Public Subnets
# ----------------------------------------------------------------------------

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = aws_subnet.public[*].cidr_block
}

# ----------------------------------------------------------------------------
# Private App Subnets
# ----------------------------------------------------------------------------

output "private_app_subnet_ids" {
  description = "List of private application subnet IDs"
  value       = aws_subnet.private_app[*].id
}

output "private_app_subnet_cidrs" {
  description = "List of private application subnet CIDR blocks"
  value       = aws_subnet.private_app[*].cidr_block
}

# ----------------------------------------------------------------------------
# Private DB Subnets
# ----------------------------------------------------------------------------

output "private_db_subnet_ids" {
  description = "List of private database subnet IDs"
  value       = aws_subnet.private_db[*].id
}

output "private_db_subnet_cidrs" {
  description = "List of private database subnet CIDR blocks"
  value       = aws_subnet.private_db[*].cidr_block
}

# ----------------------------------------------------------------------------
# Route Tables
# ----------------------------------------------------------------------------

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

# ----------------------------------------------------------------------------
# Summary Output (Helpful for quick verification)
# ----------------------------------------------------------------------------

output "phase1_summary" {
  description = "Summary of Phase 1 resources created"
  value = {
    vpc_id              = aws_vpc.main.id
    vpc_cidr            = aws_vpc.main.cidr_block
    availability_zones  = local.availability_zones
    public_subnets      = length(aws_subnet.public)
    private_app_subnets = length(aws_subnet.private_app)
    private_db_subnets  = length(aws_subnet.private_db)
    total_subnets       = length(aws_subnet.public) + length(aws_subnet.private_app) + length(aws_subnet.private_db)
  }
}

# ============================================================================
# Outputs to add in subsequent phases:
# ============================================================================
# Phase 2: NAT Gateway IDs, Elastic IPs, Private Route Table IDs
# ----------------------------------------------------------------------------

output "nat_gateway_eips" {
  description = "Elastic IPs assigned to NAT Gateways"
  value       = var.enable_nat_gateway ? aws_eip.nat[*].public_ip : []
}

output "nat_gateway_eip_ids" {
  description = "Allocation IDs of Elastic IPs for NAT Gateways"
  value       = var.enable_nat_gateway ? aws_eip.nat[*].id : []
}

# ----------------------------------------------------------------------------
# NAT Gateway IDs
# ----------------------------------------------------------------------------

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[*].id : []
}

# ----------------------------------------------------------------------------
# Private Route Tables
# ----------------------------------------------------------------------------

output "private_route_table_ids" {
  description = "IDs of private route tables (one per AZ)"
  value       = var.enable_nat_gateway ? aws_route_table.private[*].id : []
}

# ----------------------------------------------------------------------------
# Phase 2 Summary
# ----------------------------------------------------------------------------

output "phase2_summary" {
  description = "Summary of Phase 2 resources (NAT Gateways)"
  value = var.enable_nat_gateway ? {
    nat_gateways_count   = length(aws_nat_gateway.main)
    nat_gateway_ips      = aws_eip.nat[*].public_ip
    private_route_tables = length(aws_route_table.private)
    monthly_cost_estimate = "~$100 (3 NAT Gateways @ ~$32/each)"
  } : {
    nat_gateways_count   = 0
    nat_gateway_ips      = []
    private_route_tables = 0
    monthly_cost_estimate = "$0 (NAT Gateways disabled)"
  }
}

