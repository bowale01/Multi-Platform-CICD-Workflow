#!/bin/bash

# Script to configure NGINX on EC2 for multi-platform setup
# Run this script ON YOUR EC2 INSTANCE

set -e

echo "=========================================="
echo "Configuring NGINX for Multi-Platform"
echo "=========================================="
echo ""

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo: sudo ./5-configure-nginx.sh"
    exit 1
fi

# Create configurations for dev and staging
echo "Creating NGINX configurations..."
echo ""

# Dev configuration
echo "1. Creating dev.adelekeadebowale.com configuration..."
cat > /etc/nginx/sites-available/dev-adelekeadebowale << 'EOF'
server {
    listen 80;
    server_name dev.adelekeadebowale.com;
    
    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

echo "✓ Dev configuration created"

# Staging configuration
echo "2. Creating staging.adelekeadebowale.com configuration..."
cat > /etc/nginx/sites-available/staging-adelekeadebowale << 'EOF'
server {
    listen 80;
    server_name staging.adelekeadebowale.com;
    
    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

echo "✓ Staging configuration created"
echo ""

# Enable sites
echo "Enabling sites..."
ln -sf /etc/nginx/sites-available/dev-adelekeadebowale /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/staging-adelekeadebowale /etc/nginx/sites-enabled/
echo "✓ Sites enabled"
echo ""

# Test NGINX configuration
echo "Testing NGINX configuration..."
nginx -t

if [ $? -eq 0 ]; then
    echo "✓ NGINX configuration is valid"
    echo ""
    echo "Reloading NGINX..."
    systemctl reload nginx
    echo "✓ NGINX reloaded"
else
    echo "❌ NGINX configuration test failed"
    exit 1
fi

echo ""
echo "=========================================="
echo "NGINX Configuration Complete!"
echo "=========================================="
echo ""
echo "Configurations created:"
echo "  - dev.adelekeadebowale.com → Port 3002"
echo "  - staging.adelekeadebowale.com → Port 3001"
echo ""
echo "Next steps:"
echo "1. Provision SSL certificates: sudo ./6-provision-ssl.sh"
echo "2. Deploy containers via GitHub Actions"
echo ""
