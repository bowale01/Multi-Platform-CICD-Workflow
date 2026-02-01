#!/bin/bash

echo "=========================================="
echo "Manual Dev Environment Deployment"
echo "=========================================="

# 1. Login to ECR
echo -e "\n[1/5] Logging into ECR..."
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 743508003148.dkr.ecr.us-east-1.amazonaws.com

if [ $? -ne 0 ]; then
    echo "❌ ECR login failed. Check AWS credentials."
    exit 1
fi
echo "✅ ECR login successful"

# 2. Pull the dev image
echo -e "\n[2/5] Pulling dev image from ECR..."
docker pull 743508003148.dkr.ecr.us-east-1.amazonaws.com/multi-env-pipeline:dev

if [ $? -ne 0 ]; then
    echo "❌ Image pull failed. Image may not exist in ECR."
    exit 1
fi
echo "✅ Image pulled successfully"

# 3. Stop and remove old container (if exists)
echo -e "\n[3/5] Removing old container (if exists)..."
docker stop app-dev 2>/dev/null || true
docker rm app-dev 2>/dev/null || true
echo "✅ Old container cleaned up"

# 4. Run new container
echo -e "\n[4/5] Starting new container..."
docker run -d \
    --name app-dev \
    --restart unless-stopped \
    -p 3002:80 \
    743508003148.dkr.ecr.us-east-1.amazonaws.com/multi-env-pipeline:dev

if [ $? -ne 0 ]; then
    echo "❌ Container failed to start"
    exit 1
fi
echo "✅ Container started"

# 5. Verify deployment
echo -e "\n[5/5] Verifying deployment..."
sleep 2
docker ps | grep app-dev

echo -e "\nTesting local connection..."
curl -s http://localhost:3002 | head -10

echo -e "\n=========================================="
echo "✅ Deployment Complete!"
echo "=========================================="
echo "Dev site: http://dev.adelekeadebowale.com"
echo "Container: app-dev (port 3002)"
echo "=========================================="
