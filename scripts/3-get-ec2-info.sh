#!/bin/bash

# Script to get EC2 instance information for DNS configuration

set -e

REGION="us-east-1"

echo "=========================================="
echo "Getting EC2 Instance Information"
echo "=========================================="
echo ""

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ Error: AWS CLI is not configured or credentials are invalid"
    echo "Please run: aws configure"
    exit 1
fi

echo "✓ AWS CLI is configured"
echo "Region: $REGION"
echo ""

# Get all running EC2 instances
echo "Fetching running EC2 instances in $REGION..."
echo ""

aws ec2 describe-instances \
    --region "$REGION" \
    --filters "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[*].[InstanceId,PublicIpAddress,PrivateIpAddress,InstanceType,Tags[?Key=='Name'].Value|[0],State.Name]" \
    --output table

echo ""
echo "=========================================="
echo "Next Steps"
echo "=========================================="
echo "1. Identify your EC2 instance from the table above"
echo "2. Note the Public IP Address"
echo ""
echo "3. Add DNS records in Route 53:"
echo "   Go to: https://console.aws.amazon.com/route53"
echo "   Select hosted zone: adelekeadebowale.com"
echo "   Create records:"
echo ""
echo "   Record 1:"
echo "   - Name: dev.adelekeadebowale.com"
echo "   - Type: A"
echo "   - Value: <YOUR_EC2_PUBLIC_IP>"
echo ""
echo "   Record 2:"
echo "   - Name: staging.adelekeadebowale.com"
echo "   - Type: A"
echo "   - Value: <YOUR_EC2_PUBLIC_IP>"
echo ""
echo "4. Or use AWS CLI to add records:"
echo "   Run: ./scripts/4-add-dns-records.sh <YOUR_EC2_PUBLIC_IP>"
echo ""
