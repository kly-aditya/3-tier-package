#!/bin/bash
# ============================================================================
# BASTION HOST INITIALIZATION SCRIPT
# ============================================================================
# This script:
# 1. Updates system packages
# 2. Installs required tools
# 3. Downloads web and app SSH keys from S3
# 4. Sets up proper permissions
# 5. Configures SSH for multi-hop access
# ============================================================================

set -e
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "======================================"
echo "Bastion Host Initialization Started"
echo "Time: $(date)"
echo "======================================"

# ============================================================================
# 1. SYSTEM UPDATE
# ============================================================================
echo "[1/6] Updating system packages..."
dnf update -y

# ============================================================================
# 2. INSTALL REQUIRED TOOLS
# ============================================================================
echo "[2/6] Installing required tools..."
dnf install -y \
    aws-cli \
    postgresql15 \
    telnet \
    nc \
    vim \
    htop \
    git

# ============================================================================
# 3. CREATE SSH DIRECTORY FOR ec2-user
# ============================================================================
echo "[3/6] Setting up SSH directory..."
mkdir -p /home/ec2-user/.ssh
chown ec2-user:ec2-user /home/ec2-user/.ssh
chmod 700 /home/ec2-user/.ssh

# ============================================================================
# 4. DOWNLOAD SSH KEYS FROM S3
# ============================================================================
echo "[4/6] Downloading SSH keys from S3..."

# Download web tier key
aws s3 cp s3://${s3_bucket_name}/${s3_key_prefix}/web/${project_name}-${environment}-web-key.pem \
    /home/ec2-user/.ssh/web-key.pem \
    --region ${region}

# Download app tier key
aws s3 cp s3://${s3_bucket_name}/${s3_key_prefix}/app/${project_name}-${environment}-app-key.pem \
    /home/ec2-user/.ssh/app-key.pem \
    --region ${region}

# ============================================================================
# 5. SET PROPER PERMISSIONS
# ============================================================================
echo "[5/6] Setting SSH key permissions..."
chmod 600 /home/ec2-user/.ssh/*.pem
chown ec2-user:ec2-user /home/ec2-user/.ssh/*.pem

# ============================================================================
# 6. CREATE SSH CONFIG FOR EASY ACCESS
# ============================================================================
echo "[6/6] Creating SSH config..."
cat > /home/ec2-user/.ssh/config <<'EOF'
# SSH Configuration for Multi-Tier Access

# Web Tier Access
Host web-*
    User ec2-user
    IdentityFile ~/.ssh/web-key.pem
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null

# App Tier Access
Host app-*
    User ec2-user
    IdentityFile ~/.ssh/app-key.pem
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null

# Global Settings
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
EOF

chmod 600 /home/ec2-user/.ssh/config
chown ec2-user:ec2-user /home/ec2-user/.ssh/config

# ============================================================================
# 7. CREATE HELPER SCRIPTS
# ============================================================================
echo "Creating helper scripts..."

# Script to list web instances
cat > /home/ec2-user/list-web-instances.sh <<'EOF'
#!/bin/bash
echo "Web Tier Instances:"
aws ec2 describe-instances \
    --filters "Name=tag:Tier,Values=web" "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[PrivateIpAddress,InstanceId,Tags[?Key==`Name`].Value|[0]]' \
    --output table \
    --region ${region}
EOF

# Script to list app instances
cat > /home/ec2-user/list-app-instances.sh <<'EOF'
#!/bin/bash
echo "App Tier Instances:"
aws ec2 describe-instances \
    --filters "Name=tag:Tier,Values=app" "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[PrivateIpAddress,InstanceId,Tags[?Key==`Name`].Value|[0]]' \
    --output table \
    --region ${region}
EOF

# Script to test web tier SSH
cat > /home/ec2-user/test-web-ssh.sh <<'EOF'
#!/bin/bash
WEB_IP=$(aws ec2 describe-instances \
    --filters "Name=tag:Tier,Values=web" "Name=instance-state-name,Values=running" \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text \
    --region ${region})

if [ "$WEB_IP" != "None" ]; then
    echo "Testing SSH to web instance: $WEB_IP"
    ssh -i ~/.ssh/web-key.pem -o StrictHostKeyChecking=no ec2-user@$WEB_IP "echo 'Web tier SSH: SUCCESS' && hostname"
else
    echo "No running web instances found"
fi
EOF

# Script to test app tier SSH
cat > /home/ec2-user/test-app-ssh.sh <<'EOF'
#!/bin/bash
APP_IP=$(aws ec2 describe-instances \
    --filters "Name=tag:Tier,Values=app" "Name=instance-state-name,Values=running" \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text \
    --region ${region})

if [ "$APP_IP" != "None" ]; then
    echo "Testing SSH to app instance: $APP_IP"
    ssh -i ~/.ssh/app-key.pem -o StrictHostKeyChecking=no ec2-user@$APP_IP "echo 'App tier SSH: SUCCESS' && hostname"
else
    echo "No running app instances found"
fi
EOF

# Make scripts executable
chmod +x /home/ec2-user/*.sh
chown ec2-user:ec2-user /home/ec2-user/*.sh

# ============================================================================
# 8. CREATE WELCOME MESSAGE
# ============================================================================
cat > /etc/motd <<'EOF'
╔══════════════════════════════════════════════════════════════╗
║                    BASTION HOST                              ║
║              Production 3-Tier Infrastructure                ║
╚══════════════════════════════════════════════════════════════╝

📋 Available Commands:
  ./list-web-instances.sh    - List all web tier instances
  ./list-app-instances.sh    - List all app tier instances
  ./test-web-ssh.sh          - Test SSH to web tier
  ./test-app-ssh.sh          - Test SSH to app tier

🔑 SSH Keys Available:
  ~/.ssh/web-key.pem         - Web tier access
  ~/.ssh/app-key.pem         - App tier access

💡 Quick SSH Examples:
  ssh -i ~/.ssh/web-key.pem ec2-user@<WEB_PRIVATE_IP>
  ssh -i ~/.ssh/app-key.pem ec2-user@<APP_PRIVATE_IP>

📊 Infrastructure Components:
  - VPC with 3 Availability Zones
  - Web Tier (Public Subnets + ALB)
  - App Tier (Private Subnets + Internal ALB)
  - RDS Multi-AZ Database

⚠️  Security Reminder:
  - This bastion has access to web and app tiers
  - All SSH sessions are logged
  - Use SSM Session Manager when possible

EOF

# ============================================================================
# COMPLETION
# ============================================================================
echo "======================================"
echo "Bastion Host Initialization Complete!"
echo "Time: $(date)"
echo "======================================"
echo "✅ System updated"
echo "✅ Tools installed"
echo "✅ SSH keys downloaded from S3"
echo "✅ Permissions configured"
echo "✅ Helper scripts created"
echo "======================================"

# Verify keys were downloaded
if [ -f /home/ec2-user/.ssh/web-key.pem ] && [ -f /home/ec2-user/.ssh/app-key.pem ]; then
    echo "✅ SSH Key Verification: SUCCESS"
    ls -lh /home/ec2-user/.ssh/*.pem
else
    echo "❌ SSH Key Verification: FAILED"
    echo "Keys not found in /home/ec2-user/.ssh/"
    exit 1
fi
