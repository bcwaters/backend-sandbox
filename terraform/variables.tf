variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# PostgreSQL variables
variable "postgres_user" {
  description = "PostgreSQL username"
  type        = string
  sensitive   = false # Username is not considered sensitive
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true # Mark as sensitive to prevent showing in logs
}

variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
}

variable "postgres_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}

# Redis variables
variable "redis_port" {
  description = "Redis port"
  type        = number
  default     = 6379
}

# Monitoring variables
variable "prometheus_port" {
  description = "Prometheus port"
  type        = number
  default     = 9090
}

variable "grafana_port" {
  description = "Grafana port"
  type        = number
  default     = 3000
}

variable "kibana_port" {
  description = "Kibana port"
  type        = number
  default     = 5601
}

# Service ports
variable "port" {
  description = "API Gateway port"
  type        = number
  default     = 3000
}

variable "auth_service_port" {
  description = "Auth Service port"
  type        = number
  default     = 3001
}

variable "user_service_port" {
  description = "User Service port"
  type        = number
  default     = 3002
}

variable "product_service_port" {
  description = "Product Service port"
  type        = number
  default     = 3003
}

variable "order_service_port" {
  description = "Order Service port"
  type        = number
  default     = 3004
}

# JWT Configuration
variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  sensitive   = true # Mark as sensitive to prevent showing in logs
}

variable "jwt_expiration" {
  description = "JWT expiration time"
  type        = string
  default     = "1h"
}

# Elasticsearch Configuration
variable "elasticsearch_node" {
  description = "Elasticsearch node URL"
  type        = string
  default     = "http://elasticsearch:9200"
}

# RabbitMQ Configuration
variable "rabbitmq_url" {
  description = "RabbitMQ URL"
  type        = string
  default     = "amqp://rabbitmq:5672"
}

# Kafka Configuration
variable "kafka_brokers" {
  description = "Kafka brokers"
  type        = string
  default     = "kafka:9092"
}

# Logging
variable "log_level" {
  description = "Logging level"
  type        = string
  default     = "info"
} 