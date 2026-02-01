# Setup Checklist

Use this checklist to track your progress setting up the multi-environment CI/CD pipeline.

## Pre-Setup Requirements

- [ ] AWS account with billing enabled
- [ ] Domain name registered (adelekeadebowale.com)
- [ ] GitHub account with repository access
- [ ] Local machine with Git installed
- [ ] SSH client installed (for EC2 access)

## Phase 1: Repository Setup

- [ ] Fork or clone the repository
- [ ] Create `develop` branch
- [ ] Create `staging` branch
- [ ] Verify `main` branch exists
- [ ] Push all branches to GitHub

## Phase 2: AWS Infrastructure

### ECR (Elastic Container Registry)

- [ ] Login to AWS Console
- [ ] Navigate to ECR service
- [ ] Create repository (name: your-app-name)
- [ ] Note repository URI
- [ ] Enable image scanning (optional but recommended)

### EC2 Instance

- [ ] Launch Ubuntu 20.04 LTS instance
- [ ] Instance type: t2.small or larger
- [ ] Storage: 20GB or more
- [ ] Create or select key pair (.pem file)
- [ ] Download and save .pem file securely
- [ ] Configure security group:
  - [ ] SSH (port 22) from your IP
  - [ ] HTTP (port 80) from anywhere
  - [ ] HTTPS (port 443) from anywhere
- [ ] Launch instance
- [ ] Note public IP address
- [ ] (Optional) Allocate and associate Elastic IP

### IAM User for GitHub Actions

- [ ] Create IAM user: github-actions-user
- [ ] Attach policies or create custom policy with ECR permissions:
  - [ ] ecr:GetAuthorizationToken
  - [ ] ecr:BatchCheckLayerAvailability
  - [ ] ecr:GetDownloadUrlForLayer
  - [ ] ecr:PutImage
  - [ ] ecr:InitiateLayerUpload
  - [ ] ecr:UploadLayerPart
  - [ ] ecr:CompleteLayerUpload
- [ ] Create access key
- [ ] Note Access Key ID
- [ ] Note Secret Access Key
- [ ] Store credentials securely

## Phase 3: DNS Configuration

- [ ] Login to DNS provider
- [ ] Create A record: adelekeadebowale.com → EC2 IP
- [ ] Create A record: www.adelekeadebowale.com → EC2 IP
- [ ] Create A record: staging.adelekeadebowale.com → EC2 IP
- [ ] Create A record: dev.adelekeadebowale.com → EC2 IP
- [ ] Wait 5-10 minutes for DNS propagation
- [ ] Verify with: `nslookup adelekeadebowale.com`

## Phase 4: EC2 Instance Configuration

### Initial Connection

- [ ] Set key permissions: `chmod 400 your-key.pem`
- [ ] SSH into EC2: `ssh -i your-key.pem ubuntu@YOUR_EC2_IP`
- [ ] Verify connection successful

### Install Required Software

- [ ] Clone repository on EC2
- [ ] Navigate to project directory
- [ ] Make scripts executable: `chmod +x scripts/*.sh`
- [ ] Run setup script: `./scripts/ec2-setup.sh`
- [ ] Wait for setup completion (5-10 minutes)
- [ ] Logout and login again (for Docker group)

### Verify Installations

- [ ] Docker: `docker --version`
- [ ] AWS CLI: `aws --version`
- [ ] NGINX: `nginx -v`
- [ ] Certbot: `certbot --version`

### Configure AWS CLI

- [ ] Run: `aws configure`
- [ ] Enter AWS Access Key ID
- [ ] Enter AWS Secret Access Key
- [ ] Enter region (e.g., us-east-1)
- [ ] Enter output format: json
- [ ] Test: `aws ecr describe-repositories`

## Phase 5: NGINX Configuration

- [ ] Navigate to project directory
- [ ] Update NGINX configs if needed (domain names)
- [ ] Run: `sudo ./scripts/deploy-nginx.sh`
- [ ] Verify NGINX configs copied
- [ ] Test NGINX: `sudo nginx -t`
- [ ] Check NGINX status: `sudo systemctl status nginx`

## Phase 6: SSL Certificate Provisioning

- [ ] Edit provision-ssl.sh script
- [ ] Update email address in script
- [ ] Verify DNS is resolving (important!)
- [ ] Run: `sudo ./scripts/provision-ssl.sh`
- [ ] Wait for certificate provisioning (2-3 minutes)
- [ ] Verify certificates: `sudo certbot certificates`
- [ ] Check for 3 certificates:
  - [ ] adelekeadebowale.com
  - [ ] staging.adelekeadebowale.com
  - [ ] dev.adelekeadebowale.com
- [ ] Verify NGINX reloaded: `sudo systemctl status nginx`

## Phase 7: GitHub Configuration

### Configure GitHub Secrets

Go to: Repository → Settings → Secrets and variables → Actions

- [ ] Add AWS_ACCESS_KEY_ID
- [ ] Add AWS_SECRET_ACCESS_KEY
- [ ] Add AWS_REGION
- [ ] Add ECR_REGISTRY (format: 123456789012.dkr.ecr.region.amazonaws.com)
- [ ] Add ECR_REPOSITORY (your repository name)
- [ ] Add EC2_PUBLIC_IP
- [ ] Add EC2_SSH_PRIVATE_KEY (entire .pem file contents)

