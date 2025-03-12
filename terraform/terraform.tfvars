# General configuration
environment    = "dev"
aws_region     = "us-east-1"
vpc_cidr_block = "10.0.0.0/16"

# PostgreSQL configuration
postgres_user = "admin"
postgres_db   = "grok_nest_ms"
postgres_port = 5432

# Redis configuration
redis_port = 6379

# Monitoring configuration
prometheus_port = 9090
grafana_port    = 3000
kibana_port     = 5601

# Service ports
port                 = 3000
auth_service_port    = 3001
user_service_port    = 3002
product_service_port = 3003
order_service_port   = 3004

# JWT configuration
jwt_expiration = "1h"

# Elasticsearch configuration
elasticsearch_node = "http://elasticsearch:9200"

# RabbitMQ configuration
rabbitmq_url = "amqp://rabbitmq:5672"

# Kafka configuration
kafka_brokers = "kafka:9092"

# Logging
log_level = "info" 