# Message Brokers Tutorial

## Why Multiple Message Brokers?

Our microservices architecture uses both RabbitMQ and Apache Kafka for different messaging scenarios:

1. **RabbitMQ**
   - Point-to-point messaging
   - Request/Reply patterns
   - Task distribution
   - Message acknowledgment
   - Used for: Service-to-service communication, task queues

2. **Apache Kafka**
   - Event streaming
   - High-throughput messaging
   - Long-term message retention
   - Event sourcing
   - Used for: Analytics, logging, event streaming

## Getting Started

### RabbitMQ Setup

1. Install dependencies:
```bash
npm install @nestjs/microservices amqplib amqp-connection-manager
```

2. Configure RabbitMQ connection:
```typescript
// src/config/rabbitmq.config.ts
import { ClientOptions, Transport } from '@nestjs/microservices';

export const rabbitmqConfig: ClientOptions = {
  transport: Transport.RMQ,
  options: {
    urls: [process.env.RABBITMQ_URL],
    queue: 'main_queue',
    queueOptions: {
      durable: true,
    },
  },
};
```

3. Implement basic messaging:
```typescript
// src/messaging/rabbitmq.service.ts
@Injectable()
export class RabbitMQService {
  constructor(
    @Inject('RABBITMQ_SERVICE')
    private client: ClientProxy,
  ) {}

  async sendMessage(pattern: string, data: any) {
    return this.client.emit(pattern, data);
  }

  async sendRequest(pattern: string, data: any) {
    return this.client.send(pattern, data);
  }
}
```

### Kafka Setup

1. Install dependencies:
```bash
npm install @nestjs/microservices kafkajs
```

2. Configure Kafka connection:
```typescript
// src/config/kafka.config.ts
import { ClientOptions, Transport } from '@nestjs/microservices';

export const kafkaConfig: ClientOptions = {
  transport: Transport.KAFKA,
  options: {
    client: {
      brokers: [process.env.KAFKA_BROKERS],
    },
    consumer: {
      groupId: 'my-service-consumer',
    },
  },
};
```

3. Implement event streaming:
```typescript
// src/messaging/kafka.service.ts
@Injectable()
export class KafkaService {
  constructor(
    @Inject('KAFKA_SERVICE')
    private client: ClientKafka,
  ) {}

  async emit(topic: string, message: any) {
    return this.client.emit(topic, message);
  }
}
```

## Implementation Patterns

### RabbitMQ Patterns

1. **Direct Exchange**:
```typescript
@Injectable()
export class OrderService {
  @MessagePattern('create_order')
  async handleOrderCreation(@Payload() data: CreateOrderDto) {
    return this.orderRepository.create(data);
  }
}
```

2. **Publish/Subscribe**:
```typescript
@Injectable()
export class NotificationService {
  @EventPattern('order_created')
  async handleOrderCreated(@Payload() data: OrderCreatedEvent) {
    await this.sendNotification(data);
  }
}
```

### Kafka Patterns

1. **Event Streaming**:
```typescript
@Injectable()
export class AnalyticsService {
  @MessagePattern('user_activity')
  async processUserActivity(@Payload() data: UserActivityEvent) {
    await this.analyticsRepository.store(data);
  }
}
```

2. **Event Sourcing**:
```typescript
@Injectable()
export class EventSourcingService {
  async replayEvents(streamId: string) {
    const events = await this.kafkaService.consume(streamId);
    return this.eventStore.replay(events);
  }
}
```

## Best Practices

1. **Message Reliability**
```typescript
@Injectable()
export class ReliableMessagingService {
  @MessagePattern('important_operation')
  async handleOperation(@Payload() data: any, @Ctx() context: RmqContext) {
    const channel = context.getChannelRef();
    const originalMsg = context.getMessage();

    try {
      await this.processOperation(data);
      channel.ack(originalMsg);
    } catch (error) {
      channel.nack(originalMsg);
    }
  }
}
```

2. **Dead Letter Exchange**:
```typescript
const queueOptions = {
  deadLetterExchange: 'dlx',
  deadLetterRoutingKey: 'dlq',
  messageTtl: 30000,
};
```

## Advanced Features

### RabbitMQ Features

1. **Priority Queues**:
```typescript
@Injectable()
export class PriorityQueueService {
  async sendWithPriority(message: any, priority: number) {
    return this.channel.sendToQueue('priority_queue', 
      Buffer.from(JSON.stringify(message)),
      { priority }
    );
  }
}
```

2. **Message TTL**:
```typescript
@Injectable()
export class ExpiringMessageService {
  async sendExpiringMessage(message: any, ttl: number) {
    return this.channel.sendToQueue('expiring_queue',
      Buffer.from(JSON.stringify(message)),
      { expiration: ttl }
    );
  }
}
```

### Kafka Features

1. **Partitioning Strategy**:
```typescript
@Injectable()
export class PartitionedProducer {
  async sendToPartition(key: string, message: any) {
    return this.kafka.send({
      topic: 'partitioned_topic',
      messages: [
        { key, value: JSON.stringify(message) },
      ],
    });
  }
}
```

2. **Batch Processing**:
```typescript
@Injectable()
export class BatchProcessor {
  @MessagePattern('batch_topic')
  async processBatch(@Payload() messages: any[]) {
    return Promise.all(
      messages.map(msg => this.processMessage(msg))
    );
  }
}
```

## Monitoring

1. **Message Tracking**:
```typescript
@Injectable()
export class MessageTracker {
  private messageCounter: Counter;

  constructor() {
    this.messageCounter = new Counter({
      name: 'messages_processed_total',
      help: 'Total number of processed messages',
      labelNames: ['status', 'type'],
    });
  }

  trackMessage(type: string, success: boolean) {
    this.messageCounter.inc({
      status: success ? 'success' : 'failure',
      type,
    });
  }
}
```

2. **Health Checks**:
```typescript
@Injectable()
export class MessagingHealthIndicator extends HealthIndicator {
  async checkHealth(): Promise<HealthIndicatorResult> {
    try {
      await this.checkConnections();
      return {
        messaging: {
          status: 'up',
        },
      };
    } catch (error) {
      return {
        messaging: {
          status: 'down',
          error: error.message,
        },
      };
    }
  }
}
```

## Troubleshooting

Common issues and solutions:

1. **Connection Issues**
   - Check broker availability
   - Verify credentials
   - Monitor connection pools

2. **Message Loss**
   - Enable message persistence
   - Implement acknowledgments
   - Use dead letter queues

3. **Performance Problems**
   - Monitor queue sizes
   - Adjust batch sizes
   - Optimize consumer count 