### Verify Secrets

- [ ] Count: 7 secrets total
- [ ] Review each secret name for typos
- [ ] Verify no trailing spaces in values

## Phase 8: Test Deployments

### Development Environment

- [ ] Checkout develop branch locally
- [ ] Make a test change
- [ ] Commit and push to develop
- [ ] Go to GitHub Actions tab
- [ ] Watch "Deploy Development" workflow
- [ ] Wait for completion (2-3 minutes)
- [ ] Visit: https://dev.adelekeadebowale.com
- [ ] Verify site loads with HTTPS
- [ ] Check certificate is valid

### Staging Environment

- [ ] Checkout staging branch locally
- [ ] Merge develop branch
- [ ] Push to staging
- [ ] Watch "Deploy Staging" workflow
- [ ] Wait for completion
- [ ] Visit: https://staging.adelekeadebowale.com
- [ ] Verify deployment successful

### Production Environment

- [ ] Checkout main branch locally
- [ ] Merge staging branch
- [ ] Push to main
- [ ] Watch "Deploy Production" workflow
- [ ] Wait for completion
- [ ] Visit: https://adelekeadebowale.com
- [ ] Verify production deployment

## Phase 9: Verification

### Container Status

On EC2, run:
- [ ] `docker ps` - All 3 containers running
- [ ] `./scripts/check-status.sh` - All services green
- [ ] `./scripts/manage-containers.sh status` - All healthy

### Test All Endpoints

- [ ] `curl -I https://adelekeadebowale.com` → 200 OK
- [ ] `curl -I https://staging.adelekeadebowale.com` → 200 OK
- [ ] `curl -I https://dev.adelekeadebowale.com` → 200 OK

### Check Logs

- [ ] `./scripts/manage-containers.sh logs prod` → No errors
- [ ] `./scripts/manage-containers.sh logs staging` → No errors
- [ ] `./scripts/manage-containers.sh logs dev` → No errors

### SSL Verification

- [ ] Visit each domain in browser
- [ ] Click padlock icon
- [ ] Verify certificate is valid
- [ ] Verify certificate issuer is Let's Encrypt
- [ ] Verify expiration date (90 days from issue)

## Phase 10: Post-Deployment

### Documentation

- [ ] Review README.md
- [ ] Read QUICKSTART.md
- [ ] Bookmark docs/DEPLOYMENT.md
- [ ] Save docs/SECRETS.md for reference

### Security

- [ ] Verify GitHub Secrets are not exposed
- [ ] Confirm .pem file is stored securely
- [ ] Review EC2 security group rules
- [ ] Verify firewall is enabled: `sudo ufw status`

### Monitoring Setup (Optional)

- [ ] Set up AWS CloudWatch alarms
- [ ] Configure log aggregation
- [ ] Set up uptime monitoring
- [ ] Configure email/Slack alerts

### Backup Strategy (Optional)

- [ ] Set up EC2 snapshot schedule
- [ ] Document backup procedures
- [ ] Test restore procedures

## Ongoing Maintenance

### Daily

- [ ] Monitor GitHub Actions for failures
- [ ] Check application availability

### Weekly

- [ ] Review container logs
- [ ] Check disk space: `df -h`
- [ ] Clean up Docker: `./scripts/manage-containers.sh cleanup`

### Monthly

- [ ] Update EC2: `sudo apt update && sudo apt upgrade`
- [ ] Review SSL certificates: `sudo certbot certificates`
- [ ] Review AWS costs
- [ ] Rotate AWS access keys

### Quarterly

- [ ] Security audit
- [ ] Dependency updates
- [ ] Review and update documentation
- [ ] Disaster recovery test

## Troubleshooting Reference

If you encounter issues, refer to:

- [ ] README.md → Troubleshooting section
- [ ] docs/DEPLOYMENT.md → Detailed deployment guide
- [ ] GitHub Actions logs → Workflow errors
- [ ] Container logs → Application errors
- [ ] NGINX logs → `/var/log/nginx/`

## Common Issues Checklist

If something isn't working:

- [ ] DNS records pointing to correct IP?
- [ ] Security group allows ports 80, 443, 22?
- [ ] All GitHub Secrets configured correctly?
- [ ] EC2 instance has enough disk space?
- [ ] NGINX configuration is valid? (`sudo nginx -t`)
- [ ] SSL certificates provisioned? (`sudo certbot certificates`)
- [ ] Containers are running? (`docker ps`)
- [ ] AWS credentials working? (`aws ecr describe-repositories`)

## Success Criteria

✅ Your setup is complete when:

- [ ] All 3 environments are accessible via HTTPS
- [ ] SSL certificates are valid on all domains
- [ ] Pushing to each branch triggers automatic deployment
- [ ] All containers are running and healthy
- [ ] GitHub Actions workflows complete successfully
- [ ] No errors in application logs
- [ ] NGINX is properly routing requests
- [ ] AWS costs are within expected range

---

**Estimated Total Time:** 30-60 minutes  
**Difficulty Level:** Intermediate  
**Support:** See documentation in docs/ folder

**Congratulations!** 🎉 When all checkboxes are complete, you have a production-grade multi-environment CI/CD pipeline!
