# Getting Started with Grok NestJS Microservices

## Important Note About Directory Structure

There are two `grok-nest-ms` directories in the project:

1. `/home/bcwaters/repo/grok_cmd/grok_cmd/grok-nest-ms` - This is the **proper NestJS project** with a complete structure including:
   - Full NestJS configuration files (tsconfig.json, nest-cli.json)
   - Standard NestJS project structure
   - Complete package.json with all dependencies
   - .gitignore and other configuration files

2. `/home/bcwaters/repo/grok_cmd/grok-nest-ms` - This appears to be an **extraneous copy** with:
   - Partial configuration
   - Docker and environment files
   - Some source code

**Use the directory inside grok_cmd/grok_cmd** for your NestJS application development. The instructions below have been updated to reflect this.

## Prerequisites

- Node.js (v16 or later)
- npm (v7 or later)
- Docker and Docker Compose
- Git

## Step 1: Clone the Repository and Navigate to the Project

```bash
git clone <repository-url>
cd grok_cmd/grok_cmd
```

## Step 2: Migrate Infrastructure Configuration

Since there are two copies of the project, you'll need to ensure your infrastructure configuration points to the correct NestJS application:

1. Copy the Docker and environment files from the extraneous directory if needed:

```bash
# If the proper directory doesn't have these files
cp ../grok-nest-ms/docker-compose.yml grok-nest-ms/
cp ../grok-nest-ms/.env grok-nest-ms/
cp ../grok-nest-ms/prometheus.yml grok-nest-ms/
```

2. Update any paths in the docker-compose.yml file to point to the correct directory:

```bash
# Edit the docker-compose.yml file if needed
# Ensure volume paths point to the correct location
```

## Step 3: Start Infrastructure Services

Navigate to the proper NestJS project directory:

```bash
cd grok-nest-ms
```

Start the infrastructure services using Docker Compose:

```bash
sudo docker-compose up -d
```

This command will start the following services:
- PostgreSQL database
- Redis cache
- Prometheus monitoring
- Grafana dashboard
- Elasticsearch
- Kibana

Verify that the containers are running:

```bash
sudo docker ps
```

## Step 4: Configure the NestJS Application

1. Create or verify the existence of a `tsconfig.json` file:
   ```bash
   # Note: The tsconfig.json file might be in the parent directory
   # If it's not in the current directory, create it:
   
   cat > tsconfig.json << 'EOF'
   {
     "compilerOptions": {
       "module": "commonjs",
       "declaration": true,
       "removeComments": true,
       "emitDecoratorMetadata": true,
       "experimentalDecorators": true,
       "allowSyntheticDefaultImports": true,
       "target": "es2017",
       "sourceMap": true,
       "outDir": "./dist",
       "baseUrl": "./",
       "incremental": true,
       "skipLibCheck": true,
       "strictNullChecks": false,
       "noImplicitAny": false,
       "strictBindCallApply": false,
       "forceConsistentCasingInFileNames": false,
       "noFallthroughCasesInSwitch": false,
       "paths": {
         "@app/*": ["src/*"],
         "@config/*": ["src/config/*"],
         "@shared/*": ["src/shared/*"],
         "@services/*": ["src/services/*"]
       }
     }
   }
   EOF
   ```

2. Install the NestJS CLI globally:
   ```bash
   npm install -g @nestjs/cli
   ```

3. Install project dependencies:
   ```bash
   npm install
   ```

## Step 5: Start the NestJS Application

1. Start the application in development mode:
   ```bash
   npm run start:dev
   ```

   This will start the NestJS application on port 3000.

2. Verify that the application is running:
   ```bash
   curl http://localhost:3000
   ```

   You should receive a response, though it might indicate that authentication is required.

## Step 6: Authentication

The API endpoints are protected by authentication. Follow these steps to register and login:

### Register a New User

1. Use the following curl command to register a new user:
   ```bash
   curl -X POST http://localhost:3000/auth/register \
     -H "Content-Type: application/json" \
     -d '{
       "email": "admin@example.com",
       "password": "password123",
       "firstName": "Admin",
       "lastName": "User"
     }'
   ```

   This should return a JSON response with the user details (excluding the password).

### Login

