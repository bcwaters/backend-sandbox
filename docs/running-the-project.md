# Running the Grok NestJS Microservices Project

This tutorial provides a comprehensive guide on running the Grok NestJS Microservices project, including an overview of the infrastructure, startup procedures, project navigation, and diagnostic commands.

## Infrastructure Overview

The Grok NestJS Microservices project is built on a modern, scalable architecture that includes the following components:

### Core Infrastructure Services

1. **PostgreSQL Database** (Port 5432)
   - Primary relational database for storing structured data
   - Used by authentication, user management, and other services requiring relational data storage
   - Configuration defined in `docker-compose.yml` and `.env` files

2. **Redis Cache** (Port 6379)
   - In-memory data store used for caching and session management
   - Improves application performance by reducing database load
   - Configured in `docker-compose.yml` and `.env` files

3. **Elasticsearch** (Port 9200)
   - Distributed search and analytics engine
   - Used for logging and full-text search capabilities
   - Configured in `docker-compose.yml` and `.env` files

4. **Kibana** (Port 5601)
   - Data visualization dashboard for Elasticsearch
   - Provides UI for exploring and visualizing logs and metrics
   - Configured in `docker-compose.yml` and `.env` files

### Monitoring Infrastructure

1. **Prometheus** (Port 9090)
   - Metrics collection and monitoring system
   - Collects time-series data from services
   - Configuration in `infrastructure/prometheus/prometheus.yml`

2. **Grafana** (Port 3000)
   - Metrics visualization and dashboarding
   - Provides UI for monitoring system health and performance
   - Configured in `docker-compose.yml` and `.env` files

### Application Services

1. **NestJS API Gateway** (Port 3000)
   - Central entry point for all client requests
   - Handles routing, authentication, and request validation
   - Implemented in the `src` directory

2. **Authentication Service**
   - Manages user authentication and authorization
   - Issues and validates JWT tokens
   - Implemented in the `src/auth` directory

3. **User Service**
   - Handles user management operations
   - Stores user data in PostgreSQL
   - Implemented in the `src/users` directory

## Starting the Project

Follow these steps to start the Grok NestJS Microservices project:

### Prerequisites

Ensure you have the following installed:
- Docker and Docker Compose
- Node.js (v16 or later)
- npm (v7 or later)
- Git

### Step 1: Clone the Repository (if not already done)

```bash
git clone <repository-url>
cd grok_cmd
```

### Step 2: Navigate to the Correct Directory

```bash
cd grok_cmd/grok-nest-ms
```

### Step 3: Start Infrastructure Services

Start all the infrastructure services using Docker Compose:

```bash
sudo docker-compose up -d
```

This command starts PostgreSQL, Redis, Prometheus, Grafana, Elasticsearch, and Kibana in detached mode.

### Step 4: Verify Infrastructure Services

Check that all containers are running:

```bash
sudo docker ps
```

You should see containers for:
- postgres
- redis
- prometheus
- grafana
- elasticsearch
- kibana

### Step 5: Install Dependencies

Install the NestJS application dependencies:

```bash
npm install
```

### Step 6: Start the NestJS Application

Start the NestJS application in development mode:

```bash
npm run start:dev
```

The application will be available at http://localhost:3000.

## Navigating the Project

The project follows a standard NestJS structure with some additional directories for microservices architecture:

### Key Directories and Files

1. **src/** - Main application source code
   - **main.ts** - Application entry point
   - **app.module.ts** - Root application module
   - **auth/** - Authentication service
   - **users/** - User management service

2. **infrastructure/** - Infrastructure configuration
   - **prometheus/** - Prometheus configuration
   - **docker/** - Docker configuration files

3. **docs/** - Project documentation
   - **getting-started.md** - Initial setup guide
   - **stopping-the-project.md** - How to stop the project
   - **migrating-infrastructure.md** - Infrastructure migration guide

4. **Configuration Files**
   - **.env** - Environment variables
   - **docker-compose.yml** - Docker Compose configuration
   - **tsconfig.json** - TypeScript configuration
   - **nest-cli.json** - NestJS CLI configuration

### Making Changes

When making changes to the project, consider the following:

1. **Application Code Changes**
   - Modify files in the `src/` directory
   - The application will automatically reload in development mode

2. **Infrastructure Changes**
   - Modify the `docker-compose.yml` file for container configuration
   - Update the `.env` file for environment variables
   - Restart containers after changes: `sudo docker-compose down && sudo docker-compose up -d`

3. **Configuration Changes**
   - Update `tsconfig.json` for TypeScript configuration
   - Modify `nest-cli.json` for NestJS CLI configuration
   - Restart the application after changes

## Diagnostic Commands

Use these commands to diagnose and troubleshoot the project:

### Docker Container Status

Check the status of all Docker containers:

```bash
sudo docker ps
```

Check logs for a specific container:

```bash
sudo docker logs <container-name>
```

Example:
```bash
sudo docker logs postgres
```

### Database Connection

Test the PostgreSQL connection:

```bash
psql -h localhost -p 5432 -U admin -d grok_nest_ms
# Enter password when prompted (from .env file)
```

### API Endpoints

Test the NestJS API:

```bash
# Check if the application is running
curl http://localhost:3000

# Register a new user
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "password123", "firstName": "Admin", "lastName": "User"}'

# Login with the registered user
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "password123"}'

# Access protected endpoint (replace <token> with the JWT token from login response)
curl -X GET http://localhost:3000/users \
  -H "Authorization: Bearer <token>"
```

### Monitoring Services

Check if Prometheus is running:

```bash
curl http://localhost:9090
```

Check if Grafana is running:

```bash
curl http://localhost:3000
```

Note: There might be a port conflict between Grafana and the NestJS application since both use port 3000 by default. You may need to change one of them in the `.env` file.

### Elasticsearch and Kibana

Check if Elasticsearch is running:

```bash
curl http://localhost:9200
```

Check if Kibana is running:

```bash
curl http://localhost:5601
```

### Redis

Test Redis connection:

```bash
redis-cli -h localhost -p 6379 ping
```

Should return: `PONG`

## Troubleshooting Common Issues

### Port Conflicts

If you encounter port conflicts, check which process is using the port:

```bash
sudo lsof -i :<port-number>
```

Example:
```bash
sudo lsof -i :3000
```

### Container Startup Issues

If containers fail to start, check the logs:

```bash
sudo docker-compose logs
```

### Database Connection Issues

If the application can't connect to the database, verify the database is running and the connection details in `.env` are correct:

```bash
sudo docker ps | grep postgres
```

### Authentication Issues

If you're having trouble with authentication:

1. Ensure the JWT secret in `.env` is properly set
2. Check that the user registration endpoint is working
3. Verify the login endpoint returns a valid JWT token

## Conclusion

You now have a comprehensive understanding of how to run the Grok NestJS Microservices project, navigate its structure, and diagnose common issues. The project provides a robust foundation for building scalable microservices with NestJS, complete with monitoring, logging, and infrastructure as code.

For more detailed information, refer to the other documentation files in the `docs/` directory. 