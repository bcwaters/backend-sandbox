#!/bin/bash

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo "Checking if Grok NestJS Microservices project is running..."
echo "-----------------------------------------------------------"

# Check if NestJS application is running
if curl -s http://localhost:3000 > /dev/null; then
  echo -e "${GREEN}✓${NC} NestJS application is running on port 3000"
else
  echo -e "${RED}✗${NC} NestJS application is NOT running on port 3000"
fi

# Check if PostgreSQL is running
if nc -z localhost 5432 2>/dev/null; then
  echo -e "${GREEN}✓${NC} PostgreSQL is running on port 5432"
else
  echo -e "${RED}✗${NC} PostgreSQL is NOT running on port 5432"
fi

# Check if Redis is running
if nc -z localhost 6379 2>/dev/null; then
  echo -e "${GREEN}✓${NC} Redis is running on port 6379"
else
  echo -e "${RED}✗${NC} Redis is NOT running on port 6379"
fi

# Check if Prometheus is running
if curl -s http://localhost:9090 > /dev/null; then
  echo -e "${GREEN}✓${NC} Prometheus is running on port 9090"
else
  echo -e "${RED}✗${NC} Prometheus is NOT running on port 9090"
fi

# Check if Elasticsearch is running
if curl -s http://localhost:9200 > /dev/null; then
  echo -e "${GREEN}✓${NC} Elasticsearch is running on port 9200"
else
  echo -e "${RED}✗${NC} Elasticsearch is NOT running on port 9200"
fi

# Check if Kibana is running
if curl -s http://localhost:5601 > /dev/null; then
  echo -e "${GREEN}✓${NC} Kibana is running on port 5601"
else
  echo -e "${RED}✗${NC} Kibana is NOT running on port 5601"
fi

# Check Grafana
echo -e "${YELLOW}Checking Grafana...${NC}"
if nc -z localhost 3001 &>/dev/null; then
    echo -e "${GREEN}✓ Grafana is running on port 3001${NC}"
    grafana_status="running"
else
    echo -e "${RED}✗ Grafana is not running on port 3001${NC}"
    grafana_status="not running"
fi

# Check Docker service
echo -e "\n${YELLOW}Checking Docker service...${NC}"
if systemctl is-active --quiet docker || service docker status >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Docker service is running${NC}"
    docker_service="running"
else
    echo -e "${RED}✗ Docker service is not running${NC}"
    docker_service="not running"
fi

# Check Docker containers
echo -e "\n${YELLOW}Docker Containers Status:${NC}"
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo -e "${RED}Failed to get Docker container status. Docker may not be running or you may need sudo permissions.${NC}"

echo -e "\n${YELLOW}Summary:${NC}"
if curl -s http://localhost:3000 > /dev/null && \
   nc -z localhost 5432 2>/dev/null && \
   nc -z localhost 6379 2>/dev/null && \
   curl -s http://localhost:9090 > /dev/null && \
   curl -s http://localhost:9200 > /dev/null && \
   curl -s http://localhost:5601 > /dev/null; then
  echo -e "${GREEN}All services are running!${NC}"
else
  echo -e "${RED}Some services are not running.${NC}"
fi 