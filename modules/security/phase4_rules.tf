# Phase: 4 - Bastion Host
# ==============================================================================

# ------------------------------------------------------------------------------
# Bastion Security Group Rules
# ------------------------------------------------------------------------------

# Inbound: SSH from allowed CIDR (your IP)
resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion.id
  description       = "Allow SSH from allowed CIDR"
  
  cidr_ipv4   = var.allowed_ssh_cidr
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"

  tags = {
    Name = "bastion-ssh-inbound"
  }
}

# Outbound: All traffic (for yum updates, etc.)
resource "aws_vpc_security_group_egress_rule" "bastion_all" {
  security_group_id = aws_security_group.bastion.id
  description       = "Allow all outbound traffic"
  
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = {
    Name = "bastion-all-outbound"
  }
}
