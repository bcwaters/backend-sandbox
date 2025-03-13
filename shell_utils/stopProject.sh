#!/bin/bash

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define project root directory
PROJECT_ROOT="YOUR_PROJECT_ROOT_HERE"

echo -e "${BLUE}Stopping Grok NestJS Microservices project...${NC}"
echo "-----------------------------------------------------------"

# Stop NestJS application - more comprehensive process killing
echo -e "${YELLOW}Stopping NestJS application...${NC}"
pkill -f "node.*nest start" || true
pkill -f "node.*dist/main" || true
pkill -f "node.*--enable-source-maps" || true
echo -e "${GREEN}✓${NC} NestJS application stopped"

# Stop infrastructure services with Docker Compose
echo -e "${YELLOW}Stopping infrastructure services with Docker Compose...${NC}"
cd "$PROJECT_ROOT"

# Always use sudo for Docker commands to avoid permission issues
echo -e "${YELLOW}Stopping Docker containers with sudo...${NC}"
sudo docker-compose down || true

# Check if any project-related containers are still running
RUNNING_CONTAINERS=$(sudo docker ps --format "{{.Names}}" | grep -E 'postgres|redis|prometheus|grafana|elasticsearch|kibana' 2>/dev/null || echo "")
if [ -n "$RUNNING_CONTAINERS" ]; then
  echo -e "${YELLOW}Warning: Some containers are still running:${NC}"
  echo "$RUNNING_CONTAINERS"
  echo -e "${YELLOW}Attempting to stop containers individually...${NC}"
  
  # Try to stop individual containers with sudo
  for container in postgres redis prometheus grafana elasticsearch kibana; do
    echo -e "Stopping ${container}..."
    sudo docker stop $(sudo docker ps -q --filter "name=${container}" 2>/dev/null) 2>/dev/null || true
  done
  
  # Check again after individual stop attempts
  RUNNING_CONTAINERS=$(sudo docker ps --format "{{.Names}}" | grep -E 'postgres|redis|prometheus|grafana|elasticsearch|kibana' 2>/dev/null || echo "")
  if [ -n "$RUNNING_CONTAINERS" ]; then
    echo -e "${RED}Warning: Some containers are still running after stop attempts:${NC}"
    echo "$RUNNING_CONTAINERS"
    echo -e "${YELLOW}You may need to stop them manually with:${NC} sudo docker stop <container_name>"
  else
    echo -e "${GREEN}✓${NC} All containers have been stopped"
  fi
else
  echo -e "${GREEN}✓${NC} All containers have been stopped"
fi

# Final attempt to ensure everything is down
echo -e "${YELLOW}Final cleanup...${NC}"
cd "$PROJECT_ROOT"
sudo docker-compose down 2>/dev/null || true

# Verify NestJS processes are stopped
if pgrep -f "node.*nest\|node.*dist/main" > /dev/null; then
  echo -e "${RED}Warning: Some NestJS processes are still running. Forcing termination...${NC}"
  sudo pkill -9 -f "node.*nest" || true
  sudo pkill -9 -f "node.*dist/main" || true
  sudo pkill -9 -f "node.*--enable-source-maps" || true
  echo -e "${GREEN}✓${NC} Forced termination of NestJS processes"
else
  echo -e "${GREEN}✓${NC} No NestJS processes running"
fi

echo -e "\n${GREEN}Project stopped successfully!${NC}"
echo -e "${BLUE}To start the project again, use:${NC} ./startProject.sh"
echo -e "${BLUE}To check if all services are stopped, use:${NC} ./isRunning.sh" 