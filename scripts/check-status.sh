#!/bin/bash

# Quick Status Check Script
# Provides overview of all environments and services

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "Multi-Platform CI/CD Pipeline Status"
echo -e "==========================================${NC}"
echo ""

# Check Docker
echo -e "${YELLOW}[Docker Status]${NC}"
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker is installed"
    docker --version
else
    echo -e "${RED}✗${NC} Docker is not installed"
fi
echo ""

# Check NGINX
echo -e "${YELLOW}[NGINX Status]${NC}"
if command -v nginx &> /dev/null; then
    echo -e "${GREEN}✓${NC} NGINX is installed"
    nginx -v 2>&1
    if systemctl is-active --quiet nginx; then
        echo -e "${GREEN}✓${NC} NGINX is running"
    else
        echo -e "${RED}✗${NC} NGINX is not running"
    fi
else
    echo -e "${RED}✗${NC} NGINX is not installed"
fi
echo ""

# Check AWS CLI
echo -e "${YELLOW}[AWS CLI Status]${NC}"
if command -v aws &> /dev/null; then
    echo -e "${GREEN}✓${NC} AWS CLI is installed"
    aws --version
else
    echo -e "${RED}✗${NC} AWS CLI is not installed"
fi
echo ""

# Check Certbot
echo -e "${YELLOW}[Certbot Status]${NC}"
if command -v certbot &> /dev/null; then
    echo -e "${GREEN}✓${NC} Certbot is installed"
    certbot --version
else
    echo -e "${RED}✗${NC} Certbot is not installed"
fi
echo ""

# Check SSL Certificates
echo -e "${YELLOW}[SSL Certificates]${NC}"
if [ -d "/etc/letsencrypt/live" ]; then
    cert_count=$(sudo ls -1 /etc/letsencrypt/live 2>/dev/null | grep -v README | wc -l)
    if [ "$cert_count" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Found $cert_count SSL certificate(s)"
        sudo certbot certificates 2>/dev/null | grep "Certificate Name:" | sed 's/^/  /'
    else
        echo -e "${YELLOW}⚠${NC} No SSL certificates found"
    fi
else
    echo -e "${RED}✗${NC} Certbot directory not found"
fi
echo ""

# Check Running Containers
echo -e "${YELLOW}[Running Containers]${NC}"
if command -v docker &> /dev/null; then
    container_count=$(docker ps --filter "name=app-" --format "{{.Names}}" 2>/dev/null | wc -l)
    if [ "$container_count" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Found $container_count running container(s)"
        docker ps --filter "name=app-" --format "  {{.Names}}: {{.Status}} (Port {{.Ports}})" 2>/dev/null
    else
        echo -e "${YELLOW}⚠${NC} No application containers running"
    fi
else
    echo -e "${RED}✗${NC} Docker not available"
fi
echo ""

# Check Port Usage
echo -e "${YELLOW}[Port Status]${NC}"
for port in 3000 3001 3002; do
    if sudo netstat -tulpn 2>/dev/null | grep -q ":$port "; then
        process=$(sudo netstat -tulpn 2>/dev/null | grep ":$port " | awk '{print $7}' | cut -d'/' -f2)
        echo -e "${GREEN}✓${NC} Port $port: In use by $process"
    else
        echo -e "${YELLOW}⚠${NC} Port $port: Available (no process)"
    fi
done
echo ""

# Check NGINX Configuration
echo -e "${YELLOW}[NGINX Configuration]${NC}"
if [ -f "/etc/nginx/sites-enabled/app-prod.conf" ]; then
    echo -e "${GREEN}✓${NC} Production config enabled"
else
    echo -e "${RED}✗${NC} Production config not found"
fi

if [ -f "/etc/nginx/sites-enabled/app-staging.conf" ]; then
    echo -e "${GREEN}✓${NC} Staging config enabled"
else
    echo -e "${RED}✗${NC} Staging config not found"
fi

if [ -f "/etc/nginx/sites-enabled/app-dev.conf" ]; then
    echo -e "${GREEN}✓${NC} Development config enabled"
else
    echo -e "${RED}✗${NC} Development config not found"
fi
echo ""

# Test NGINX Configuration
echo -e "${YELLOW}[NGINX Configuration Test]${NC}"
if command -v nginx &> /dev/null; then
    if sudo nginx -t 2>&1 | grep -q "successful"; then
        echo -e "${GREEN}✓${NC} NGINX configuration is valid"
    else
        echo -e "${RED}✗${NC} NGINX configuration has errors"
        sudo nginx -t 2>&1 | sed 's/^/  /'
    fi
fi
echo ""

# Check Environment Endpoints
echo -e "${YELLOW}[Environment Health Check]${NC}"
environments=(
    "Production:http://localhost:3000"
    "Staging:http://localhost:3001"
    "Development:http://localhost:3002"
)

for env in "${environments[@]}"; do
    name="${env%%:*}"
    url="${env##*:}"
    if curl -s -f -o /dev/null "$url" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $name ($url): Responding"
    else
        echo -e "${RED}✗${NC} $name ($url): Not responding"
    fi
done
echo ""

# Disk Space
echo -e "${YELLOW}[Disk Space]${NC}"
df -h / | tail -n 1 | awk '{
    use=$5;
    gsub(/%/, "", use);
    if (use >= 80) 
        printf "\033[0;31m✗\033[0m Disk usage: %s (Warning: High usage)\n", $5;
    else if (use >= 60)
        printf "\033[1;33m⚠\033[0m Disk usage: %s (Moderate usage)\n", $5;
    else
        printf "\033[0;32m✓\033[0m Disk usage: %s\n", $5;
}'
echo ""

# Docker Images
echo -e "${YELLOW}[Docker Images]${NC}"
if command -v docker &> /dev/null; then
    image_count=$(docker images --filter "dangling=false" 2>/dev/null | grep -v REPOSITORY | wc -l)
    echo -e "  Total images: $image_count"
    docker images --format "  {{.Repository}}:{{.Tag}} ({{.Size}})" 2>/dev/null | head -n 5
    if [ "$image_count" -gt 5 ]; then
        echo "  ... and $((image_count - 5)) more"
    fi
fi
echo ""

# System Info
echo -e "${YELLOW}[System Information]${NC}"
echo "  Hostname: $(hostname)"
echo "  Uptime: $(uptime -p 2>/dev/null || uptime)"
echo "  Load Average: $(uptime | awk -F'load average:' '{print $2}')"
echo ""

echo -e "${BLUE}=========================================="
echo "Status Check Complete"
echo -e "==========================================${NC}"
echo ""
echo "For detailed logs, use:"
echo "  ./scripts/manage-containers.sh logs [prod|staging|dev]"
echo ""
