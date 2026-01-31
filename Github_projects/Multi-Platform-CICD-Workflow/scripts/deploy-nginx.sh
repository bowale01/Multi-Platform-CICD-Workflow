#!/bin/bash

# NGINX Configuration Deployment Script
# Copies NGINX configs from repository to NGINX sites-available and enables them

set -e

echo "=========================================="
echo "NGINX Configuration Deployment"
echo "=========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NGINX_CONFIG_DIR="$SCRIPT_DIR/../nginx"

# Copy production config
echo "Deploying production configuration..."
cp "$NGINX_CONFIG_DIR/app-prod.conf" /etc/nginx/sites-available/
ln -sf /etc/nginx/sites-available/app-prod.conf /etc/nginx/sites-enabled/

# Copy staging config
echo "Deploying staging configuration..."
cp "$NGINX_CONFIG_DIR/app-staging.conf" /etc/nginx/sites-available/
ln -sf /etc/nginx/sites-available/app-staging.conf /etc/nginx/sites-enabled/

# Copy development config
echo "Deploying development configuration..."
cp "$NGINX_CONFIG_DIR/app-dev.conf" /etc/nginx/sites-available/
ln -sf /etc/nginx/sites-available/app-dev.conf /etc/nginx/sites-enabled/

# Remove default site
if [ -L /etc/nginx/sites-enabled/default ]; then
    echo "Removing default NGINX site..."
    rm /etc/nginx/sites-enabled/default
fi

# Test configuration
echo "Testing NGINX configuration..."
nginx -t

# Reload NGINX
echo "Reloading NGINX..."
systemctl reload nginx

echo ""
echo "=========================================="
echo "NGINX Configuration Deployed!"
echo "=========================================="
echo ""
echo "Configured sites:"
echo "  - Production: adelekeadebowale.com (port 3000)"
echo "  - Staging: staging.adelekeadebowale.com (port 3001)"
echo "  - Development: dev.adelekeadebowale.com (port 3002)"
echo ""
echo "Next step: Run provision-ssl.sh to enable HTTPS"
echo ""
