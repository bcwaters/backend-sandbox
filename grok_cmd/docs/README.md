# Grok NestJS Microservices Architecture

## Project Overview

This project implements a modern, scalable microservices architecture using NestJS, Docker, and various cloud-native technologies. It's designed to demonstrate best practices in microservices development, monitoring, and deployment.

## Architecture Overview

### Core Components

1. **API Gateway (Port 3000)**
   - Central entry point for all client requests
   - Handles request routing
   - Implements authentication and authorization
   - Manages rate limiting and caching

2. **Microservices**
   - **Auth Service (Port 3001)**: User authentication and authorization
   - **User Service (Port 3002)**: User management and profiles
   - **Product Service (Port 3003)**: Product catalog and inventory
   - **Order Service (Port 3004)**: Order processing and management

### Infrastructure Services

1. **Databases**
   - **PostgreSQL (Port 5432)**
     - Primary relational database
     - Stores user data, orders, and authentication information
   - **Redis (Port 6379)**
     - Caching layer
     - Session management
     - Rate limiting

2. **Monitoring Stack**
   - **Prometheus (Port 9090)**
     - Metrics collection
     - Time-series data
   - **Grafana (Port 3000)**
     - Metrics visualization
     - Dashboard creation
   - **ELK Stack**
     - Elasticsearch (Port 9200): Log storage and search
     - Kibana (Port 5601): Log visualization and analysis

## Prerequisites

- Docker and Docker Compose
- Node.js (v16 or later)
- npm or yarn
- Git

## Getting Started

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd grok_cmd
   ```

2. **Environment Setup**
   ```bash
   # Copy the example environment file
   cp .env.example .env
   
   # Update the .env file with your configurations
   # The default values should work for local development
   ```

3. **Start Infrastructure Services**
   ```bash
   # Start essential services
   docker-compose up -d postgres redis prometheus grafana elasticsearch kibana
   ```

4. **Verify Services**
   - PostgreSQL: `http://localhost:5432`
   - Redis: `http://localhost:6379`
   - Prometheus: `http://localhost:9090`
   - Grafana: `http://localhost:3000`
   - Elasticsearch: `http://localhost:9200`
   - Kibana: `http://localhost:5601`

## Development Workflow

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Run in Development Mode**
   ```bash
   npm run start:dev
   ```

3. **Access Services**
   - API Documentation: `http://localhost:3000/api`
   - Swagger UI: `http://localhost:3000/api-docs`

## Service Dependencies

### Auth Service
- PostgreSQL: User credentials and sessions
- Redis: Token caching and blacklisting
- Dependencies: User Service

### User Service
- PostgreSQL: User profiles and data
- Redis: Profile caching
- Dependencies: None

### Product Service
- PostgreSQL: Product catalog
- Redis: Product caching
- Dependencies: None

### Order Service
- PostgreSQL: Order data
- Redis: Order status caching
- Dependencies: User Service, Product Service

## Monitoring and Logging

### Prometheus Metrics
- Application metrics
- Service health checks
- Performance monitoring

### Grafana Dashboards
- System metrics visualization
- Service performance graphs
- Custom dashboard creation

### ELK Stack
- Centralized logging
- Log analysis and visualization
- Error tracking and debugging

## Configuration

### Environment Variables
Key configurations in `.env`:
```env
# PostgreSQL
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin123
POSTGRES_DB=grok_nest_ms
POSTGRES_PORT=5432

# Redis
REDIS_PORT=6379

# Service Ports
PORT=3000
AUTH_SERVICE_PORT=3001
USER_SERVICE_PORT=3002
PRODUCT_SERVICE_PORT=3003
ORDER_SERVICE_PORT=3004

# Monitoring
PROMETHEUS_PORT=9090
GRAFANA_PORT=3000
KIBANA_PORT=5601
```

## Troubleshooting

1. **Service Health Checks**
   ```bash
   # Check container status
   docker-compose ps
   
   # View service logs
   docker-compose logs -f [service-name]
   ```

2. **Common Issues**
   - Database connection errors: Check PostgreSQL credentials
   - Redis connection: Verify Redis is running
   - Port conflicts: Ensure no other services use the same ports

## Best Practices

1. **Development**
   - Follow NestJS best practices
   - Use TypeScript decorators and types
   - Implement proper error handling
   - Write unit and e2e tests

2. **Deployment**
   - Use container orchestration (Docker Compose/Kubernetes)
   - Implement proper logging and monitoring
   - Follow security best practices
   - Use environment variables for configuration

3. **Maintenance**
   - Regular dependency updates
   - Security patches
   - Performance monitoring
   - Database backups

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the ISC License.