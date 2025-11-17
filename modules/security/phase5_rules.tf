# ==============================================================================
# Phase 5: Database Security Group Rules
# ==============================================================================
# Purpose: Allow PostgreSQL access to database from App Tier and Bastion
# Phase: 5 - Database Tier
# ==============================================================================

# ------------------------------------------------------------------------------
# Database Ingress Rules
# ------------------------------------------------------------------------------

# Allow PostgreSQL access from App Tier to Database
resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id = aws_security_group.database.id

  description                  = "PostgreSQL from App Tier"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.app.id

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-db-from-app-tier"
      Component = "database"
      Phase     = "5"
    }
  )
}

# Allow PostgreSQL access from Bastion (for testing and troubleshooting)
resource "aws_vpc_security_group_ingress_rule" "db_from_bastion" {
  security_group_id = aws_security_group.database.id

  description                  = "PostgreSQL from Bastion (for testing)"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion.id

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-db-from-bastion"
      Component = "database"
      Phase     = "5"
      Purpose   = "Testing and troubleshooting"
    }
  )
}

# ------------------------------------------------------------------------------
# Database Egress Rules
# ------------------------------------------------------------------------------

# Allow all outbound traffic (standard practice for RDS)
resource "aws_vpc_security_group_egress_rule" "db_all_outbound" {
  security_group_id = aws_security_group.database.id

  description = "Allow all outbound traffic"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = merge(
    var.tags,
    {
      Name      = "${var.project_name}-${var.environment}-db-all-outbound"
      Component = "database"
      Phase     = "5"
    }
  )
}
