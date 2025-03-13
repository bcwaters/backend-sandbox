#!/bin/bash
source .env
# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Define project root directory
PROJECT_ROOT="$PROJECT_ROOT"
NEST_DIR="${PROJECT_ROOT}/grok-nest-ms"

echo -e "${BLUE}Starting Grok NestJS Microservices project...${NC}"
echo "-----------------------------------------------------------"

# Check if we're in the right directory
if [ ! -d "$NEST_DIR" ]; then
  echo -e "${RED}Error: NestJS project directory not found at $NEST_DIR${NC}"
  echo "Please update the PROJECT_ROOT variable in this script."
  exit 1
fi

# Start Docker service if not running
echo -e "${YELLOW}Checking Docker service...${NC}"
if ! systemctl is-active --quiet docker; then
  echo -e "${YELLOW}Starting Docker service...${NC}"
  sudo systemctl start docker
  if systemctl is-active --quiet docker; then
    echo -e "${GREEN}✓${NC} Docker service started successfully"
  else
    echo -e "${RED}✗${NC} Failed to start Docker service"
    exit 1
  fi
else
  echo -e "${GREEN}✓${NC} Docker service is already running"
fi

# Start infrastructure services with Docker Compose
echo -e "${YELLOW}Starting infrastructure services with Docker Compose...${NC}"
cd "$PROJECT_ROOT"

# Always use sudo for Docker commands to avoid permission issues
echo -e "${YELLOW}Starting Docker containers with sudo...${NC}"
if sudo docker-compose up -d; then
  echo -e "${GREEN}✓${NC} Infrastructure services started successfully"
else
  echo -e "${RED}✗${NC} Failed to start infrastructure services"
  echo -e "${YELLOW}Attempting to start containers individually...${NC}"
  
  # Try to start individual containers with sudo
  for service in postgres redis prometheus grafana elasticsearch kibana; do
    echo -e "Starting ${service}..."
    sudo docker-compose up -d $service
  done
  
  # Check if containers are running
  RUNNING_CONTAINERS=$(sudo docker ps --format "{{.Names}}" | grep -E 'postgres|redis|prometheus|grafana|elasticsearch|kibana' 2>/dev/null || echo "")
  if [ -z "$RUNNING_CONTAINERS" ]; then
    echo -e "${RED}✗${NC} Failed to start infrastructure services"
    exit 1
  else
    echo -e "${GREEN}✓${NC} Some infrastructure services started successfully"
  fi
fi

# Wait for services to be ready
echo -e "${YELLOW}Waiting for infrastructure services to be ready...${NC}"
echo -e "${YELLOW}This may take up to 30 seconds...${NC}"
sleep 30

# Check if PostgreSQL is ready
echo -e "${YELLOW}Checking if PostgreSQL is ready...${NC}"
pg_ready=false
for i in {1..5}; do
  if nc -z localhost 5432; then
    pg_ready=true
    echo -e "${GREEN}✓${NC} PostgreSQL is ready"
    break
  else
    echo -e "${YELLOW}Waiting for PostgreSQL to be ready (attempt $i/5)...${NC}"
    sleep 5
  fi
done

if [ "$pg_ready" = false ]; then
  echo -e "${RED}✗${NC} PostgreSQL is not ready. Starting NestJS application anyway..."
fi

# Start NestJS application
echo -e "${YELLOW}Starting NestJS application...${NC}"
cd "$NEST_DIR"
if npm run start:dev > /dev/null 2>&1 & then
  echo -e "${GREEN}✓${NC} NestJS application started successfully"
  echo -e "${GREEN}✓${NC} Application is running in development mode"
  echo -e "${BLUE}You can access the application at:${NC} http://localhost:3000"
  echo -e "${BLUE}API documentation is available at:${NC} http://localhost:3000/api"
else
  echo -e "${RED}✗${NC} Failed to start NestJS application"
  exit 1
fi

# Display running services
echo -e "\n${YELLOW}Running services:${NC}"
echo -e "${GREEN}✓${NC} NestJS application: http://localhost:3000"
echo -e "${GREEN}✓${NC} API Documentation: http://localhost:3000/api"
echo -e "${GREEN}✓${NC} PostgreSQL: localhost:5432"
echo -e "${GREEN}✓${NC} Redis: localhost:6379"
echo -e "${GREEN}✓${NC} Prometheus: http://localhost:9090"
echo -e "${GREEN}✓${NC} Grafana: http://localhost:3001"
echo -e "${GREEN}✓${NC} Elasticsearch: http://localhost:9200"
echo -e "${GREEN}✓${NC} Kibana: http://localhost:5601"

echo -e "\n${BLUE}To check if all services are running, use:${NC} ./isRunning.sh"
echo -e "${BLUE}To stop all services, use:${NC} ./stopProject.sh"
echo -e "\n${GREEN}Project started successfully!${NC}"
echo ""
echo -e "${CYAN}Access your application:${NC}"
echo -e "  - NestJS API: ${YELLOW}http://localhost:3000${NC}"
echo -e "  - Swagger API Docs: ${YELLOW}http://localhost:3000/api${NC}"
echo -e "  - Prometheus: ${YELLOW}http://localhost:9090${NC}"
echo -e "  - Grafana: ${YELLOW}http://localhost:3001${NC} (default credentials: admin/admin)"
echo -e "  - Kibana: ${YELLOW}http://localhost:5601${NC}"
echo -e "  - Elasticsearch: ${YELLOW}http://localhost:9200${NC}" 