#!/bin/bash
# ==============================================================================
# Bastion Host User Data Script
# ==============================================================================
# Purpose: Bootstrap script for bastion host setup
# Phase: 4 - Bastion Host
# ==============================================================================

set -e  # Exit on any error

# Logging setup
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "==== Bastion Host Setup Started at $(date) ===="

# Update system packages
echo "==> Updating system packages..."
dnf update -y

# Install useful tools
echo "==> Installing useful tools..."
dnf install -y --skip-broken \
    vim \
    wget \
    git \
    htop \
    tmux \
    net-tools \
    telnet \
    nc \
    bind-utils

# Install PostgreSQL client (for testing RDS connection later)
echo "==> Installing PostgreSQL 15 client..."
dnf install -y postgresql15

# Configure SSH
echo "==> Configuring SSH..."
# Allow SSH agent forwarding
sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding yes/' /etc/ssh/sshd_config
systemctl restart sshd

# Set hostname
echo "==> Setting hostname..."
hostnamectl set-hostname bastion-host

# Configure timezone (adjust as needed)
echo "==> Setting timezone to UTC..."
timedatectl set-timezone UTC

# Create a welcome message
cat > /etc/motd << 'MOTD'
================================================================================
   🛡️  BASTION HOST - Package3 Production Environment
================================================================================
   
   This is a jump box for secure access to private resources.
   
   Important Notes:
   - Always use SSH agent forwarding: ssh -A
   - Never store private keys on this host
   - All activities are logged
   
   Installed Tools:
   - PostgreSQL 15 client (psql)
   - vim, curl, wget, git
   - htop, tmux, net-tools
   
   Next Steps:
   - Connect to web tier: ssh ec2-user@<web-private-ip>
   - Connect to app tier: ssh ec2-user@<app-private-ip>
   - Test RDS: psql -h <rds-endpoint> -U dbadmin -d postgres
   
================================================================================
MOTD

# Install CloudWatch agent (optional, for monitoring)
echo "==> Installing CloudWatch agent..."
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm
rm -f ./amazon-cloudwatch-agent.rpm

# Enable automatic security updates
echo "==> Enabling automatic security updates..."
dnf install -y dnf-automatic
sed -i 's/apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf
systemctl enable --now dnf-automatic.timer

echo "==== Bastion Host Setup Completed at $(date) ===="
echo "==> System ready for use!"
