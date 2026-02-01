#!/bin/bash

# Container Management Script
# Useful commands for managing multi-environment containers

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function print_header() {
    echo -e "${GREEN}=========================================="
    echo -e "$1"
    echo -e "==========================================${NC}"
}

function show_status() {
    print_header "Container Status"
    docker ps -a --filter "name=app-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
}

function show_logs() {
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: $0 logs [prod|staging|dev]${NC}"
        exit 1
    fi
    
    case $1 in
        prod)
            docker logs -f app-prod
            ;;
        staging)
            docker logs -f app-staging
            ;;
        dev)
            docker logs -f app-dev
            ;;
        *)
            echo -e "${RED}Invalid environment. Use: prod, staging, or dev${NC}"
            exit 1
            ;;
    esac
}

function restart_container() {
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: $0 restart [prod|staging|dev]${NC}"
        exit 1
    fi
    
    case $1 in
        prod)
            echo "Restarting production container..."
            docker restart app-prod
            ;;
        staging)
            echo "Restarting staging container..."
            docker restart app-staging
            ;;
        dev)
            echo "Restarting development container..."
            docker restart app-dev
            ;;
        all)
            echo "Restarting all containers..."
            docker restart app-prod app-staging app-dev
            ;;
        *)
            echo -e "${RED}Invalid environment. Use: prod, staging, dev, or all${NC}"
            exit 1
            ;;
    esac
    echo -e "${GREEN}Container(s) restarted successfully${NC}"
}

function cleanup() {
    print_header "Cleaning Up Docker Resources"
    echo "Removing stopped containers..."
    docker container prune -f
    echo "Removing unused images..."
    docker image prune -af
    echo "Removing unused volumes..."
    docker volume prune -f
    echo -e "${GREEN}Cleanup complete${NC}"
}

function health_check() {
    print_header "Health Check"
    
    echo -e "${YELLOW}Production (port 3000):${NC}"
    curl -Is http://localhost:3000 | head -n 1
    
    echo -e "${YELLOW}Staging (port 3001):${NC}"
    curl -Is http://localhost:3001 | head -n 1
    
    echo -e "${YELLOW}Development (port 3002):${NC}"
    curl -Is http://localhost:3002 | head -n 1
    echo ""
}

function show_usage() {
    echo "Container Management Script"
    echo ""
    echo "Usage: $0 [command] [environment]"
    echo ""
    echo "Commands:"
    echo "  status                    Show all container statuses"
    echo "  logs [env]               Show logs for environment (prod|staging|dev)"
    echo "  restart [env]            Restart container(s) (prod|staging|dev|all)"
    echo "  health                   Check health of all environments"
    echo "  cleanup                  Clean up Docker resources"
    echo ""
    echo "Examples:"
    echo "  $0 status"
    echo "  $0 logs prod"
    echo "  $0 restart all"
    echo "  $0 health"
}

# Main script logic
case "${1:-}" in
    status)
        show_status
        ;;
    logs)
        show_logs "$2"
        ;;
    restart)
        restart_container "$2"
        ;;
    health)
        health_check
        ;;
    cleanup)
        cleanup
        ;;
    *)
        show_usage
        ;;
esac
