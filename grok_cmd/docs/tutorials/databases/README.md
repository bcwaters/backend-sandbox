# Database Tutorial

## Why Multiple Databases?

Our microservices architecture employs both PostgreSQL and MongoDB for different use cases. Here's why:

1. **PostgreSQL (Relational Database)**
   - Strong ACID compliance for critical transactions
   - Complex relationships and joins
   - Structured data with strict schemas
   - Used for: User data, Authentication, Orders

2. **MongoDB (Document Database)**
   - Flexible schema for evolving data structures
   - High performance for read-heavy operations
   - Better for hierarchical data structures
   - Used for: Product catalog, User preferences, Logs

## Getting Started

### PostgreSQL Setup

1. Install TypeORM and PostgreSQL driver:
```bash
npm install @nestjs/typeorm typeorm pg
```

2. Configure PostgreSQL connection:
```typescript
// src/config/database.config.ts
import { TypeOrmModuleOptions } from '@nestjs/typeorm';

export const postgresConfig: TypeOrmModuleOptions = {
  type: 'postgres',
  host: process.env.POSTGRES_HOST,
  port: parseInt(process.env.POSTGRES_PORT),
  username: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
  entities: ['dist/**/*.entity{.ts,.js}'],
  synchronize: false,
  migrations: ['dist/migrations/*{.ts,.js}'],
  migrationsRun: true,
};
```

3. Create an entity:
```typescript
// src/users/entities/user.entity.ts
import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity()
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  password: string;

  @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;
}
```

### MongoDB Setup

1. Install MongoDB driver:
```bash
npm install @nestjs/mongoose mongoose
```

2. Configure MongoDB connection:
```typescript
// src/config/mongo.config.ts
import { MongooseModuleOptions } from '@nestjs/mongoose';

export const mongoConfig: MongooseModuleOptions = {
  uri: process.env.MONGODB_URI,
  useNewUrlParser: true,
  useUnifiedTopology: true,
};
```

3. Create a schema:
```typescript
// src/products/schemas/product.schema.ts
import { Schema, Prop, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema()
export class Product extends Document {
  @Prop({ required: true })
  name: string;

  @Prop()
  description: string;

  @Prop({ required: true })
  price: number;

  @Prop({ type: [String] })
  categories: string[];
}

export const ProductSchema = SchemaFactory.createForClass(Product);
```

## Database Migration Strategies

### PostgreSQL Migrations

1. Create a migration:
```bash
npm run typeorm migration:create -- -n CreateUserTable
```

2. Example migration:
```typescript
import { MigrationInterface, QueryRunner, Table } from 'typeorm';

export class CreateUserTable1234567890123 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: 'users',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            generationStrategy: 'uuid',
            default: 'uuid_generate_v4()',
          },
          {
            name: 'email',
            type: 'varchar',
            isUnique: true,
          },
          {
            name: 'password',
            type: 'varchar',
          },
          {
            name: 'created_at',
            type: 'timestamp',
            default: 'now()',
          },
        ],
      }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('users');
  }
}
```

### MongoDB Indexes

Create indexes for better performance:

```typescript
ProductSchema.index({ name: 'text', description: 'text' });
ProductSchema.index({ categories: 1 });
```

## Best Practices

1. **Data Consistency**
   - Use transactions for critical operations
   - Implement retry mechanisms
   - Handle partial failures

2. **Performance Optimization**
   - Create appropriate indexes
   - Use query optimization
   - Implement caching strategies

3. **Security**
   - Use connection pooling
   - Implement access controls
   - Encrypt sensitive data

## Advanced Features

### PostgreSQL Features

1. **Full-Text Search**:
```typescript
@Entity()
export class Product {
  @Column({ type: 'tsvector', nullable: true })
  searchVector: string;

  @Index({ synchronize: false })
  @Column({ type: 'jsonb', nullable: true })
  metadata: Record<string, any>;
}
```

2. **Materialized Views**:
```typescript
await queryRunner.query(`
  CREATE MATERIALIZED VIEW product_stats AS
  SELECT category, COUNT(*) as total
  FROM products
  GROUP BY category;
`);
```

### MongoDB Features

1. **Aggregation Pipeline**:
```typescript
const stats = await this.productModel.aggregate([
  {
    $group: {
      _id: '$category',
      avgPrice: { $avg: '$price' },
      count: { $sum: 1 }
    }
  }
]);
```

2. **Change Streams**:
```typescript
const changeStream = this.productModel.watch();
changeStream.on('change', (change) => {
  // Handle change
});
```

## Monitoring

1. **PostgreSQL Monitoring**:
```typescript
// Query performance monitoring
const queryRunner = connection.createQueryRunner();
const startTime = Date.now();
await queryRunner.query('SELECT * FROM users');
const duration = Date.now() - startTime;
```

2. **MongoDB Monitoring**:
```typescript
mongoose.set('debug', true);
mongoose.connection.on('error', (err) => {
  // Handle connection error
});
```

## Troubleshooting

Common issues and solutions:

1. **Connection Issues**
   - Check connection strings
   - Verify network connectivity
   - Check authentication credentials

2. **Performance Problems**
   - Analyze query plans
   - Check index usage
   - Monitor connection pools

3. **Data Consistency**
   - Verify transaction boundaries
   - Check constraint violations
   - Monitor replication lag 