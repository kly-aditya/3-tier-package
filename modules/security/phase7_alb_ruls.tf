
# PHASE 7 SECURITY RULES - WEB ALB
# ==============================================================================
# ALB ingress: HTTP from internet (0.0.0.0/0)
# ALB egress: HTTP to Web tier
# ==============================================================================

# ------------------------------------------------------------------------------
# WEB ALB INGRESS RULES
# ------------------------------------------------------------------------------

# Allow HTTP from internet
resource "aws_vpc_security_group_ingress_rule" "web_alb_http_ingress" {
  security_group_id = aws_security_group.web_alb.id
  description       = "Allow HTTP from internet"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "${var.project_name}-${var.environment}-web-alb-http-ingress"
  }
}

# ------------------------------------------------------------------------------
# WEB ALB EGRESS RULES
# ------------------------------------------------------------------------------

# Allow HTTP to Web tier
resource "aws_vpc_security_group_egress_rule" "web_alb_to_web" {
  security_group_id            = aws_security_group.web_alb.id
  description                  = "Allow HTTP to Web tier"
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.web.id

  tags = {
    Name = "${var.project_name}-${var.environment}-web-alb-to-web"
  }
}
