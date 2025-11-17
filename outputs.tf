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

output "web_alb_security_group_id" {
  description = "ID of the Web ALB security group"
  value       = module.security.web_alb_security_group_id
}

output "web_security_group_id" {
  description = "ID of the Web Tier security group"
  value       = module.security.web_security_group_id
}

output "app_alb_security_group_id" {
  description = "ID of the App ALB security group"
  value       = module.security.app_alb_security_group_id
}

output "app_security_group_id" {
  description = "ID of the App Tier security group"
  value       = module.security.app_security_group_id
}

output "database_security_group_id" {
  description = "ID of the Database security group"
  value       = module.security.database_security_group_id
}

output "bastion_security_group_id" {
  description = "ID of the Bastion security group"
  value       = module.security.bastion_security_group_id
}

output "phase3_summary" {
  description = "Summary of Phase 3 deployment - Security Groups"
  value = {
    security_groups_created = 6
    cost_per_month         = "$0 (Security groups are free)"
    web_alb_sg_id          = module.security.web_alb_security_group_id
    web_sg_id              = module.security.web_security_group_id
    app_alb_sg_id          = module.security.app_alb_security_group_id
    app_sg_id              = module.security.app_security_group_id
    database_sg_id         = module.security.database_security_group_id
    bastion_sg_id          = module.security.bastion_security_group_id
    note                   = "Security group rules will be added in Phases 4-8"
  }
}


# Phase 4 Outputs - Bastion with Automated Key Pair
# ==============================================================================

# Key Pair Outputs
output "bastion_key_pair_name" {
  description = "Name of the bastion key pair"
  value       = module.bastion_key_pair.key_pair_name
}

output "bastion_private_key_pem" {
  description = "Private key for bastion SSH access (SAVE THIS!)"
  value       = module.bastion_key_pair.private_key_pem
  sensitive   = true
}

# Bastion Outputs
output "bastion_public_ip" {
  description = "Public IP address of bastion host"
  value       = module.bastion.bastion_eip
}

output "bastion_ssh_command" {
  description = "SSH command to connect to bastion (after saving private key)"
  value       = "ssh -i ~/.ssh/${var.project_name}-bastion-key.pem ec2-user@${module.bastion.bastion_eip}"
}

output "bastion_asg_name" {
  description = "Name of bastion Auto Scaling Group"
  value       = module.bastion.bastion_asg_name
}

# Instructions Output
output "save_private_key_instructions" {
  description = "How to save your private key and connect"
  value       = <<-EOT
    
    ═══════════════════════════════════════════════════════════════
    🔑 SAVE YOUR PRIVATE KEY (Do this immediately!)
    ═══════════════════════════════════════════════════════════════
    
    Step 1: Save the private key to a file:
    ──────────────────────────────────────
    terraform output -raw bastion_private_key_pem > ~/.ssh/${var.project_name}-bastion-key.pem
    
    Step 2: Set correct permissions:
    ────────────────────────────────
    chmod 400 ~/.ssh/${var.project_name}-bastion-key.pem
    
    Step 3: Connect to bastion:
    ───────────────────────────
    ssh -i ~/.ssh/${var.project_name}-bastion-key.pem ec2-user@${module.bastion.bastion_eip}
    
    ⚠️  IMPORTANT: Save this key NOW! It's only available in Terraform state.
    
    ═══════════════════════════════════════════════════════════════
  EOT
}

# Summary
output "phase4_summary" {
  description = "Summary of Phase 4 deployment"
  value = {
    bastion_public_ip  = module.bastion.bastion_eip
    instance_type      = "t3.micro"
    key_pair_name      = module.bastion_key_pair.key_pair_name
    cost_per_month     = "~$8 (t3.micro)"
    security_group_id  = module.security.bastion_security_group_id
    ssh_access_from    = var.my_ip
    note               = "Private key is in Terraform state - extract it immediately!"
  }
}
