# ============================================================================
# PACKAGE 3: Production-Standard (3-AZ) Infrastructure
# ============================================================================
# PHASE 1: VPC & Basic Networking
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
# PHASE 1: VPC & NETWORKING RESOURCES
# ============================================================================

# ----------------------------------------------------------------------------
# VPC
# ----------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpc"
    }
  )
}

# ----------------------------------------------------------------------------
# Internet Gateway
# ----------------------------------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-igw"
    }
  )
}

# ----------------------------------------------------------------------------
# Public Subnets (Web Tier)
# ----------------------------------------------------------------------------

resource "aws_subnet" "public" {
  count = 3

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
      Tier = "Public"
      AZ   = local.availability_zones[count.index]
    }
  )
}

# ----------------------------------------------------------------------------
# Private Subnets - Application Tier
# ----------------------------------------------------------------------------

resource "aws_subnet" "private_app" {
  count = 3

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 11}.0/24"
  availability_zone = local.availability_zones[count.index]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-app-subnet-${count.index + 1}"
      Tier = "Application"
      AZ   = local.availability_zones[count.index]
    }
  )
}

# ----------------------------------------------------------------------------
# Private Subnets - Database Tier
# ----------------------------------------------------------------------------

resource "aws_subnet" "private_db" {
  count = 3

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 21}.0/24"
  availability_zone = local.availability_zones[count.index]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-db-subnet-${count.index + 1}"
      Tier = "Database"
      AZ   = local.availability_zones[count.index]
    }
  )
}

# ----------------------------------------------------------------------------
# Public Route Table
# ----------------------------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-rt"
      Type = "Public"
    }
  )
}

# ----------------------------------------------------------------------------
# Public Route to Internet Gateway
# ----------------------------------------------------------------------------

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# ----------------------------------------------------------------------------
# Public Route Table Associations
# ----------------------------------------------------------------------------

resource "aws_route_table_association" "public" {
  count = 3

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ============================================================================
# PHASE 1 COMPLETE
# ============================================================================
# Resources Created:
# - 1x VPC
# - 1x Internet Gateway
# - 3x Public Subnets
# - 3x Private App Subnets
# - 3x Private DB Subnets
# - 1x Public Route Table
# - 1x Route to Internet Gateway
# - 3x Route Table Associations
#
# Total: ~15 resources
# Cost: $0 (VPC and subnets are free!)
# ============================================================================

# ============================================================================
# NEXT PHASES (Not implemented yet):
# ============================================================================
# Phase 2: NAT Gateways (3x), Elastic IPs (3x), Private Route Tables
# Phase 3: Security Groups (6x, empty rules)
# Phase 4: Bastion Host module
# Phase 5: RDS Database module
# Phase 6-8: Compute tiers (Web & App)
# Phase 9-13: Auto-scaling, WAF, Monitoring, etc.
# ============================================================================
