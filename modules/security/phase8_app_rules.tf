# PHASE 8 SECURITY RULES - APP TIER
# ==============================================================================
# Ingress: Port 3000 from App ALB Security Group
# Ingress: SSH (22) from Bastion Security Group
# Egress: PostgreSQL (5432) to Database Security Group
# Egress: All traffic (for internet via NAT)
# ==============================================================================

# ------------------------------------------------------------------------------
# APP TIER INGRESS RULES
# ------------------------------------------------------------------------------

# Allow app traffic (port 3000) from App ALB Security Group
resource "aws_vpc_security_group_ingress_rule" "app_from_app_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "Allow app traffic from App ALB"
  from_port                    = 3000
  to_port                      = 3000
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.app_alb.id

  tags = {
    Name = "${var.project_name}-${var.environment}-app-from-app-alb"
  }
}

# Allow SSH from Bastion Security Group
resource "aws_vpc_security_group_ingress_rule" "app_from_bastion" {
  security_group_id            = aws_security_group.app.id
  description                  = "Allow SSH from Bastion"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion.id

  tags = {
    Name = "${var.project_name}-${var.environment}-app-from-bastion"
  }
}

# ------------------------------------------------------------------------------
# APP TIER EGRESS RULES
# ------------------------------------------------------------------------------



# Allow PostgreSQL to Database Security Group
resource "aws_vpc_security_group_egress_rule" "app_to_database" {
  security_group_id            = aws_security_group.app.id
  description                  = "Allow PostgreSQL to Database"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.database.id

  tags = {
    Name = "${var.project_name}-${var.environment}-app-to-database"
  }
}


# Allow all outbound traffic (for NAT Gateway internet access)
resource "aws_vpc_security_group_egress_rule" "app_egress_all" {
  security_group_id = aws_security_group.app.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "${var.project_name}-${var.environment}-app-egress-all"
  }
}

/*

# ------------------------------------------------------------------------------
# DATABASE INGRESS RULE (allow from App tier)
# ------------------------------------------------------------------------------

# Allow PostgreSQL from App tier (in addition to existing bastion rule)
resource "aws_vpc_security_group_ingress_rule" "database_from_app" {
  security_group_id            = aws_security_group.database.id
  description                  = "Allow PostgreSQL from App tier"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.app.id

  tags = {
    Name = "${var.project_name}-${var.environment}-database-from-app"
  }
}
*/