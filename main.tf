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

# ============================================================================
# PHASE 2: NAT GATEWAYS & PRIVATE ROUTING
# ============================================================================
# Add this code to the END of your main.tf file
# (after Phase 1 resources)
# ============================================================================

# ----------------------------------------------------------------------------
# Elastic IPs for NAT Gateways
# ----------------------------------------------------------------------------

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 3 : 0
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-eip-${count.index + 1}"
      AZ   = local.availability_zones[count.index]
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# ----------------------------------------------------------------------------
# NAT Gateways (one per AZ)
# ----------------------------------------------------------------------------

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? 3 : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-gateway-${count.index + 1}"
      AZ   = local.availability_zones[count.index]
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# ----------------------------------------------------------------------------
# Private Route Tables (one per AZ)
# ----------------------------------------------------------------------------

resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? 3 : 0

  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-rt-${count.index + 1}"
      Type = "Private"
      AZ   = local.availability_zones[count.index]
    }
  )
}

# ----------------------------------------------------------------------------
# Routes to NAT Gateways
# ----------------------------------------------------------------------------

resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? 3 : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

# ----------------------------------------------------------------------------
# Private App Subnet Route Table Associations
# ----------------------------------------------------------------------------

resource "aws_route_table_association" "private_app" {
  count = var.enable_nat_gateway ? 3 : 0

  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ----------------------------------------------------------------------------
# Private DB Subnet Route Table Associations
# ----------------------------------------------------------------------------

resource "aws_route_table_association" "private_db" {
  count = var.enable_nat_gateway ? 3 : 0

  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ============================================================================


# Phase 4: Bastion with Automated Key Pair

# Step 1: Create SSH Key Pair (Automated!)
module "bastion_key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0"

  key_name           = "${var.project_name}-${var.environment}-bastion-key"
  create_private_key = true

  tags = merge(
    local.common_tags,
    {
      Name      = "${var.project_name}-${var.environment}-bastion-key"
      Component = "bastion"
      Phase     = "4"
    }
  )
}

# Step 2: Update security module to include bastion rules

module "security" {
  source = "./modules/security"

  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = aws_vpc.main.id
  allowed_ssh_cidr = var.my_ip

  tags = local.common_tags
}

# Step 3: Deploy Bastion
module "bastion" {
  source = "./modules/bastion"

  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = aws_vpc.main.id
  public_subnet_ids         = [for subnet in aws_subnet.public : subnet.id]
  bastion_security_group_id = module.security.bastion_security_group_id
  instance_type             = "t3.micro"
  key_name                  = module.bastion_key_pair.key_pair_name  # ← Automated!
  allowed_ssh_cidr          = var.my_ip

  tags = local.common_tags
  
  depends_on = [module.bastion_key_pair]
}
