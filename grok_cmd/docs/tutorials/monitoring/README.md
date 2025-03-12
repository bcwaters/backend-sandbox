# Monitoring and Logging Tutorial

## Why Comprehensive Monitoring?

Our microservices architecture implements a robust monitoring and logging stack for several critical reasons:

1. **Prometheus & Grafana**
   - Real-time metrics collection
   - Custom dashboards
   - Alerting capabilities
   - Performance monitoring

2. **ELK Stack**
   - Centralized logging
   - Log aggregation
   - Search capabilities
   - Visual log analysis

## Getting Started

### Prometheus Setup

1. Install dependencies:
```bash
npm install @willsoto/nestjs-prometheus prom-client
```

2. Configure Prometheus module:
```typescript
// src/config/prometheus.config.ts
import { PrometheusModule } from '@willsoto/nestjs-prometheus';

@Module({
  imports: [
    PrometheusModule.register({
      defaultMetrics: {
        enabled: true,
      },
    }),
  ],
})
export class MonitoringModule {}
```

3. Create custom metrics:
```typescript
// src/monitoring/metrics.service.ts
@Injectable()
export class MetricsService {
  private readonly requestDuration: Histogram;
  private readonly activeUsers: Gauge;
  private readonly errorCounter: Counter;

  constructor() {
    this.requestDuration = new Histogram({
      name: 'http_request_duration_seconds',
      help: 'Duration of HTTP requests in seconds',
      labelNames: ['method', 'route', 'status_code'],
    });

    this.activeUsers = new Gauge({
      name: 'active_users',
      help: 'Number of active users',
    });

    this.errorCounter = new Counter({
      name: 'errors_total',
      help: 'Total number of errors',
      labelNames: ['type'],
    });
  }
}
```

### ELK Stack Setup

1. Install dependencies:
```bash
npm install winston winston-elasticsearch
```

2. Configure logging:
```typescript
// src/config/logging.config.ts
import { WinstonModule } from 'nest-winston';
import { ElasticsearchTransport } from 'winston-elasticsearch';

const esTransport = new ElasticsearchTransport({
  level: 'info',
  clientOpts: {
    node: process.env.ELASTICSEARCH_NODE,
    maxRetries: 5,
    requestTimeout: 10000,
  },
  indexPrefix: 'microservice-logs',
});

export const loggingConfig = WinstonModule.createLogger({
  transports: [esTransport],
});
```

## Implementation Patterns

### Metrics Collection

1. **Request Metrics**:
```typescript
@Injectable()
export class MetricsInterceptor implements NestInterceptor {
  constructor(private metricsService: MetricsService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const start = Date.now();
    const req = context.switchToHttp().getRequest();

    return next.handle().pipe(
      tap({
        next: () => {
          const duration = Date.now() - start;
          this.metricsService.recordRequestDuration(
            req.method,
            req.route.path,
            context.switchToHttp().getResponse().statusCode,
            duration,
          );
        },
      }),
    );
  }
}
```

2. **Business Metrics**:
```typescript
@Injectable()
export class OrderService {
  constructor(private metricsService: MetricsService) {}

  async createOrder(order: Order) {
    const timer = this.metricsService.startOrderProcessingTimer();
    try {
      const result = await this.processOrder(order);
      timer.observe({ status: 'success' });
      return result;
    } catch (error) {
      timer.observe({ status: 'failure' });
      throw error;
    }
  }
}
```

### Structured Logging

1. **Request Logging**:
```typescript
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  constructor(private logger: Logger) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const req = context.switchToHttp().getRequest();
    const requestId = uuid();

    return next.handle().pipe(
      tap({
        next: (data) => {
          this.logger.log({
            level: 'info',
            message: 'Request completed',
            requestId,
            method: req.method,
            path: req.path,
            statusCode: context.switchToHttp().getResponse().statusCode,
            responseData: data,
          });
        },
        error: (error) => {
          this.logger.error({
            message: 'Request failed',
            requestId,
            method: req.method,
            path: req.path,
            error: error.message,
            stack: error.stack,
          });
        },
      }),
    );
  }
}
```

