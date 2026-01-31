#!/bin/bash

# Script to add DNS records in Route 53 for dev and staging subdomains

set -e

REGION="us-east-1"
DOMAIN="adelekeadebowale.com"

if [ -z "$1" ]; then
    echo "Usage: $0 <EC2_PUBLIC_IP>"
    echo ""
    echo "Example: $0 54.123.45.67"
    echo ""
    echo "Get your EC2 IP by running: ./scripts/3-get-ec2-info.sh"
    exit 1
fi

EC2_IP=$1

echo "=========================================="
echo "Adding DNS Records to Route 53"
echo "=========================================="
echo ""
echo "Domain: $DOMAIN"
echo "EC2 IP: $EC2_IP"
echo "Region: $REGION"
echo ""

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ Error: AWS CLI is not configured"
    exit 1
fi

# Get hosted zone ID
echo "Finding hosted zone for $DOMAIN..."
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='${DOMAIN}.'].Id" --output text | cut -d'/' -f3)

if [ -z "$HOSTED_ZONE_ID" ]; then
    echo "❌ Error: Hosted zone not found for $DOMAIN"
    echo "Please ensure your domain is registered in Route 53"
    exit 1
fi

echo "✓ Hosted Zone ID: $HOSTED_ZONE_ID"
echo ""

# Function to create A record
create_a_record() {
    local subdomain=$1
    local full_domain="${subdomain}.${DOMAIN}"
    
    echo "Creating A record for $full_domain..."
    
    CHANGE_BATCH=$(cat <<EOF
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$full_domain",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "$EC2_IP"
          }
        ]
      }
    }
  ]
}
EOF
)
    
    CHANGE_ID=$(aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch "$CHANGE_BATCH" \
        --query "ChangeInfo.Id" \
        --output text)
    
    if [ $? -eq 0 ]; then
        echo "✓ A record created/updated for $full_domain"
        echo "  Change ID: $CHANGE_ID"
    else
        echo "❌ Failed to create A record for $full_domain"
    fi
    
    echo ""
}

# Create records for dev and staging
create_a_record "dev"
create_a_record "staging"

echo "=========================================="
echo "DNS Records Created Successfully!"
echo "=========================================="
echo ""
echo "Records created:"
echo "  dev.${DOMAIN} → $EC2_IP"
echo "  staging.${DOMAIN} → $EC2_IP"
echo ""
echo "⚠️  Note: DNS propagation may take 5-10 minutes"
echo ""
echo "Test DNS propagation:"
echo "  nslookup dev.${DOMAIN}"
echo "  nslookup staging.${DOMAIN}"
echo ""
echo "=========================================="
echo "Next Steps"
echo "=========================================="
echo "1. Wait 5-10 minutes for DNS propagation"
echo "2. SSH into your EC2 instance"
echo "3. Run the NGINX configuration script"
echo "4. Provision SSL certificates"
echo ""
