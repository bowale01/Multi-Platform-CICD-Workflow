# Multi-Platform CI/CD Workflow - Project Structure

```
Multi-Platform-CICD-Workflow/
│
├── .github/
│   └── workflows/
│       ├── deploy-prod.yml          # Production deployment workflow (main branch)
│       ├── deploy-staging.yml       # Staging deployment workflow (staging branch)
│       └── deploy-dev.yml           # Development deployment workflow (develop branch)
│
├── docs/
│   ├── SECRETS.md                   # GitHub Secrets configuration guide
│   └── DEPLOYMENT.md                # Step-by-step deployment guide
│
├── nginx/
│   ├── app-prod.conf                # Production NGINX configuration
│   ├── app-staging.conf             # Staging NGINX configuration
│   └── app-dev.conf                 # Development NGINX configuration
│
├── scripts/
│   ├── ec2-setup.sh                 # Initial EC2 instance setup script
│   ├── provision-ssl.sh             # SSL certificate provisioning script
│   ├── deploy-nginx.sh              # NGINX configuration deployment script
│   └── manage-containers.sh         # Container management utilities
│
├── .dockerignore                     # Docker build exclusions
├── .gitignore                        # Git exclusions
├── Dockerfile                        # Container image definition
├── LICENSE                           # MIT License
├── README.md                         # Main documentation
├── package.json                      # Node.js project metadata
└── index.html                        # Sample application page
```

## File Descriptions

### GitHub Actions Workflows (`.github/workflows/`)

#### deploy-prod.yml
- **Trigger:** Push to `main` branch
- **Actions:** Build → Push to ECR with `:latest` tag → Deploy to EC2 port 3000
- **Result:** Live at https://adelekeadebowale.com

#### deploy-staging.yml
- **Trigger:** Push to `staging` branch
- **Actions:** Build → Push to ECR with `:staging` tag → Deploy to EC2 port 3001
- **Result:** Live at https://staging.adelekeadebowale.com

#### deploy-dev.yml
- **Trigger:** Push to `develop` branch
- **Actions:** Build → Push to ECR with `:dev` tag → Deploy to EC2 port 3002
- **Result:** Live at https://dev.adelekeadebowale.com

### Documentation (`docs/`)

#### SECRETS.md
- Complete guide for configuring GitHub Secrets
- Explains each secret's purpose and how to obtain values
- Security best practices
- Troubleshooting common issues

#### DEPLOYMENT.md
- Comprehensive deployment guide
- Phase-by-phase setup instructions
- Post-deployment verification steps
- Maintenance and rollback procedures

### NGINX Configurations (`nginx/`)

Each configuration file includes:
- HTTP to HTTPS redirect
- SSL certificate configuration
- Security headers
- Reverse proxy settings to appropriate container port
- Logging configuration

#### app-prod.conf
- Routes `adelekeadebowale.com` → `localhost:3000`
- Production environment settings

#### app-staging.conf
- Routes `staging.adelekeadebowale.com` → `localhost:3001`
- Staging environment settings

#### app-dev.conf
- Routes `dev.adelekeadebowale.com` → `localhost:3002`
- Development environment settings

### Setup Scripts (`scripts/`)

#### ec2-setup.sh
Installs and configures:
- Docker and Docker Compose
- AWS CLI
- NGINX
- Certbot for SSL
- Firewall rules

#### provision-ssl.sh
- Provisions Let's Encrypt SSL certificates for all domains
- Configures automatic certificate renewal
- Sets up cron job for renewals

#### deploy-nginx.sh
- Copies NGINX configs to appropriate directories
- Creates symbolic links to enable sites
- Tests and reloads NGINX configuration

#### manage-containers.sh
Provides commands for:
- Viewing container status
- Accessing container logs
- Restarting containers
- Health checks
- Resource cleanup

### Application Files

#### Dockerfile
- Multi-stage build for optimized image size
- Based on NGINX Alpine for minimal footprint
- Includes health checks
- Configured for production deployment

#### .dockerignore
Excludes from Docker build:
- Node modules
- Development files
- Environment files
- Build artifacts

#### index.html
- Sample landing page
- Environment detection (dev/staging/prod)
- Pipeline information display
- Responsive design

#### package.json
- Project metadata
- Dependency management
- Build scripts

## Deployment Flow

```
┌─────────────────────────────────────────────────────────────┐
│  Developer commits to branch (develop/staging/main)         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  GitHub Actions workflow triggers automatically             │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Docker image built with appropriate tag                    │
│  (:dev, :staging, or :latest)                              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Image pushed to AWS ECR                                    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  SSH into EC2 instance                                      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Pull latest image from ECR                                 │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Stop and remove existing container                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Start new container on appropriate port                    │
│  Production: 3000 | Staging: 3001 | Development: 3002      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  NGINX routes subdomain to container port                   │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Application live at appropriate domain with HTTPS          │
└─────────────────────────────────────────────────────────────┘
```

## Environment Isolation

Each environment is completely isolated:

**Development (develop branch)**
- Container: `app-dev`
- Port: 3002
- Tag: `:dev`
- Domain: dev.adelekeadebowale.com
- Use: Feature development and testing

**Staging (staging branch)**
- Container: `app-staging`
- Port: 3001
- Tag: `:staging`
- Domain: staging.adelekeadebowale.com
- Use: Pre-production testing and QA

**Production (main branch)**
- Container: `app-prod`
- Port: 3000
- Tag: `:latest`
- Domain: adelekeadebowale.com
- Use: Live production environment

## Security Layers

1. **GitHub Secrets:** All credentials stored securely
2. **SSH Keys:** Encrypted private key for EC2 access
3. **AWS IAM:** Least privilege access for GitHub Actions
4. **SSL/TLS:** HTTPS enforced on all domains
5. **Docker:** Container isolation
6. **Firewall:** UFW configured on EC2
7. **Security Groups:** AWS network-level protection

## Maintenance

### Daily
- Monitor GitHub Actions for failed deployments
- Check application logs if issues reported

### Weekly
- Review container resource usage
- Clean up unused Docker images

### Monthly
- Update system packages on EC2
- Review and rotate AWS access keys
- Verify SSL certificates are renewing automatically

### Quarterly
- Review and update dependencies
- Security audit of configurations
- Backup important data

## Getting Help

1. **Check Documentation:**
   - README.md for overview and troubleshooting
   - docs/DEPLOYMENT.md for setup issues
   - docs/SECRETS.md for secret configuration

2. **Review Logs:**
   - GitHub Actions logs for CI/CD issues
   - Container logs via manage-containers.sh
   - NGINX logs in /var/log/nginx/

3. **Common Issues:**
   - DNS not resolving: Check A records and TTL
   - SSL errors: Run `sudo certbot certificates`
   - Container won't start: Check Docker logs
   - Deployment fails: Verify GitHub Secrets

## Contributing

When contributing to this project:
1. Create feature branch from `develop`
2. Test changes in development environment
3. Create pull request to `develop`
4. After approval, promote through staging to production
