# Quick Start Guide

Get your multi-platform CI/CD pipeline running in under 30 minutes!

## Prerequisites Checklist

- [ ] AWS Account with billing enabled
- [ ] Domain name (adelekeadebowale.com)
- [ ] GitHub account
- [ ] Local machine with Git and SSH client

## Step-by-Step Setup

### 1. Fork or Clone Repository (2 minutes)

```bash
# Clone the repository
git clone https://github.com/bowale01/Multi-Platform-CICD-Workflow.git
cd Multi-Platform-CICD-Workflow

# Create branches
git checkout -b develop
git push -u origin develop

git checkout -b staging
git push -u origin staging

git checkout main
```

### 2. AWS Setup (10 minutes)

#### Create ECR Repository
```bash
aws ecr create-repository --repository-name your-app-name --region us-east-1
```
**Save the repository URI!**

#### Launch EC2 Instance
- AMI: Ubuntu 20.04 LTS
- Type: t2.small or larger
- Storage: 20GB+
- Security Group: Allow SSH (22), HTTP (80), HTTPS (443)
- **Save your .pem key file!**

#### Configure DNS
Create A records pointing to your EC2 IP:
- adelekeadebowale.com
- www.adelekeadebowale.com  
- staging.adelekeadebowale.com
- dev.adelekeadebowale.com

### 3. EC2 Configuration (10 minutes)

```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# Clone repository
git clone https://github.com/bowale01/Multi-Platform-CICD-Workflow.git
cd Multi-Platform-CICD-Workflow

# Run setup
chmod +x scripts/*.sh
./scripts/ec2-setup.sh

# Logout and login (for Docker permissions)
exit
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# Configure AWS
aws configure
# Enter: Access Key, Secret Key, Region, json

# Deploy NGINX configs
cd Multi-Platform-CICD-Workflow
sudo ./scripts/deploy-nginx.sh

# Update email in SSL script
nano scripts/provision-ssl.sh  # Change email address

# Provision SSL certificates
sudo ./scripts/provision-ssl.sh
```

### 4. GitHub Secrets (5 minutes)

Go to: **GitHub Repository → Settings → Secrets → Actions → New secret**

Add these 7 secrets:

| Secret | Value |
|--------|-------|
| AWS_ACCESS_KEY_ID | Your AWS access key |
| AWS_SECRET_ACCESS_KEY | Your AWS secret key |
| AWS_REGION | e.g., us-east-1 |
| ECR_REGISTRY | 123456789012.dkr.ecr.us-east-1.amazonaws.com |
| ECR_REPOSITORY | your-app-name |
| EC2_PUBLIC_IP | Your EC2 public IP |
| EC2_SSH_PRIVATE_KEY | Full contents of .pem file |

### 5. Deploy! (2 minutes)

```bash
# Test development
git checkout develop
echo "Test" > test.txt
git add test.txt
git commit -m "Test dev deployment"
git push origin develop

# Watch GitHub Actions tab for deployment progress
# Visit: https://dev.adelekeadebowale.com

# Deploy to staging
git checkout staging
git merge develop
git push origin staging
# Visit: https://staging.adelekeadebowale.com

# Deploy to production
git checkout main
git merge staging
git push origin main
# Visit: https://adelekeadebowale.com
```

## Verification

### Check Everything Works

```bash
# On EC2
./scripts/check-status.sh
./scripts/manage-containers.sh status

# Test endpoints
curl -I https://adelekeadebowale.com
curl -I https://staging.adelekeadebowale.com
curl -I https://dev.adelekeadebowale.com
```

## Common Issues

### "Connection refused" when accessing domain
- Wait 5-10 minutes for DNS propagation
- Check EC2 security group allows HTTP/HTTPS
- Verify container is running: `docker ps`

### GitHub Actions deployment fails
- Verify all 7 secrets are set correctly
- Check EC2 security group allows SSH
- Review Actions logs for specific error

### SSL certificate error
- Wait 2-3 minutes after provisioning
- Check certificate status: `sudo certbot certificates`
- Verify domain points to EC2 IP: `nslookup adelekeadebowale.com`

## Daily Workflow

```bash
# 1. Create feature
git checkout develop
git pull origin develop
git checkout -b feature/new-feature

# 2. Develop and test locally
# Make changes...

# 3. Deploy to development
git add .
git commit -m "Add new feature"
git push origin feature/new-feature
# Create PR to develop branch
# After merge, automatically deploys to dev.adelekeadebowale.com

# 4. Test on development
# Visit https://dev.adelekeadebowale.com

# 5. Promote to staging
git checkout staging
git pull origin staging
git merge develop
git push origin staging
# Automatically deploys to staging.adelekeadebowale.com

# 6. Test on staging
# Visit https://staging.adelekeadebowale.com

# 7. Promote to production
git checkout main
git pull origin main
git merge staging
git push origin main
# Automatically deploys to adelekeadebowale.com
```

## Useful Commands

```bash
# View logs
./scripts/manage-containers.sh logs prod
./scripts/manage-containers.sh logs staging
./scripts/manage-containers.sh logs dev

# Check status
./scripts/check-status.sh

# Restart containers
./scripts/manage-containers.sh restart all

# Health check
./scripts/manage-containers.sh health

# Cleanup
./scripts/manage-containers.sh cleanup
```

## Next Steps

- [ ] Add your actual application code
- [ ] Set up monitoring (CloudWatch)
- [ ] Configure database if needed
- [ ] Add automated tests to workflows
- [ ] Set up backup strategy
- [ ] Configure alerting (Slack, email)

## Getting Help

- **Detailed Guide:** [docs/DEPLOYMENT.md](../docs/DEPLOYMENT.md)
- **Secrets Setup:** [docs/SECRETS.md](../docs/SECRETS.md)
- **Project Structure:** [docs/STRUCTURE.md](../docs/STRUCTURE.md)
- **Main README:** [README.md](../README.md)

## Success Checklist

After following this guide, you should have:

- [ ] Three live environments with HTTPS
- [ ] Automated deployments on Git push
- [ ] Proper environment isolation
- [ ] SSL certificates with auto-renewal
- [ ] Container orchestration on EC2
- [ ] NGINX reverse proxy routing

**Congratulations!** 🎉 You now have a production-grade multi-platform CI/CD pipeline!

---

**Time to complete:** 30-45 minutes  
**Difficulty:** Intermediate  
**Cost:** ~$10-20/month (AWS EC2 + domain)
