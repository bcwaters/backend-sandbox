# Migrating Infrastructure to the Proper NestJS Directory

This guide will help you migrate the infrastructure configuration from the extraneous `grok-nest-ms` directory to the proper NestJS project directory.

## Directory Structure

There are two `grok-nest-ms` directories in the project:

1. **Proper NestJS Project**: `/home/bcwaters/repo/grok_cmd/grok_cmd/grok-nest-ms`
   - This directory contains a complete NestJS project structure with all necessary configuration files
   - This is the directory you should use for development

2. **Extraneous Copy**: `/home/bcwaters/repo/grok_cmd/grok_cmd/grok_cmd/extra-nest-ms` (renamed from `grok-nest-ms`)
   - This directory contains some infrastructure configuration files that need to be migrated
   - After migration, this directory can be ignored (but not deleted to avoid breaking any existing references)

## Migration Steps

Follow these steps to migrate the infrastructure configuration to the proper NestJS project directory:

### 1. Rename the Extraneous Directory

First, rename the extraneous directory to avoid confusion:

```bash
# Navigate to the root directory
cd /home/bcwaters/repo/grok_cmd/grok_cmd

# Rename the extraneous directory
mv grok_cmd/grok-nest-ms grok_cmd/extra-nest-ms
```

### 2. Create Required Directories

Create the necessary directory structure in the proper NestJS project directory:

```bash
# Create the prometheus directory
mkdir -p grok-nest-ms/infrastructure/prometheus
```

### 3. Copy Configuration Files

Copy the necessary configuration files from the root directory to the proper NestJS project directory:

```bash
# Copy docker-compose.yml
cp docker-compose.yml grok-nest-ms/

# Copy .env file
cp .env grok-nest-ms/

# Copy prometheus.yml
cp infrastructure/prometheus/prometheus.yml grok-nest-ms/infrastructure/prometheus/
```

### 4. Copy NestJS Configuration Files

Copy the necessary NestJS configuration files from the extraneous directory to the proper NestJS project directory:

```bash
# Copy tsconfig.json (if not already present)
cp tsconfig.json grok-nest-ms/

# Copy tsconfig.build.json
cp grok_cmd/extra-nest-ms/tsconfig.build.json grok-nest-ms/

# Copy nest-cli.json
cp grok_cmd/extra-nest-ms/nest-cli.json grok-nest-ms/

# Copy .eslintrc.js
cp grok_cmd/extra-nest-ms/.eslintrc.js grok-nest-ms/

# Copy .prettierrc
cp grok_cmd/extra-nest-ms/.prettierrc grok-nest-ms/
```

### 5. Stop Existing Containers

Stop any existing Docker containers to avoid port conflicts:

```bash
# Stop containers in the root directory
sudo docker-compose down

# Stop containers in the grok-nest-ms directory (if any)
cd grok-nest-ms
sudo docker-compose down
```

### 6. Start the Infrastructure Services

Start the Docker containers in the proper NestJS project directory:

```bash
# Start the containers
sudo docker-compose up -d
```

### 7. Install Dependencies and Start the Application

Install the dependencies and start the NestJS application:

```bash
# Install dependencies
npm install

# Start the application in development mode
npm run start:dev
```

## Verification

After completing these steps, verify that everything is working correctly:

### 1. Check Docker Containers

```bash
sudo docker ps
```

You should see the following containers running:
- PostgreSQL (port 5432)
- Redis (port 6379)
- Prometheus (port 9090)
- Grafana (port 3000)
- Elasticsearch (port 9200)
- Kibana (port 5601)

### 2. Test the NestJS Application

```bash
curl http://localhost:3000
```

You should receive a response from the NestJS application.

### 3. Test the Authentication

```bash
# Register a new user
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "password123", "firstName": "Admin", "lastName": "User"}'

# Login with the registered user
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "password123"}'
```

### 4. Test the Infrastructure Services

```bash
# Test Prometheus
curl http://localhost:9090

# Test Grafana
curl http://localhost:3000

# Test Elasticsearch
curl http://localhost:9200

# Test Kibana
curl http://localhost:5601
```

## Conclusion

After completing these steps, your infrastructure configuration should be properly migrated to the correct NestJS project directory. You can now use this directory for all development work and safely ignore the extraneous copy.

Remember to update any documentation, scripts, or CI/CD pipelines that might reference the old directory structure. 