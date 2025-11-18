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

# Phase 2: NAT Gateways (3x), Elastic IPs (3x), Private Route Tables

# ============================================================================

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


# PHASE 5: RDS DATABASE
# ============================================================================
# ADD THIS TO THE END OF YOUR EXISTING main.tf FILE:

module "database" {
  source = "./modules/database"

  project_name              = var.project_name
  environment               = var.environment
  db_subnet_ids             = aws_subnet.private_db[*].id
  database_security_group_id = module.security.database_security_group_id

  # Database configuration
  db_instance_class            = var.db_instance_class
  db_name                      = var.db_name
  db_master_username           = var.db_master_username
  postgres_version             = var.postgres_version
  postgres_major_version       = var.postgres_major_version
  
  # Storage
  allocated_storage            = var.db_allocated_storage
  max_allocated_storage        = var.db_max_allocated_storage
  storage_type                 = var.db_storage_type
  
  # High Availability
  multi_az                     = var.db_multi_az
  
  # Backup
  backup_retention_days        = var.db_backup_retention_days
  backup_window                = var.db_backup_window
  maintenance_window           = var.db_maintenance_window
  skip_final_snapshot          = var.db_skip_final_snapshot
  
  # Monitoring
  monitoring_interval                = var.db_monitoring_interval
  performance_insights_enabled       = var.db_performance_insights_enabled
  performance_insights_retention     = var.db_performance_insights_retention
  log_retention_days                 = var.db_log_retention_days
  
  # Parameters
  max_connections              = var.db_max_connections
  log_statement                = var.db_log_statement
  log_min_duration_ms          = var.db_log_min_duration_ms
  
  # Protection
  deletion_protection          = var.db_deletion_protection
  auto_minor_version_upgrade   = var.db_auto_minor_version_upgrade

  tags = local.common_tags
}


# ==============================================================================
# PHASE 6: WEB TIER MODULE
# ==============================================================================

module "web" {
  source = "./modules/web"

  project_name = var.project_name
  environment  = var.environment

  # Networking
  public_subnet_ids = aws_subnet.public[*].id
  web_sg_id         = module.security.web_security_group_id

  # Instance configuration
  instance_type     = var.web_instance_type
  root_volume_size  = var.web_root_volume_size

  # Auto Scaling
  asg_min_size         = var.web_asg_min_size
  asg_desired_capacity = var.web_asg_desired_capacity
  asg_max_size         = var.web_asg_max_size

  common_tags = local.common_tags
}


# PHASE 7: WEB APPLICATION LOAD BALANCER
# ==============================================================================

module "web_alb" {
  source = "./modules/alb"

  project_name = var.project_name
  environment  = var.environment

  # Networking
  vpc_id             = aws_vpc.main.id
  public_subnet_ids  = aws_subnet.public[*].id
  web_alb_sg_id      = module.security.web_alb_security_group_id

  # Auto Scaling Group
  web_asg_name = module.web.autoscaling_group_name

  # ALB Configuration
  enable_deletion_protection = var.alb_enable_deletion_protection

  # Health Check
  health_check_path                = var.alb_health_check_path
  health_check_interval            = var.alb_health_check_interval
  health_check_timeout             = var.alb_health_check_timeout
  health_check_healthy_threshold   = var.alb_health_check_healthy_threshold
  health_check_unhealthy_threshold = var.alb_health_check_unhealthy_threshold
  deregistration_delay             = var.alb_deregistration_delay

  # Stickiness
  enable_stickiness    = var.alb_enable_stickiness
  stickiness_duration  = var.alb_stickiness_duration

  common_tags = local.common_tags
}


# PHASE 8: APPLICATION TIER
# ==============================================================================

module "app" {
  source = "./modules/app"

  project_name = var.project_name
  environment  = var.environment

  # Networking
  private_app_subnet_ids = aws_subnet.private_app[*].id
  app_sg_id              = module.security.app_security_group_id

  # Database
  db_secret_name = module.database.db_secret_name
  db_endpoint    = module.database.db_instance_address
  db_name        = module.database.db_name
  db_username    = module.database.db_master_username

  # Instance configuration
  instance_type    = var.app_instance_type
  root_volume_size = var.app_root_volume_size

  # Auto Scaling
  asg_min_size         = var.app_asg_min_size
  asg_desired_capacity = var.app_asg_desired_capacity
  asg_max_size         = var.app_asg_max_size

  common_tags = local.common_tags
}