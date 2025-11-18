# ==============================================================================
# PHASE 6 SECURITY RULES - WEB TIER
# ==============================================================================
# Ingress: HTTP (80) from Web ALB Security Group
# Ingress: SSH (22) from Bastion Security Group
# Egress: All traffic (for internet access via NAT)
# ==============================================================================

# ------------------------------------------------------------------------------
# WEB TIER INGRESS RULES
# ------------------------------------------------------------------------------

# Allow HTTP from Web ALB Security Group
resource "aws_vpc_security_group_ingress_rule" "web_from_web_alb" {
  security_group_id            = aws_security_group.web.id
  description                  = "Allow HTTP from Web ALB"
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.web_alb.id

  tags = {
    Name = "${var.project_name}-${var.environment}-web-from-alb"
  }
}

# Allow SSH from Bastion Security Group
resource "aws_vpc_security_group_ingress_rule" "web_from_bastion" {
  security_group_id            = aws_security_group.web.id
  description                  = "Allow SSH from Bastion"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion.id

  tags = {
    Name = "${var.project_name}-${var.environment}-web-from-bastion"
  }
}

# ------------------------------------------------------------------------------
# WEB TIER EGRESS RULES
# ------------------------------------------------------------------------------

# Allow all outbound traffic (for package updates, etc.)
resource "aws_vpc_security_group_egress_rule" "web_egress_all" {
  security_group_id = aws_security_group.web.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "${var.project_name}-${var.environment}-web-egress-all"
  }
}
