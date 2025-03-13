# Caching Tutorial

## Why Redis Caching?

Redis is implemented in our microservices architecture as a distributed caching layer for several critical reasons:

1. **Performance Optimization**
   - Reduce database load
   - Faster response times
   - In-memory data access

2. **Distributed State Management**
   - Session management
   - Temporary data storage
   - Shared state across services

3. **Rate Limiting**
   - API request throttling
   - DDoS protection
   - Resource usage control

4. **Real-time Features**
   - Pub/Sub messaging
   - Real-time analytics
   - Live user data

## Getting Started

### Redis Setup

1. Install Redis dependencies:
```bash
npm install @nestjs/cache-manager cache-manager cache-manager-redis-store ioredis
```

2. Configure Redis connection:
```typescript
// src/config/redis.config.ts
import { CacheModuleOptions } from '@nestjs/cache-manager';
import * as redisStore from 'cache-manager-redis-store';

export const redisConfig: CacheModuleOptions = {
  store: redisStore,
  host: process.env.REDIS_HOST,
  port: parseInt(process.env.REDIS_PORT),
  ttl: 60 * 60, // Default TTL: 1 hour
};
```

3. Import Redis module:
```typescript
// src/app.module.ts
import { CacheModule } from '@nestjs/cache-manager';
import { redisConfig } from './config/redis.config';

@Module({
  imports: [
    CacheModule.register(redisConfig),
  ],
})
export class AppModule {}
```

## Implementation Patterns

### Basic Caching

1. **Simple Key-Value Caching**:
```typescript
@Injectable()
export class ProductService {
  constructor(
    @Inject(CACHE_MANAGER)
    private cacheManager: Cache,
  ) {}

  async getProduct(id: string): Promise<Product> {
    // Try to get from cache
    const cached = await this.cacheManager.get(`product:${id}`);
    if (cached) {
      return cached;
    }

    // Get from database
    const product = await this.productRepository.findOne(id);
    
    // Store in cache
    await this.cacheManager.set(`product:${id}`, product);
    
    return product;
  }
}
```

2. **Cache Decorator**:
```typescript
@Injectable()
export class ProductService {
  @CacheKey('products')
  @CacheTTL(3600)
  @UseInterceptors(CacheInterceptor)
  async getAllProducts(): Promise<Product[]> {
    return this.productRepository.find();
  }
}
```

### Advanced Patterns

1. **Cache Aside Pattern**:
```typescript
@Injectable()
export class CacheService {
  async getOrSet<T>(
    key: string,
    callback: () => Promise<T>,
    ttl: number = 3600
  ): Promise<T> {
    const cached = await this.cacheManager.get(key);
    if (cached) {
      return cached;
    }

    const data = await callback();
    await this.cacheManager.set(key, data, ttl);
    return data;
  }
}
```

2. **Bulk Operations**:
```typescript
@Injectable()
export class BulkCacheService {
  async mget(keys: string[]): Promise<any[]> {
    const client = this.cacheManager.store.getClient();
    return client.mget(keys);
  }

  async mset(keyValues: Record<string, any>, ttl: number): Promise<void> {
    const client = this.cacheManager.store.getClient();
    const pipeline = client.pipeline();
    
    Object.entries(keyValues).forEach(([key, value]) => {
      pipeline.set(key, JSON.stringify(value), 'EX', ttl);
    });
    
    await pipeline.exec();
  }
}
```

## Best Practices

1. **Cache Invalidation Strategies**
```typescript
@Injectable()
export class CacheInvalidationService {
  // Pattern-based invalidation
  async invalidatePattern(pattern: string): Promise<void> {
    const client = this.cacheManager.store.getClient();
    const keys = await client.keys(pattern);
    if (keys.length) {
      await client.del(keys);
    }
  }

  // Versioned cache keys
  async getVersionedKey(baseKey: string): Promise<string> {
    const version = await this.cacheManager.get(`version:${baseKey}`) || 0;
    return `${baseKey}:v${version}`;
  }
}
```

2. **Error Handling**
```typescript
@Injectable()
export class ResilientCacheService {
  async safeGet(key: string): Promise<any> {
    try {
      return await this.cacheManager.get(key);
    } catch (error) {
      // Log error and fallback to null
      this.logger.error(`Cache get error: ${error.message}`);
      return null;
    }
  }
}
```

## Advanced Features

### Pub/Sub Messaging

```typescript
@Injectable()
export class RedisPubSubService {
  private publisher: Redis;
  private subscriber: Redis;

  constructor() {
    this.publisher = new Redis(redisConfig);
    this.subscriber = new Redis(redisConfig);
  }

  async publish(channel: string, message: any): Promise<void> {
    await this.publisher.publish(channel, JSON.stringify(message));
  }

  async subscribe(channel: string, callback: (message: any) => void): Promise<void> {
    await this.subscriber.subscribe(channel);
    this.subscriber.on('message', (chan, message) => {
      if (chan === channel) {
        callback(JSON.parse(message));
      }
    });
  }
}
```

### Rate Limiting

```typescript
@Injectable()
export class RedisRateLimiter {
  async isRateLimited(key: string, limit: number, window: number): Promise<boolean> {
    const client = this.cacheManager.store.getClient();
    const current = await client.incr(key);
    
    if (current === 1) {
      await client.expire(key, window);
    }
    
    return current > limit;
  }
}
```

## Monitoring

1. **Cache Metrics**:
```typescript
@Injectable()
export class CacheMetricsService {
  private hitCounter: Counter;
  private missCounter: Counter;

  constructor() {
    this.hitCounter = new Counter({
      name: 'cache_hits_total',
      help: 'Total number of cache hits',
    });
    this.missCounter = new Counter({
      name: 'cache_misses_total',
      help: 'Total number of cache misses',
    });
  }

  recordMetrics(hit: boolean): void {
    hit ? this.hitCounter.inc() : this.missCounter.inc();
  }
}
```

2. **Health Checks**:
```typescript
@Injectable()
export class RedisHealthIndicator extends HealthIndicator {
  async isHealthy(): Promise<HealthIndicatorResult> {
    try {
      const client = this.cacheManager.store.getClient();
      await client.ping();
      return {
        redis: {
          status: 'up',
        },
      };
    } catch (error) {
      return {
        redis: {
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

1. **Memory Issues**
   - Monitor memory usage
   - Implement key expiration
   - Use maxmemory policies

2. **Connection Problems**
   - Check network connectivity
   - Verify Redis configuration
   - Implement connection pooling

3. **Performance Issues**
   - Monitor cache hit rates
   - Optimize key design
   - Use appropriate data structures 