#!/bin/bash

# Script to create AWS ECR repository for multi-environment pipeline
# Region: us-east-1

set -e

echo "=========================================="
echo "Creating ECR Repository"
echo "=========================================="
echo ""

REPOSITORY_NAME="multi-env-pipeline"
REGION="us-east-1"

echo "Repository Name: $REPOSITORY_NAME"
echo "Region: $REGION"
echo ""

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ Error: AWS CLI is not configured or credentials are invalid"
    echo "Please run: aws configure"
    exit 1
fi

echo "✓ AWS CLI is configured"
echo ""

# Check if repository already exists
if aws ecr describe-repositories --repository-names "$REPOSITORY_NAME" --region "$REGION" &> /dev/null; then
    echo "⚠️  Repository '$REPOSITORY_NAME' already exists"
    REGISTRY_URI=$(aws ecr describe-repositories --repository-names "$REPOSITORY_NAME" --region "$REGION" --query "repositories[0].repositoryUri" --output text)
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
    
    echo ""
    echo "=========================================="
    echo "Existing Repository Details"
    echo "=========================================="
    echo "Repository URI: $REGISTRY_URI"
    echo "Registry: $REGISTRY"
    echo "Repository Name: $REPOSITORY_NAME"
    echo ""
    echo "You can use these values in your GitHub Secrets:"
    echo "  ECR_REGISTRY=$REGISTRY"
    echo "  ECR_REPOSITORY=$REPOSITORY_NAME"
    echo "  AWS_REGION=$REGION"
    echo ""
    exit 0
fi

echo "Creating ECR repository..."

# Create the repository with image scanning enabled
aws ecr create-repository \
    --repository-name "$REPOSITORY_NAME" \
    --region "$REGION" \
    --image-scanning-configuration scanOnPush=true \
    --tags Key=Project,Value=multi-env-pipeline Key=Environment,Value=all

if [ $? -eq 0 ]; then
    echo "✓ Repository created successfully"
    echo ""
    
    # Get repository details
    REGISTRY_URI=$(aws ecr describe-repositories --repository-names "$REPOSITORY_NAME" --region "$REGION" --query "repositories[0].repositoryUri" --output text)
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
    
    echo "=========================================="
    echo "Repository Created Successfully!"
    echo "=========================================="
    echo "Repository URI: $REGISTRY_URI"
    echo "Registry: $REGISTRY"
    echo "Repository Name: $REPOSITORY_NAME"
    echo "Region: $REGION"
    echo ""
    echo "=========================================="
    echo "GitHub Secrets to Configure"
    echo "=========================================="
    echo "Add these to your GitHub repository settings → Secrets → Actions:"
    echo ""
    echo "ECR_REGISTRY=$REGISTRY"
    echo "ECR_REPOSITORY=$REPOSITORY_NAME"
    echo "AWS_REGION=$REGION"
    echo ""
    echo "You'll also need:"
    echo "  AWS_ACCESS_KEY_ID=<your-access-key>"
    echo "  AWS_SECRET_ACCESS_KEY=<your-secret-key>"
    echo "  EC2_PUBLIC_IP=<your-ec2-ip>"
    echo "  EC2_SSH_PRIVATE_KEY=<your-pem-file-contents>"
    echo ""
    echo "=========================================="
    echo "Next Steps"
    echo "=========================================="
    echo "1. Configure GitHub Secrets (see above)"
    echo "2. Run: ./scripts/2-create-branches.sh"
    echo "3. Get your EC2 IP: aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress,Tags[?Key==\`Name\`].Value|[0]]' --output table"
    echo ""
else
    echo "❌ Failed to create repository"
    exit 1
fi
