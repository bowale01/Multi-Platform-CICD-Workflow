# Deployment Guide

This guide walks you through deploying your multi-platform CI/CD pipeline from scratch.

## Quick Start (TL;DR)

```bash
# 1. Set up AWS infrastructure
aws ecr create-repository --repository-name your-app

# 2. Launch EC2 and run setup
./scripts/ec2-setup.sh

# 3. Deploy NGINX configs
sudo ./scripts/deploy-nginx.sh

# 4. Provision SSL certificates
sudo ./scripts/provision-ssl.sh

# 5. Configure GitHub Secrets (see docs/SECRETS.md)

# 6. Push to branches to deploy
git push origin develop   # Deploys to dev.adelekeadebowale.com
git push origin staging   # Deploys to staging.adelekeadebowale.com
git push origin main      # Deploys to adelekeadebowale.com
```

## Detailed Deployment Steps

### Phase 1: AWS Infrastructure Setup (30 minutes)

#### 1.1 Create ECR Repository

```bash
# Login to AWS CLI
aws configure

# Create ECR repository
aws ecr create-repository \
    --repository-name your-app-name \
    --image-scanning-configuration scanOnPush=true \
    --region your-region

# Output will show repository URI - save this!
# Example: 123456789012.dkr.ecr.us-east-1.amazonaws.com/your-app-name
```

#### 1.2 Launch EC2 Instance

**Specifications:**
- **AMI:** Ubuntu Server 20.04 LTS or later
- **Instance Type:** t2.small or larger (minimum)
- **Storage:** 20 GB or more
- **Key Pair:** Create new or use existing (.pem file)

**Security Group Rules:**
```
Type            Protocol    Port    Source
SSH             TCP         22      Your IP / 0.0.0.0/0
HTTP            TCP         80      0.0.0.0/0
HTTPS           TCP         443     0.0.0.0/0
```

**Important:** Save the private key (.pem file) securely!

#### 1.3 Allocate Elastic IP (Recommended)

```bash
# Allocate Elastic IP
aws ec2 allocate-address --domain vpc

# Associate with instance
aws ec2 associate-address \
    --instance-id i-1234567890abcdef0 \
    --allocation-id eipalloc-12345678
```

This prevents your IP from changing when you stop/start the instance.

### Phase 2: DNS Configuration (15 minutes)

#### Option A: Using Route 53

```bash
# Get your hosted zone ID
aws route53 list-hosted-zones

# Create A records
aws route53 change-resource-record-sets \
    --hosted-zone-id YOUR_ZONE_ID \
    --change-batch file://dns-records.json
```

Create `dns-records.json`:
```json
{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "adelekeadebowale.com",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [{"Value": "YOUR_EC2_IP"}]
      }
    },
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "www.adelekeadebowale.com",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [{"Value": "YOUR_EC2_IP"}]
      }
    },
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "staging.adelekeadebowale.com",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [{"Value": "YOUR_EC2_IP"}]
      }
    },
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "dev.adelekeadebowale.com",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [{"Value": "YOUR_EC2_IP"}]
      }
    }
  ]
}
```

#### Option B: Using Other DNS Providers

Create these A records:
- `adelekeadebowale.com` → Your EC2 IP
- `www.adelekeadebowale.com` → Your EC2 IP
- `staging.adelekeadebowale.com` → Your EC2 IP
- `dev.adelekeadebowale.com` → Your EC2 IP

Wait 5-10 minutes for DNS propagation.

### Phase 3: EC2 Instance Setup (20 minutes)

#### 3.1 Connect to EC2

```bash
# Set permissions on your key
chmod 400 your-key.pem

# Connect via SSH
ssh -i your-key.pem ubuntu@your-ec2-ip
```

#### 3.2 Clone Repository

```bash
# Install git if not present
sudo apt update
sudo apt install -y git

# Clone your repository
git clone https://github.com/bowale01/Multi-Platform-CICD-Workflow.git
cd Multi-Platform-CICD-Workflow
```

#### 3.3 Run Setup Script

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run initial setup
./scripts/ec2-setup.sh

# This installs: Docker, AWS CLI, NGINX, Certbot
# Takes about 5-10 minutes
```

#### 3.4 Logout and Login Again

```bash
# Exit SSH session
exit

# Reconnect (needed for Docker group changes)
ssh -i your-key.pem ubuntu@your-ec2-ip
```

#### 3.5 Configure AWS CLI

```bash
# Configure AWS credentials
aws configure

# Enter when prompted:
# - AWS Access Key ID: [Your Access Key]
# - AWS Secret Access Key: [Your Secret Key]
# - Default region: [Your Region, e.g., us-east-1]
# - Default output format: json
```

### Phase 4: NGINX and SSL Configuration (15 minutes)

#### 4.1 Deploy NGINX Configurations

```bash
cd ~/Multi-Platform-CICD-Workflow

# Deploy NGINX configs
sudo ./scripts/deploy-nginx.sh
```

This will:
- Copy NGINX configs to `/etc/nginx/sites-available/`
- Enable sites in `/etc/nginx/sites-enabled/`
- Test configuration
- Reload NGINX

#### 4.2 Provision SSL Certificates

**First, update the email in the script:**

```bash
# Edit the provision script
nano scripts/provision-ssl.sh

