# 1. Web ALB Security Group
# ------------------------------------------------------------------------------
# Purpose: Controls traffic to public-facing Web Application Load Balancer
# Future Rules (Phase 7): HTTPS (443) from internet, HTTP (80) redirect

resource "aws_security_group" "web_alb" {
  name_prefix = "${var.project_name}-${var.environment}-web-alb-"
  description = "Security group for Web Tier Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-web-alb-sg"
      Tier      = "public"
      Component = "web-load-balancer"
      Phase     = "3"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# 2. Web Tier Security Group
# ------------------------------------------------------------------------------
# Purpose: Controls traffic to web tier EC2 instances in public subnets
# Future Rules (Phase 6-7): HTTP from Web ALB, SSH from Bastion

resource "aws_security_group" "web" {
  name_prefix = "${var.project_name}-${var.environment}-web-"
  description = "Security group for Web Tier EC2 instances"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-web-sg"
      Tier      = "public"
      Component = "web-servers"
      Phase     = "3"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# 3. App ALB Security Group
# ------------------------------------------------------------------------------
# Purpose: Controls traffic to internal App Application Load Balancer
# Future Rules (Phase 8): HTTP/Custom port from Web Tier SG

resource "aws_security_group" "app_alb" {
  name_prefix = "${var.project_name}-${var.environment}-app-alb-"
  description = "Security group for App Tier Application Load Balancer (Internal)"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-app-alb-sg"
      Tier      = "private"
      Component = "app-load-balancer"
      Phase     = "3"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# 4. App Tier Security Group
# ------------------------------------------------------------------------------
# Purpose: Controls traffic to application tier EC2 instances in private subnets
# Future Rules (Phase 8): Custom app port from App ALB, SSH from Bastion

resource "aws_security_group" "app" {
  name_prefix = "${var.project_name}-${var.environment}-app-"
  description = "Security group for Application Tier EC2 instances"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-app-sg"
      Tier      = "private"
      Component = "app-servers"
      Phase     = "3"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# 5. Database Security Group
# ------------------------------------------------------------------------------
# Purpose: Controls traffic to RDS PostgreSQL database in private subnets
# Future Rules (Phase 5): PostgreSQL (5432) from App Tier only

resource "aws_security_group" "database" {
  name_prefix = "${var.project_name}-${var.environment}-db-"
  description = "Security group for RDS PostgreSQL Database"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-db-sg"
      Tier      = "private"
      Component = "database"
      Phase     = "3"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# 6. Bastion Security Group
# ------------------------------------------------------------------------------
# Purpose: Controls traffic to bastion/jump box for secure SSH access
# Future Rules (Phase 4): SSH (22) from your IP only

resource "aws_security_group" "bastion" {
  name_prefix = "${var.project_name}-${var.environment}-bastion-"
  description = "Security group for Bastion Host (Jump Box)"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-bastion-sg"
      Tier      = "public"
      Component = "bastion"
      Phase     = "3"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
