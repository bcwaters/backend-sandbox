# NestJS Microservices Architecture

A scalable microservices architecture built with NestJS, featuring high availability, fault tolerance, and modern cloud-native practices.

## Architecture Overview

This project implements a microservices-based architecture with the following components:

- **API Gateway**: Central entry point for all client requests
- **Authentication Service**: Handles user authentication and authorization
- **User Service**: Manages user-related operations
- **Product Service**: Handles product catalog and inventory
- **Order Service**: Manages order processing and fulfillment

## Technology Stack

- **Framework**: NestJS with TypeScript
- **Databases**: 
  - PostgreSQL (for relational data)
  - MongoDB (for document storage)
- **Caching**: Redis
- **Message Brokers**: 
  - RabbitMQ (for service-to-service communication)
  - Apache Kafka (for event streaming)
- **Container Orchestration**: 
  - Docker
  - Kubernetes
- **Load Balancing**: 
  - Nginx
  - AWS Elastic Load Balancer
- **Monitoring & Logging**:
  - Prometheus
  - ELK Stack (Elasticsearch, Logstash, Kibana)
- **API Management**: 
  - AWS API Gateway
  - Kong

## Prerequisites

- Node.js (v16 or later)
- Docker and Docker Compose
- Kubernetes cluster
- PostgreSQL
- MongoDB
- Redis
- RabbitMQ/Kafka

## Getting Started

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd grok_cmd
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. Start the development environment:
   ```bash
   # Start infrastructure services
   docker-compose up -d

   # Start development server
   npm run start:dev
   ```

## Project Structure

```
.
├── src/
│   ├── config/           # Configuration files
│   ├── gateway/          # API Gateway implementation
│   ├── services/         # Microservices
│   │   ├── auth-service/
│   │   ├── user-service/
│   │   ├── product-service/
│   │   └── order-service/
│   └── shared/          # Shared utilities and interfaces
├── infrastructure/      # Infrastructure configurations
│   ├── docker/         # Docker configurations
│   ├── k8s/           # Kubernetes manifests
│   └── nginx/         # Nginx configurations
└── docs/              # Project documentation
```

## Development

### Running Services Individually

Each microservice can be run independently:

```bash
# Auth Service
npm run start:dev auth-service

# User Service
npm run start:dev user-service

# Product Service
npm run start:dev product-service

# Order Service
npm run start:dev order-service
```

### Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

## Deployment

The application can be deployed using Docker and Kubernetes:

```bash
# Build Docker images
docker-compose build

# Deploy to Kubernetes
kubectl apply -f infrastructure/k8s/
```

## Monitoring and Logging

- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000`
- Kibana: `http://localhost:5601`

## API Documentation

API documentation is available at:
- Swagger UI: `http://localhost:3000/api`
- ReDoc: `http://localhost:3000/api-docs`

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the ISC License. 