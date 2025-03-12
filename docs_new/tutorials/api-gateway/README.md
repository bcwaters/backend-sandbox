# API Gateway Tutorial

## Why API Gateway?

The API Gateway serves as the single entry point for all client requests in our microservices architecture. This pattern is crucial for several reasons:

1. **Request Routing**: Directs requests to appropriate microservices
2. **Authentication & Authorization**: Centralizes security concerns
3. **Rate Limiting**: Protects services from overload
4. **Request/Response Transformation**: Handles data format transformations
5. **Load Balancing**: Distributes traffic across service instances

## Getting Started

### Prerequisites
- Node.js (v16 or later)
- NestJS CLI (`npm i -g @nestjs/cli`)

### Basic Setup

1. Create a new NestJS application:
```bash
nest new api-gateway
cd api-gateway
```

2. Install required dependencies:
```bash
npm install @nestjs/microservices @nestjs/swagger helmet
```

3. Configure the gateway:
```typescript
// src/main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import * as helmet from 'helmet';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Security middleware
  app.use(helmet());
  
  // CORS configuration
  app.enableCors();
  
  // Swagger documentation
  const config = new DocumentBuilder()
    .setTitle('API Gateway')
    .setDescription('Microservices API Gateway')
    .setVersion('1.0')
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document);
  
  await app.listen(3000);
}
bootstrap();
```

### Implementing Routes

Create proxy routes to your microservices:

```typescript
// src/app.controller.ts
import { Controller, All, Req } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

@Controller()
@ApiTags('Gateway')
export class AppController {
  @All('auth/*')
  async auth(@Req() req) {
    // Forward to Auth Service
  }

  @All('users/*')
  async users(@Req() req) {
    // Forward to User Service
  }

  // Additional routes...
}
```

## Best Practices

1. **Error Handling**
   - Implement global error filters
   - Standardize error responses
   - Log errors appropriately

2. **Security**
   - Use HTTPS
   - Implement rate limiting
   - Add security headers
   - Validate JWT tokens

3. **Monitoring**
   - Add health checks
   - Implement metrics collection
   - Set up logging

## Advanced Features

### Circuit Breaker

Implement circuit breaker pattern to handle service failures:

```typescript
import {
  CircuitBreaker,
  CircuitBreakerOptions,
} from '@nestjs/common';

const options: CircuitBreakerOptions = {
  failureThreshold: 5,
  successThreshold: 2,
  timeout: 10000,
};

@CircuitBreaker(options)
async makeServiceCall() {
  // Service call implementation
}
```

### Rate Limiting

Add rate limiting to protect your services:

```typescript
import { RateLimit } from '@nestjs/throttler';

@RateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
})
```

## Deployment

1. Build the Docker image:
```bash
docker build -t api-gateway .
```

2. Run with Docker:
```bash
docker run -p 3000:3000 api-gateway
```

## Monitoring

The API Gateway exposes metrics at `/metrics` endpoint for Prometheus:

```typescript
import { PrometheusController } from '@willsoto/nestjs-prometheus';

// Register metrics
const requestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
});
```

## Troubleshooting

Common issues and solutions:

1. **Service Discovery Issues**
   - Check service registry configuration
   - Verify service health checks
   - Check network connectivity

2. **Performance Problems**
   - Monitor response times
   - Check resource utilization
   - Analyze request patterns

3. **Security Issues**
   - Verify JWT configuration
   - Check CORS settings
   - Review rate limiting rules 