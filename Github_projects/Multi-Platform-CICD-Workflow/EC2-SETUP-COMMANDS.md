# EC2 Setup Commands - Run on EC2 Instance

## Connect to EC2
```bash
ssh -i /path/to/your-key.pem ubuntu@184.72.153.228
```

## Once connected, run these commands:

### 1. Update system and install prerequisites
```bash
sudo apt-get update
sudo apt-get install -y nginx certbot python3-certbot-nginx docker.io awscli
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
```

### 2. Configure NGINX for dev subdomain
```bash
sudo tee /etc/nginx/sites-available/dev-adelekeadebowale > /dev/null << 'EOF'
server {
    listen 80;
    server_name dev.adelekeadebowale.com;
    
    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF
```

### 3. Configure NGINX for staging subdomain
```bash
sudo tee /etc/nginx/sites-available/staging-adelekeadebowale > /dev/null << 'EOF'
server {
    listen 80;
    server_name staging.adelekeadebowale.com;
    
    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF
```

### 4. Enable sites and reload NGINX
```bash
sudo ln -sf /etc/nginx/sites-available/dev-adelekeadebowale /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/staging-adelekeadebowale /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 5. Provision SSL certificates
```bash
# For dev subdomain
sudo certbot --nginx -d dev.adelekeadebowale.com --non-interactive --agree-tos --email debolek4dem@gmail.com

# For staging subdomain
sudo certbot --nginx -d staging.adelekeadebowale.com --non-interactive --agree-tos --email debolek4dem@gmail.com
```

### 6. Verify certbot auto-renewal
```bash
sudo certbot renew --dry-run
```

### 7. Check status
```bash
sudo systemctl status nginx
sudo systemctl status docker
docker ps
```

---

## After EC2 Setup Complete

### Test DNS resolution (from your local machine)
```bash
nslookup dev.adelekeadebowale.com
nslookup staging.adelekeadebowale.com
```

### Deploy to dev environment
```bash
git checkout develop
git push origin develop
```

Watch deployment: https://github.com/bowale01/Multi-Platform-CICD-Workflow/actions

### Deploy to staging environment
```bash
git checkout staging  
git push origin staging
```

---

## Verification Checklist

- [ ] GitHub Secrets configured (7 secrets)
- [ ] SSH access to EC2 working
- [ ] NGINX installed and running
- [ ] Docker installed and running
- [ ] Dev NGINX config created
- [ ] Staging NGINX config created
- [ ] Sites enabled in NGINX
- [ ] SSL certificate for dev subdomain
- [ ] SSL certificate for staging subdomain
- [ ] DNS resolving correctly
- [ ] First dev deployment successful
- [ ] First staging deployment successful

---

## Troubleshooting

### NGINX not starting
```bash
sudo nginx -t  # Check configuration
sudo systemctl status nginx  # Check status
sudo journalctl -u nginx -n 50  # Check logs
```

### SSL certificate issues
```bash
sudo certbot certificates  # List certificates
sudo certbot renew --dry-run  # Test renewal
```

### Docker container issues
```bash
docker ps -a  # List all containers
docker logs app-dev  # Check dev container logs
docker logs app-staging  # Check staging container logs
```

### GitHub Actions deployment fails
- Check secrets are configured correctly
- Verify EC2 security group allows SSH from GitHub Actions
- Check EC2 SSH key is correct in secrets
- Review workflow logs in Actions tab