## Best Practices

1. **Metric Naming**:
```typescript
const metricNames = {
  httpRequests: {
    name: 'http_requests_total',
    help: 'Total number of HTTP requests',
    labelNames: ['method', 'path', 'status'],
  },
  databaseQueries: {
    name: 'database_queries_total',
    help: 'Total number of database queries',
    labelNames: ['operation', 'table'],
  },
};
```

2. **Log Correlation**:
```typescript
@Injectable()
export class CorrelationService {
  private readonly asyncHooks = new AsyncHooks();

  track<T>(context: { requestId: string }, fn: () => Promise<T>): Promise<T> {
    return this.asyncHooks.run(context, fn);
  }

  getContext(): { requestId: string } {
    return this.asyncHooks.getStore();
  }
}
```

## Advanced Features

### Alerting

1. **Prometheus Alerting Rules**:
```yaml
groups:
  - name: service_alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: High error rate detected
```

2. **Custom Alert Manager**:
```typescript
@Injectable()
export class AlertManager {
  async sendAlert(alert: Alert) {
    // Send to various channels (email, Slack, etc.)
    await Promise.all([
      this.emailService.send(alert),
      this.slackService.notify(alert),
    ]);
  }
}
```

### Dashboard Creation

1. **Grafana Dashboard**:
```typescript
const dashboardConfig = {
  title: 'Service Overview',
  panels: [
    {
      title: 'Request Rate',
      type: 'graph',
      targets: [
        {
          expr: 'rate(http_requests_total[5m])',
          legendFormat: '{{method}} {{path}}',
        },
      ],
    },
    // Additional panels...
  ],
};
```

## Monitoring Infrastructure

1. **Health Checks**:
```typescript
@Injectable()
export class HealthService {
  @HealthCheck()
  check() {
    return Promise.all([
      this.databaseHealthIndicator.isHealthy(),
      this.redisHealthIndicator.isHealthy(),
      this.kafkaHealthIndicator.isHealthy(),
    ]);
  }
}
```

2. **Resource Monitoring**:
```typescript
@Injectable()
export class ResourceMonitor {
  private readonly cpuUsage: Gauge;
  private readonly memoryUsage: Gauge;

  constructor() {
    this.cpuUsage = new Gauge({
      name: 'process_cpu_usage',
      help: 'Process CPU usage percentage',
    });

    this.memoryUsage = new Gauge({
      name: 'process_memory_usage_bytes',
      help: 'Process memory usage in bytes',
    });
  }

  startMonitoring() {
    setInterval(() => {
      this.updateMetrics();
    }, 5000);
  }
}
```

## Troubleshooting

Common issues and solutions:

1. **Metric Collection Issues**
   - Check Prometheus scrape configuration
   - Verify metric endpoint accessibility
   - Monitor metric cardinality

2. **Logging Problems**
   - Verify Elasticsearch connectivity
   - Check log rotation policies
   - Monitor log volume

3. **Performance Impact**
   - Optimize metric collection frequency
   - Use appropriate log levels
   - Monitor resource usage

## Best Practices for Production

1. **Retention Policies**:
```typescript
const retentionConfig = {
  metrics: {
    retention: '15d',
    size: '50GB',
  },
  logs: {
    retention: '30d',
    size: '100GB',
  },
};
```

2. **Backup Strategies**:
```typescript
@Injectable()
export class BackupService {
  async backupMetrics() {
    // Implement metric data backup
  }

  async backupLogs() {
    // Implement log data backup
  }
}
```

3. **Scaling Considerations**:
```typescript
const monitoringScaleConfig = {
  prometheus: {
    storage: {
      retention: '15d',
      size: '50GB',
    },
    scrape: {
      interval: '15s',
      timeout: '10s',
    },
  },
  elasticsearch: {
    nodes: 3,
    shards: 5,
    replicas: 1,
  },
};
``` 