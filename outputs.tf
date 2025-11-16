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
# Phase 4: Bastion public IP, Bastion security group ID
# Phase 5: RDS endpoint, read replica endpoint, RDS security group ID
# Phase 7: Web ALB DNS name, Web ALB ARN
# Phase 8: App ALB DNS name (internal), App ALB ARN
# Phase 11: CloudWatch dashboard URLs
# ============================================================================
