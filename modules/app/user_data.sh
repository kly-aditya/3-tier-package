#!/bin/bash
# ==============================================================================
# APP TIER USER DATA SCRIPT - PHASE 8
# ==============================================================================
# Installs and configures:
# - Node.js
# - PostgreSQL client
# - Simple API server
# ==============================================================================

set -e

# ------------------------------------------------------------------------------
# LOGGING
# ------------------------------------------------------------------------------
exec > >(tee -a /var/log/user-data.log)
exec 2>&1

echo "=========================================="
echo "App Tier Initialization Started"
echo "Date: $(date)"
echo "Environment: ${environment}"
echo "=========================================="

# ------------------------------------------------------------------------------
# SYSTEM UPDATE
# ------------------------------------------------------------------------------
echo "[INFO] Updating system packages..."
dnf update -y

# ------------------------------------------------------------------------------
# INSTALL NODE.JS
# ------------------------------------------------------------------------------
echo "[INFO] Installing Node.js..."
dnf install -y nodejs npm

# ------------------------------------------------------------------------------
# INSTALL POSTGRESQL CLIENT
# ------------------------------------------------------------------------------
echo "[INFO] Installing PostgreSQL client..."
dnf install -y postgresql15

# ------------------------------------------------------------------------------
# CREATE APP DIRECTORY
# ------------------------------------------------------------------------------
echo "[INFO] Creating app directory..."
mkdir -p /opt/app
cd /opt/app

# ------------------------------------------------------------------------------
# CREATE SIMPLE API SERVER
# ------------------------------------------------------------------------------
echo "[INFO] Creating API server..."

cat > /opt/app/server.js << 'EOFJS'
const http = require('http');
const { execSync } = require('child_process');

const PORT = 3000;
const ENV = process.env.ENVIRONMENT || 'unknown';

// Get instance metadata
function getMetadata(path) {
    try {
        return execSync(`curl -s http://169.254.169.254/latest/meta-data/$${path}`).toString().trim();
    } catch (e) {
        return 'Unknown';
    }
}

const INSTANCE_ID = getMetadata('instance-id');
const AZ = getMetadata('placement/availability-zone');
const PRIVATE_IP = getMetadata('local-ipv4');

// Health check endpoint
function handleHealth(res) {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('OK');
}

// Info endpoint
function handleInfo(res) {
    const info = {
        status: 'running',
        environment: ENV,
        instance_id: INSTANCE_ID,
        availability_zone: AZ,
        private_ip: PRIVATE_IP,
        nodejs_version: process.version,
        uptime_seconds: Math.floor(process.uptime()),
        timestamp: new Date().toISOString()
    };
    
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(info, null, 2));
}

// Database test endpoint
function handleDbTest(res) {
    try {
        const result = execSync('psql --version').toString();
        const dbInfo = {
            postgresql_client: result.trim(),
            db_endpoint: process.env.DB_ENDPOINT || 'Not configured',
            db_name: process.env.DB_NAME || 'Not configured',
            status: 'client_installed'
        };
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(dbInfo, null, 2));
    } catch (e) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: e.message }));
    }
}

// Main request handler
const server = http.createServer((req, res) => {
    console.log(`$${new Date().toISOString()} - $${req.method} $${req.url}`);
    
    if (req.url === '/health') {
        handleHealth(res);
    } else if (req.url === '/api/info' || req.url === '/') {
        handleInfo(res);
    } else if (req.url === '/api/db-test') {
        handleDbTest(res);
    } else {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('Not Found');
    }
});

server.listen(PORT, () => {
    console.log(`App server listening on port $${PORT}`);
    console.log(`Environment: $${ENV}`);
    console.log(`Instance: $${INSTANCE_ID}`);
});
EOFJS

# Set environment variables
cat > /opt/app/.env << EOF
ENVIRONMENT=${environment}
DB_ENDPOINT=${db_endpoint}
DB_NAME=${db_name}
DB_USERNAME=${db_username}
DB_SECRET_NAME=${db_secret_name}
EOF

# ------------------------------------------------------------------------------
# CREATE SYSTEMD SERVICE
# ------------------------------------------------------------------------------
echo "[INFO] Creating systemd service..."

cat > /etc/systemd/system/app-server.service << 'EOF'
[Unit]
Description=Application Server
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/app
EnvironmentFile=/opt/app/.env
ExecStart=/usr/bin/node /opt/app/server.js
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Set permissions
chown -R ec2-user:ec2-user /opt/app
chmod +x /opt/app/server.js

# ------------------------------------------------------------------------------
# START SERVICE
# ------------------------------------------------------------------------------
echo "[INFO] Starting app server..."
systemctl daemon-reload
systemctl enable app-server
systemctl start app-server

# Verify service is running
sleep 5
if systemctl is-active --quiet app-server; then
    echo "[SUCCESS] App server is running"
else
    echo "[ERROR] App server failed to start"
    systemctl status app-server
    exit 1
fi

# ------------------------------------------------------------------------------
# VERIFICATION
# ------------------------------------------------------------------------------
echo "[INFO] Verifying app server..."

# Test health endpoint
if curl -s http://localhost:3000/health | grep -q "OK"; then
    echo "[SUCCESS] Health check endpoint working"
else
    echo "[ERROR] Health check endpoint not responding"
fi

# Test info endpoint
if curl -s http://localhost:3000/api/info | grep -q "running"; then
    echo "[SUCCESS] Info endpoint working"
else
    echo "[ERROR] Info endpoint not responding"
fi

# ------------------------------------------------------------------------------
# COMPLETION
# ------------------------------------------------------------------------------
echo "=========================================="
echo "App Tier Initialization Completed"
echo "Date: $(date)"
echo "=========================================="

# Display service status
systemctl status app-server --no-pager