1. Use the following curl command to login with the registered user:
   ```bash
   curl -X POST http://localhost:3000/auth/login \
     -H "Content-Type: application/json" \
     -d '{
       "email": "admin@example.com",
       "password": "password123"
     }'
   ```

   This should return a JSON response with an access token:
   ```json
   {
     "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
   }
   ```

### Using the Access Token

1. To access protected endpoints, include the access token in the Authorization header:
   ```bash
   curl -X GET http://localhost:3000/users \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
   ```

   Replace `YOUR_ACCESS_TOKEN` with the token you received from the login response.

2. You can also access the Swagger UI documentation at http://localhost:3000/api and use the "Authorize" button to enter your token.

## Step 7: Explore the API

1. Open the Swagger UI documentation in your browser:
   ```
   http://localhost:3000/api
   ```

2. Click on the "Authorize" button and enter your access token (without the "Bearer " prefix).

3. You can now explore and test all the available endpoints.

## Step 8: Access Monitoring Tools

1. Prometheus:
   ```
   http://localhost:9090
   ```

2. Grafana:
   ```
   http://localhost:3000
   ```

   Note: There might be a port conflict with the NestJS application. If so, you can modify the port in the docker-compose.yml file.

## Troubleshooting

### Common Issues and Solutions

#### Script Failures

If the `startProject.sh` or `stopProject.sh` scripts fail, you can try the following manual commands:

```bash
# Stop all Docker containers
sudo docker-compose down

# Start all Docker containers
sudo docker-compose up -d

# Check running Docker containers
sudo docker ps

# Check logs for a specific container
sudo docker logs [container_name]

# Restart a specific container
sudo docker restart [container_name]
```

#### NestJS Application Issues

If the NestJS application fails to start:

```bash
# Kill any running NestJS processes
pkill -f "node.*nest start"
pkill -f "node.*dist/main"
pkill -f "node.*--enable-source-maps"

# Start the NestJS application manually
cd grok-nest-ms
npm run start:dev
```

#### Database Connection Issues

If the application cannot connect to the database:

```bash
# Check if PostgreSQL container is running
sudo docker ps | grep postgres

# Check PostgreSQL logs
sudo docker logs grok_cmd_postgres_1

# Connect to PostgreSQL directly
sudo docker exec -it grok_cmd_postgres_1 psql -U admin -d grok_nest_ms

# Check if the users table exists
sudo docker exec -it grok_cmd_postgres_1 psql -U admin -d grok_nest_ms -c "\dt"
```

#### Port Conflicts

If you encounter port conflicts:

```bash
# Check what process is using a specific port (e.g., 3000)
sudo lsof -i :3000

# Kill the process using a specific port
sudo kill -9 $(sudo lsof -t -i:3000)
```

#### Docker Permission Issues

If you encounter Docker permission issues:

```bash
# Add your user to the docker group
sudo usermod -aG docker $USER

# Apply the changes (requires logout/login)
newgrp docker

# Or run Docker commands with sudo
sudo docker-compose up -d
```

### Checking Service Status

To check if all services are running properly:

```bash
# Use the provided script
./docs_new/isRunning.sh

# Or check manually
curl -I http://localhost:3000/api  # NestJS API
curl -I http://localhost:9090      # Prometheus
curl -I http://localhost:5601      # Kibana
curl -I http://localhost:9200      # Elasticsearch
nc -z localhost 5432               # PostgreSQL
nc -z localhost 6379               # Redis
```

### Logs and Debugging

To view logs for debugging:

```bash
# View NestJS application logs
cd grok-nest-ms
npm run start:dev

# View Docker container logs
sudo docker logs -f grok_cmd_postgres_1
sudo docker logs -f grok_cmd_elasticsearch_1
sudo docker logs -f grok_cmd_kibana_1

# View all container logs
sudo docker-compose logs -f
```

### Resetting the Environment

If you need to completely reset the environment:

```bash
# Stop all services
./docs_new/stopProject.sh

# Remove all Docker containers, volumes, and networks
sudo docker-compose down -v

# Remove PostgreSQL data
sudo docker volume rm grok_cmd_postgres_data

# Start fresh
./docs_new/startProject.sh
```

## Next Steps

- Explore the codebase to understand the microservices architecture
- Add new features or modify existing ones
- Set up a CI/CD pipeline for automated testing and deployment
- Deploy the application to a production environment 