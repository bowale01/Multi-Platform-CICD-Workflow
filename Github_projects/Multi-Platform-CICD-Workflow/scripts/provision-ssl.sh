#!/bin/bash

# SSL Certificate Provisioning Script
# Run this script on your EC2 instance after NGINX is configured

set -e

echo "=========================================="
echo "SSL Certificate Provisioning"
echo "=========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Provision SSL for production domain
echo "Provisioning SSL for adelekeadebowale.com..."
certbot --nginx -d adelekeadebowale.com -d www.adelekeadebowale.com --non-interactive --agree-tos --email your-email@example.com

# Provision SSL for staging subdomain
echo "Provisioning SSL for staging.adelekeadebowale.com..."
certbot --nginx -d staging.adelekeadebowale.com --non-interactive --agree-tos --email your-email@example.com

# Provision SSL for development subdomain
echo "Provisioning SSL for dev.adelekeadebowale.com..."
certbot --nginx -d dev.adelekeadebowale.com --non-interactive --agree-tos --email your-email@example.com

# Test NGINX configuration
echo "Testing NGINX configuration..."
nginx -t

# Reload NGINX
echo "Reloading NGINX..."
systemctl reload nginx

# Set up automatic renewal
echo "Setting up automatic SSL renewal..."
if ! crontab -l | grep -q certbot; then
    (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -
fi

echo ""
echo "=========================================="
echo "SSL Setup Complete!"
echo "=========================================="
echo ""
echo "Certificates provisioned for:"
echo "  - adelekeadebowale.com"
echo "  - www.adelekeadebowale.com"
echo "  - staging.adelekeadebowale.com"
echo "  - dev.adelekeadebowale.com"
echo ""
echo "Automatic renewal is configured via cron"
echo ""
