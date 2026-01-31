#!/bin/bash

# Script to provision SSL certificates for dev and staging subdomains
# Run this script ON YOUR EC2 INSTANCE

set -e

echo "=========================================="
echo "Provisioning SSL Certificates"
echo "=========================================="
echo ""

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo: sudo ./6-provision-ssl.sh"
    exit 1
fi

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    echo "Certbot not found. Installing..."
    apt-get update
    apt-get install -y certbot python3-certbot-nginx
    echo "✓ Certbot installed"
else
    echo "✓ Certbot is installed"
fi

echo ""
echo "=========================================="
echo "Provisioning Certificates"
echo "=========================================="
echo ""

# Function to provision certificate
provision_cert() {
    local domain=$1
    
    echo "Provisioning certificate for $domain..."
    certbot --nginx -d "$domain" --non-interactive --agree-tos --email debolek4dem@gmail.com
    
    if [ $? -eq 0 ]; then
        echo "✓ Certificate provisioned for $domain"
    else
        echo "❌ Failed to provision certificate for $domain"
        return 1
    fi
    
    echo ""
}

# Provision for dev
provision_cert "dev.adelekeadebowale.com"

# Provision for staging  
provision_cert "staging.adelekeadebowale.com"

echo "=========================================="
echo "SSL Certificates Provisioned!"
echo "=========================================="
echo ""
echo "Certificates created:"
echo "  ✓ dev.adelekeadebowale.com"
echo "  ✓ staging.adelekeadebowale.com"
echo ""
echo "Certificates will auto-renew via cron job."
echo "Test renewal: certbot renew --dry-run"
echo ""
echo "=========================================="
echo "Next Steps"
echo "=========================================="
echo "1. Configure GitHub Secrets (see GITHUB-SECRETS-GUIDE.md)"
echo "2. Push to develop branch to trigger deployment"
echo "3. Test: https://dev.adelekeadebowale.com"
echo "4. Push to staging branch to trigger deployment"
echo "5. Test: https://staging.adelekeadebowale.com"
echo ""
