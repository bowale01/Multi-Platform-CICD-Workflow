#!/bin/bash

echo "=========================================="
echo "Installing AWS CLI and Deploying Dev"
echo "=========================================="

# Install AWS CLI
echo -e "\n[1/6] Installing AWS CLI..."
sudo apt-get update -qq
sudo apt-get install -y awscli

echo "✅ AWS CLI installed"

# Configure AWS credentials (using GitHub secrets values)
echo -e "\n[2/6] Configuring AWS credentials..."
mkdir -p ~/.aws
cat > ~/.aws/credentials << 'EOF'
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF

cat > ~/.aws/config << 'EOF'
[default]
region = us-east-1
output = json
EOF

echo "✅ AWS configured"

# Login to ECR
echo -e "\n[3/6] Logging into ECR..."
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 743508003148.dkr.ecr.us-east-1.amazonaws.com

echo "✅ ECR login successful"

# Pull the dev image
echo -e "\n[4/6] Pulling dev image..."
docker pull 743508003148.dkr.ecr.us-east-1.amazonaws.com/multi-env-pipeline:dev

echo "✅ Image pulled"

# Stop old container
echo -e "\n[5/6] Cleaning up old container..."
docker stop app-dev 2>/dev/null || true
docker rm app-dev 2>/dev/null || true

# Run new container
echo -e "\n[6/6] Starting container..."
docker run -d \
    --name app-dev \
    --restart unless-stopped \
    -p 3002:80 \
    743508003148.dkr.ecr.us-east-1.amazonaws.com/multi-env-pipeline:dev

echo "✅ Container started"

# Verify
echo -e "\n=========================================="
docker ps | grep app-dev
echo -e "\nTesting..."
curl -s http://localhost:3002 | head -5
echo -e "\n=========================================="
echo "✅ Dev environment deployed!"
echo "Visit: http://dev.adelekeadebowale.com"
echo "=========================================="
