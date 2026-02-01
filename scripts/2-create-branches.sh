#!/bin/bash

# Script to create Git branch structure for multi-platform pipeline

set -e

echo "=========================================="
echo "Creating Git Branch Structure"
echo "=========================================="
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not a git repository"
    exit 1
fi

echo "✓ Git repository detected"
echo ""

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"
echo ""

# Function to create and push branch
create_branch() {
    local branch_name=$1
    
    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        echo "⚠️  Branch '$branch_name' already exists locally"
    else
        echo "Creating branch: $branch_name"
        git checkout -b "$branch_name"
        echo "✓ Branch '$branch_name' created"
    fi
    
    # Check if branch exists on remote
    if git ls-remote --heads origin "$branch_name" | grep -q "$branch_name"; then
        echo "⚠️  Branch '$branch_name' already exists on remote"
    else
        echo "Pushing branch: $branch_name"
        git push -u origin "$branch_name"
        echo "✓ Branch '$branch_name' pushed to remote"
    fi
    
    echo ""
}

# Ensure we're on main branch
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "Switching to main branch..."
    git checkout main
    echo ""
fi

# Pull latest changes
echo "Pulling latest changes from main..."
git pull origin main
echo ""

# Create develop branch
echo "Creating develop branch..."
create_branch "develop"

# Switch back to main
git checkout main
echo "Switched back to main"
echo ""

# Create staging branch
echo "Creating staging branch..."
create_branch "staging"

# Switch back to main
git checkout main
echo "Switched back to main"
echo ""

echo "=========================================="
echo "Branch Structure Created Successfully!"
echo "=========================================="
echo ""
echo "Available branches:"
git branch -a | grep -E "(main|staging|develop)"
echo ""
echo "=========================================="
echo "Branch → Environment Mapping"
echo "=========================================="
echo "main     → Production   (adelekeadebowale.com)"
echo "staging  → Staging      (staging.adelekeadebowale.com)"
echo "develop  → Development  (dev.adelekeadebowale.com)"
echo ""
echo "=========================================="
echo "Next Steps"
echo "=========================================="
echo "1. Get your EC2 public IP:"
echo "   aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress,Tags[?Key==\`Name\`].Value|[0]]' --output table"
echo ""
echo "2. Add DNS records in Route 53 for:"
echo "   - dev.adelekeadebowale.com → Your EC2 IP"
echo "   - staging.adelekeadebowale.com → Your EC2 IP"
echo ""
echo "3. SSH into EC2 and run setup scripts"
echo ""