# Change "your-email@example.com" to your actual email
# Save with Ctrl+O, Exit with Ctrl+X
```

**Then run the provisioning:**

```bash
# Run SSL provisioning
sudo ./scripts/provision-ssl.sh
```

This will:
- Provision SSL certificates for all domains
- Configure automatic renewal
- Reload NGINX with SSL configuration

**Verify SSL is working:**
```bash
# Test certificates
sudo certbot certificates

# You should see 3 certificates listed
```

### Phase 5: GitHub Configuration (10 minutes)

#### 5.1 Create Branch Structure

```bash
# On your local machine
cd Multi-Platform-CICD-Workflow

# Create and push develop branch
git checkout -b develop
git push -u origin develop

# Create and push staging branch
git checkout -b staging
git push -u origin staging

# Ensure main branch exists
git checkout main
```

#### 5.2 Configure GitHub Secrets

Go to your repository: **Settings → Secrets and variables → Actions**

Add these 7 secrets (see [docs/SECRETS.md](SECRETS.md) for details):

1. `AWS_ACCESS_KEY_ID`
2. `AWS_SECRET_ACCESS_KEY`
3. `AWS_REGION`
4. `ECR_REGISTRY`
5. `ECR_REPOSITORY`
6. `EC2_PUBLIC_IP`
7. `EC2_SSH_PRIVATE_KEY`

### Phase 6: Test Deployments (10 minutes)

#### 6.1 Test Development Deployment

```bash
# Switch to develop branch
git checkout develop

# Make a test change
echo "Test deployment" > test.txt
git add test.txt
git commit -m "Test dev deployment"
git push origin develop
```

**Monitor deployment:**
1. Go to GitHub repository
2. Click "Actions" tab
3. Watch the "Deploy Development" workflow
4. Once complete, visit https://dev.adelekeadebowale.com

#### 6.2 Test Staging Deployment

```bash
# Switch to staging
git checkout staging

# Merge from develop
git merge develop
git push origin staging
```

Watch the workflow and visit https://staging.adelekeadebowale.com

#### 6.3 Test Production Deployment

```bash
# Switch to main
git checkout main

# Merge from staging
git merge staging
git push origin main
```

Watch the workflow and visit https://adelekeadebowale.com

## Post-Deployment Verification

### Check All Services

```bash
# On EC2 instance
./scripts/manage-containers.sh status
./scripts/manage-containers.sh health
```

### Verify HTTPS

```bash
# Test SSL certificates
curl -I https://adelekeadebowale.com
curl -I https://staging.adelekeadebowale.com
curl -I https://dev.adelekeadebowale.com

# All should return HTTP/2 200 OK
```

### Check Container Logs

```bash
# View logs
./scripts/manage-containers.sh logs prod
./scripts/manage-containers.sh logs staging
./scripts/manage-containers.sh logs dev
```

## Workflow for Future Deployments

### Standard Development Flow

```bash
# 1. Create feature branch from develop
git checkout develop
git pull origin develop
git checkout -b feature/new-feature

# 2. Make changes and commit
git add .
git commit -m "Add new feature"

# 3. Push feature branch
git push origin feature/new-feature

# 4. Create PR to develop on GitHub
# 5. After review, merge PR

# 6. Deploy to development automatically
git checkout develop
git pull origin develop

# 7. Test on dev.adelekeadebowale.com

# 8. Promote to staging
git checkout staging
git pull origin staging
git merge develop
git push origin staging

# 9. Test on staging.adelekeadebowale.com

# 10. Promote to production
git checkout main
git pull origin main
git merge staging
git push origin main

# 11. Verify on adelekeadebowale.com
```

## Rollback Procedure

If you need to rollback a deployment:

### Method 1: Redeploy Previous Version

```bash
# On your local machine
git checkout main
git log  # Find the commit hash of the previous good version
git reset --hard <commit-hash>
git push origin main --force

# This triggers a new deployment with the old code
```

### Method 2: Manual Container Rollback

```bash
# On EC2 instance
# List available images
docker images

# Find previous image tag and run it
docker stop app-prod
docker rm app-prod
docker run -d \
  --name app-prod \
  --restart unless-stopped \
  -p 3000:80 \
  YOUR_ECR_REGISTRY/YOUR_REPO:previous-tag
```

## Maintenance Tasks

### Weekly

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Clean up Docker resources
./scripts/manage-containers.sh cleanup
```

### Monthly

```bash
# Check SSL certificate expiration
sudo certbot certificates

# Review CloudWatch logs (if configured)
# Rotate AWS access keys (every 90 days)
```

## Troubleshooting

See the main README.md for detailed troubleshooting steps.

## Next Steps

- Set up monitoring with CloudWatch
- Configure automated backups
- Implement database for your application
- Add automated testing to workflows
- Set up Slack notifications for deployments

## Support

For issues or questions:
- Check [README.md](../README.md) troubleshooting section
- Review GitHub Actions logs
- Check container logs with manage-containers.sh
- Open an issue on GitHub repository
