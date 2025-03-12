terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
  
  # Uncomment this block to use Terraform Cloud/Enterprise
  # backend "remote" {
  #   organization = "your-organization"
  #   workspaces {
  #     name = "grok-nest-ms"
  #   }
  # }
  
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.aws_region
  # Authentication will be handled through environment variables
  # AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
}

provider "docker" {
  # Docker provider configuration
}

# Include modules for different components of the infrastructure
module "networking" {
  source = "./modules/networking"
  
  vpc_cidr_block = var.vpc_cidr_block
  environment    = var.environment
}

module "database" {
  source = "./modules/database"
  
  environment      = var.environment
  vpc_id           = module.networking.vpc_id
  subnet_ids       = module.networking.private_subnet_ids
  postgres_user    = var.postgres_user
  postgres_db      = var.postgres_db
  postgres_port    = var.postgres_port
  # Sensitive data is passed via variables that are populated from environment variables
}

module "cache" {
  source = "./modules/cache"
  
  environment   = var.environment
  vpc_id        = module.networking.vpc_id
  subnet_ids    = module.networking.private_subnet_ids
  redis_port    = var.redis_port
}

module "monitoring" {
  source = "./modules/monitoring"
  
  environment     = var.environment
  vpc_id          = module.networking.vpc_id
  subnet_ids      = module.networking.private_subnet_ids
  prometheus_port = var.prometheus_port
  grafana_port    = var.grafana_port
  kibana_port     = var.kibana_port
}

module "services" {
  source = "./modules/services"
  
  environment          = var.environment
  vpc_id               = module.networking.vpc_id
  subnet_ids           = module.networking.private_subnet_ids
  api_gateway_port     = var.port
  auth_service_port    = var.auth_service_port
  user_service_port    = var.user_service_port
  product_service_port = var.product_service_port
  order_service_port   = var.order_service_port
  jwt_expiration       = var.jwt_expiration
  # Sensitive data is passed via variables that are populated from environment variables
} 