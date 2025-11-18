#!/bin/bash
# ==============================================================================
# WEB TIER USER DATA SCRIPT - PHASE 6
# ==============================================================================
# Installs and configures:
# - Apache HTTP Server
# - PHP 8.x
# - Simple test page with health check endpoint
# ==============================================================================

set -e  # Exit on any error

# ------------------------------------------------------------------------------
# LOGGING
# ------------------------------------------------------------------------------
exec > >(tee -a /var/log/user-data.log)
exec 2>&1

echo "=========================================="
echo "Web Tier Initialization Started"
echo "Date: $(date)"
echo "Environment: ${environment}"
echo "=========================================="

# ------------------------------------------------------------------------------
# SYSTEM UPDATE
# ------------------------------------------------------------------------------
echo "[INFO] Updating system packages..."
dnf update -y

# ------------------------------------------------------------------------------
# INSTALL APACHE & PHP
# ------------------------------------------------------------------------------
echo "[INFO] Installing Apache HTTP Server..."
dnf install -y httpd

echo "[INFO] Installing PHP 8.x and extensions..."
dnf install -y php php-cli php-common php-json php-mbstring php-xml

# ------------------------------------------------------------------------------
# CONFIGURE APACHE
# ------------------------------------------------------------------------------
echo "[INFO] Configuring Apache..."

# Enable and start Apache
systemctl enable httpd
systemctl start httpd

# ------------------------------------------------------------------------------
# CREATE TEST PAGE
# ------------------------------------------------------------------------------
echo "[INFO] Creating test page..."

cat > /var/www/html/index.php << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Package 3 - Web Tier</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .container {
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            padding: 40px;
            max-width: 800px;
            width: 100%;
        }
        h1 {
            color: #667eea;
            margin-top: 0;
        }
        .info-box {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 15px;
            margin: 15px 0;
            border-radius: 5px;
        }
        .info-box strong {
            color: #764ba2;
        }
        .status {
            display: inline-block;
            padding: 5px 15px;
            background: #28a745;
            color: white;
            border-radius: 20px;
            font-weight: bold;
            margin: 10px 0;
        }
        .footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 2px solid #e9ecef;
            color: #6c757d;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Package 3 - Production 3-Tier Architecture</h1>
        <div class="status">✓ Web Tier Active</div>
        
        <div class="info-box">
            <strong>Environment:</strong> ${environment}
        </div>
        
        <div class="info-box">
            <strong>Server Hostname:</strong> <?php echo gethostname(); ?>
        </div>
        
        <div class="info-box">
            <strong>Server IP:</strong> <?php echo $_SERVER['SERVER_ADDR']; ?>
        </div>
        
        <div class="info-box">
            <strong>PHP Version:</strong> <?php echo phpversion(); ?>
        </div>
        
        <div class="info-box">
            <strong>Apache Version:</strong> <?php echo apache_get_version(); ?>
        </div>
        
        <div class="info-box">
            <strong>Availability Zone:</strong> <?php
                $az = @file_get_contents('http://169.254.169.254/latest/meta-data/placement/availability-zone');
                echo $az ? $az : 'Unknown';
            ?>
        </div>
        
        <div class="info-box">
            <strong>Instance ID:</strong> <?php
                $instance_id = @file_get_contents('http://169.254.169.254/latest/meta-data/instance-id');
                echo $instance_id ? $instance_id : 'Unknown';
            ?>
        </div>
        
        <div class="info-box">
            <strong>Request Time:</strong> <?php echo date('Y-m-d H:i:s'); ?>
        </div>

        <div class="footer">
            <strong>Phase 6:</strong> Web Tier Deployment<br>
            <strong>Architecture:</strong> Auto Scaling Group across 3 Availability Zones<br>
            <strong>Health Check:</strong> <a href="/health">/health</a>
        </div>
    </div>
</body>
</html>
EOF

# ------------------------------------------------------------------------------
# CREATE HEALTH CHECK ENDPOINT
# ------------------------------------------------------------------------------
echo "[INFO] Creating health check endpoint..."

cat > /var/www/html/health << 'EOF'
OK
EOF

# Set proper permissions
chmod 644 /var/www/html/index.php
chmod 644 /var/www/html/health

# ------------------------------------------------------------------------------
# RESTART APACHE
# ------------------------------------------------------------------------------
echo "[INFO] Restarting Apache to apply changes..."
systemctl restart httpd

# Verify Apache is running
if systemctl is-active --quiet httpd; then
    echo "[SUCCESS] Apache is running"
else
    echo "[ERROR] Apache failed to start"
    systemctl status httpd
    exit 1
fi

# ------------------------------------------------------------------------------
# VERIFICATION
# ------------------------------------------------------------------------------
echo "[INFO] Verifying web server..."

# Test health endpoint
if curl -s http://localhost/health | grep -q "OK"; then
    echo "[SUCCESS] Health check endpoint working"
else
    echo "[ERROR] Health check endpoint not responding"
fi

# Test PHP
if curl -s http://localhost/index.php | grep -q "Package 3"; then
    echo "[SUCCESS] PHP page working"
else
    echo "[ERROR] PHP page not responding"
fi

# ------------------------------------------------------------------------------
# COMPLETION
# ------------------------------------------------------------------------------
echo "=========================================="
echo "Web Tier Initialization Completed"
echo "Date: $(date)"
echo "=========================================="

# Display Apache status
systemctl status httpd --no-pager
