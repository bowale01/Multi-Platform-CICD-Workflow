# Migration Plan: From Single-Environment to Multi-Platform Pipeline

## Current State Analysis

### Existing Setup (adelekeadebowale.com)
- **Repository:** [bowale01/Adebowale-myportfoliopage-app](https://github.com/bowale01/Adebowale-myportfoliopage-app)
- **Application:** React portfolio site
- **Container Registry:** Docker Hub (`bowale01/portfolio:latest`)
- **Deployment:** Single GitHub Actions workflow → EC2
- **Current Port:** 3000 (presumably)
- **DNS:** Route 53 managed
- **SSL:** Let's Encrypt

### New Multi-Platform Setup
- **Repository:** bowale01/Multi-Platform-CICD-Workflow
- **Application:** Static NGINX site (simpler than React)
- **Container Registry:** AWS ECR (more AWS-native)
- **Deployment:** 3 separate workflows for dev/staging/prod
- **Ports:** 3000 (prod), 3001 (staging), 3002 (dev)
- **Domains:**
  - Production: `adelekeadebowale.com` → Port 3000
  - Staging: `staging.adelekeadebowale.com` → Port 3001
  - Development: `dev.adelekeadebowale.com` → Port 3002

---

## Safe Migration Strategy

### Phase 1: Parallel Setup (Dev/Staging Only)
**Goal:** Deploy dev and staging environments WITHOUT touching production

1. **Create ECR Repository**
   ```bash
   aws ecr create-repository \
       --repository-name multi-env-pipeline \
       --region us-east-1
   ```

2. **Create Git Branches**
   ```bash
   git checkout -b develop
   git push -u origin develop
   
   git checkout -b staging
   git push -u origin staging
   ```

3. **Add DNS Records in Route 53**
   - Add A record: `dev.adelekeadebowale.com` → EC2 IP
   - Add A record: `staging.adelekeadebowale.com` → EC2 IP
   - **DO NOT TOUCH** existing `adelekeadebowale.com` record

4. **Configure GitHub Secrets**
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
   - AWS_REGION
   - ECR_REGISTRY (your-account.dkr.ecr.region.amazonaws.com)
   - ECR_REPOSITORY (multi-env-pipeline)
   - EC2_PUBLIC_IP
   - EC2_SSH_PRIVATE_KEY

5. **Deploy to EC2 (Dev & Staging)**
   - SSH into your existing EC2 instance
   - Create NGINX configs for dev and staging subdomains
   - Provision SSL certificates for new subdomains
   - Deploy dev container on port 3002
   - Deploy staging container on port 3001
   - **Your current production site on port 3000 remains untouched**

### Phase 2: Production Migration (After Testing)
**Goal:** Migrate production to the new pipeline only after dev/staging are stable

1. **Update Production Workflow**
   - Keep your old React portfolio OR
   - Switch to this static NGINX site

2. **Switch Container Source**
   - Change from Docker Hub to ECR
   - Deploy to same port 3000
   - Update NGINX config to point to new container

3. **Gradual Cutover**
   - Deploy new container as `app-prod-v2` on port 3003
   - Test at EC2-IP:3003
   - Switch NGINX to port 3003
   - If successful, remove old container

---

## Pre-Migration Checklist

- [ ] EC2 instance has sufficient resources (t2.micro can handle 3 containers)
- [ ] Backup current EC2 instance (create AMI snapshot)
- [ ] Note current production container name and port
- [ ] Backup current NGINX configuration
- [ ] Have SSH access to EC2 ready
- [ ] AWS CLI configured locally
- [ ] GitHub repository secrets ready to configure

---

## Step-by-Step Execution

### Step 1: Create ECR Repository
```bash
aws ecr create-repository \
    --repository-name multi-env-pipeline \
    --region <YOUR_REGION> \
    --image-scanning-configuration scanOnPush=true \
    --tags Key=Environment,Value=multi-env
```

**Output to save:** Repository URI (e.g., `<YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/multi-env-pipeline`)

### Step 2: Create Branch Structure
```bash
# In this repository
git checkout main
git checkout -b develop
git push -u origin develop

git checkout main
git checkout -b staging
git push -u origin staging
```

### Step 3: Add DNS Records (Route 53)
```bash
# Get your EC2 public IP first
aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=<YOUR_EC2_NAME>" \
    --query "Reservations[0].Instances[0].PublicIpAddress"

# Or if you don't remember the instance name:
aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,PublicIpAddress,Tags[?Key=='Name'].Value|[0]]" --output table
```

In **Route 53 Console**:
1. Go to your hosted zone for `adelekeadebowale.com`
2. Create record: `dev.adelekeadebowale.com` → Type A → Value: `<EC2_IP>`
3. Create record: `staging.adelekeadebowale.com` → Type A → Value: `<EC2_IP>`

### Step 4: Configure GitHub Secrets
In this repository's Settings → Secrets → Actions:
```
AWS_ACCESS_KEY_ID = <your-access-key>
AWS_SECRET_ACCESS_KEY = <your-secret-key>
AWS_REGION = us-east-1  (or your region)
ECR_REGISTRY = 123456789012.dkr.ecr.us-east-1.amazonaws.com  (from Step 1)
ECR_REPOSITORY = multi-env-pipeline
EC2_PUBLIC_IP = <your-ec2-ip>
EC2_SSH_PRIVATE_KEY = <your-pem-file-contents>
```

### Step 5: SSH into EC2 and Prepare
```bash
ssh -i your-key.pem ubuntu@<EC2_IP>

# Check current running containers
docker ps

# Check what port your current site is using
docker port <current-container-name>

# Install AWS CLI if not present
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS credentials on EC2
aws configure
```

### Step 6: Create NGINX Configurations on EC2
```bash
# Create dev config
sudo nano /etc/nginx/sites-available/dev-adelekeadebowale

# Create staging config
sudo nano /etc/nginx/sites-available/staging-adelekeadebowale

# Enable the sites
sudo ln -s /etc/nginx/sites-available/dev-adelekeadebowale /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/staging-adelekeadebowale /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload NGINX
sudo systemctl reload nginx
```

### Step 7: Provision SSL Certificates
```bash
# For development subdomain
sudo certbot --nginx -d dev.adelekeadebowale.com

# For staging subdomain
sudo certbot --nginx -d staging.adelekeadebowale.com
```

### Step 8: Deploy Development Environment
```bash
# Push to develop branch
git checkout develop
git add .
git commit -m "Initial dev environment deployment"
git push origin develop

# Watch GitHub Actions workflow
# Once deployed, test: https://dev.adelekeadebowale.com
```

### Step 9: Deploy Staging Environment
```bash
# Push to staging branch
git checkout staging
git merge develop
git push origin staging

# Test: https://staging.adelekeadebowale.com
```

### Step 10: Production Migration (After Successful Testing)
**Only proceed if dev and staging are working perfectly!**

```bash
# Option A: Keep your existing React portfolio on production
# - Don't change production at all
# - Use this new pipeline only for dev/staging

# Option B: Migrate production to this new static site
git checkout main
git merge staging
git push origin main

# Monitor deployment
# Test: https://adelekeadebowale.com
```

---

## Rollback Plan

If anything goes wrong:

### Rollback Development/Staging
```bash
ssh -i your-key.pem ubuntu@<EC2_IP>

# Stop problematic containers
docker stop app-dev app-staging
docker rm app-dev app-staging

# Remove NGINX configs
sudo rm /etc/nginx/sites-enabled/dev-adelekeadebowale
sudo rm /etc/nginx/sites-enabled/staging-adelekeadebowale
sudo systemctl reload nginx
```

### Rollback Production (if migrated)
```bash
# Revert to old container
docker stop app-prod
docker rm app-prod

docker pull bowale01/portfolio:latest
docker run -d --name portfolio-container --restart unless-stopped \
    -p 3000:80 bowale01/portfolio:latest

# Update NGINX to point back to old container
```

---

## Testing Checklist

### After Dev Deployment
- [ ] Site loads at https://dev.adelekeadebowale.com
- [ ] SSL certificate is valid (green padlock)
- [ ] No 502/503 errors
- [ ] Container is running: `docker ps | grep app-dev`
- [ ] Logs are clean: `docker logs app-dev`

### After Staging Deployment
- [ ] Site loads at https://staging.adelekeadebowale.com
- [ ] SSL certificate is valid
- [ ] Environment badge shows "STAGING"
- [ ] No 502/503 errors
- [ ] Container is running: `docker ps | grep app-staging`

### After Production Migration
- [ ] Site loads at https://adelekeadebowale.com
- [ ] SSL certificate is valid
- [ ] Environment badge shows "PRODUCTION"
- [ ] All links and assets work
- [ ] Mobile responsive
- [ ] Container auto-restarts: `docker inspect app-prod | grep RestartPolicy`

---

## Resources Needed

### AWS Resources
- ECR repository (~$0.10/GB/month storage)
- EC2 instance (existing - no additional cost)
- Route 53 hosted zone (existing - $0.50/month)
- Data transfer costs (minimal for static site)

### Time Estimates
- ECR setup: 5 minutes
- Branch creation: 2 minutes
- DNS configuration: 5 minutes
- GitHub secrets: 10 minutes
- EC2 NGINX setup: 30 minutes
- SSL provisioning: 10 minutes
- Dev deployment + testing: 20 minutes
- Staging deployment + testing: 20 minutes
- **Total (Dev + Staging):** ~2 hours
- Production migration: 30 minutes (only if needed)

---

## Support Scripts

I'll create helper scripts in `scripts/` directory:
- `create-ecr-repo.sh` - Automate ECR creation
- `configure-nginx-dev.sh` - Generate dev NGINX config
- `configure-nginx-staging.sh` - Generate staging NGINX config
- `provision-ssl-dev.sh` - Automate dev SSL certificate
- `provision-ssl-staging.sh` - Automate staging SSL certificate
- `test-deployments.sh` - Verify all environments

---

## Next Steps

Let me know when you're ready to start, and I'll help you execute each phase step-by-step!

**Recommended:** Start with Phase 1 (Dev & Staging) only. This gives you a safe parallel environment to test without any risk to your production site.
