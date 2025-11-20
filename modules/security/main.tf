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

# APP ALB SECURITY GROUP
# ------------------------------------------------------------------------------

resource "aws_security_group" "app_alb" {
  name_prefix = "${var.project_name}-${var.environment}-app-alb-sg-"
  description = "Security group for internal app ALB"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-app-alb-sg"
      Tier = "app-alb"
      
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Inbound: Allow HTTP from Web Security Group
resource "aws_security_group_rule" "app_alb_inbound_from_web" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
  security_group_id        = aws_security_group.app_alb.id
  description              = "Allow HTTP from Web tier"
}

# Outbound: Allow HTTP to App Security Group on port 3000
resource "aws_security_group_rule" "app_alb_outbound_to_app" {
  type                     = "egress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  security_group_id        = aws_security_group.app_alb.id
  description              = "Allow HTTP to App tier on port 3000"
}

# ------------------------------------------------------------------------------
# UPDATE APP SECURITY GROUP - Add rule to allow traffic from App ALB
# ------------------------------------------------------------------------------

resource "aws_security_group_rule" "app_inbound_from_app_alb" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_alb.id
  security_group_id        = aws_security_group.app.id
  description              = "Allow HTTP from App ALB on port 3000"
}

# ------------------------------------------------------------------------------
# UPDATE WEB SECURITY GROUP - Add rule to allow outbound to App ALB
# ------------------------------------------------------------------------------

resource "aws_security_group_rule" "web_outbound_to_app_alb" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_alb.id
  security_group_id        = aws_security_group.web.id
  description              = "Allow HTTP to App ALB"
}





