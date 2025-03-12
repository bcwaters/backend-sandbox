# Terraform Configuration for Grok NestJS Microservices

This directory contains Terraform configurations to provision and manage the infrastructure for the Grok NestJS Microservices project.

## Directory Structure

```
terraform/
├── main.tf                # Main Terraform configuration
├── variables.tf           # Variable definitions
├── terraform.tfvars       # Non-sensitive variable values
├── .env.terraform         # Environment variables for sensitive data (not in version control)
├── .env.terraform.example # Example environment file (safe for version control)
├── modules/               # Terraform modules for different components
│   ├── networking/        # VPC, subnets, security groups
│   ├── database/          # PostgreSQL database
│   ├── cache/             # Redis cache
│   ├── monitoring/        # Prometheus, Grafana, ELK stack
│   └── services/          # Microservices infrastructure
└── .gitignore             # Git ignore file
```

## Environment Variables Management

This project follows best practices for managing environment variables and sensitive data:

1. **Non-sensitive variables**: Stored in `terraform.tfvars`
2. **Sensitive variables**: Managed through environment variables in `.env.terraform` (not committed to version control)
3. **Example file**: `.env.terraform.example` provides a template for required sensitive variables

## Getting Started

### Prerequisites

- Terraform CLI (v1.0.0 or newer)
- AWS CLI configured with appropriate permissions
- Docker and Docker Compose (for local development)

### Setup

1. **Initialize Terraform**:
   ```bash
   cd terraform
   terraform init
   ```

2. **Set up environment variables**:
   ```bash
   cp .env.terraform.example .env.terraform
   # Edit .env.terraform with your sensitive values
   source .env.terraform
   ```

3. **Plan the deployment**:
   ```bash
   terraform plan
   ```

4. **Apply the configuration**:
   ```bash
   terraform apply
   ```

## Sensitive Data Management

This project handles sensitive data according to security best practices:

1. **Environment Variables**: Sensitive values are passed to Terraform via environment variables
2. **Terraform Variables**: Marked as `sensitive = true` to prevent logging
3. **Version Control**: Sensitive files are excluded via `.gitignore`
4. **Terraform State**: State files should be stored in a secure backend (e.g., S3 with encryption)

## Terraform Cloud/Enterprise Integration

To use Terraform Cloud or Enterprise:

1. Uncomment the backend configuration in `main.tf`
2. Set the appropriate environment variables in `.env.terraform`
3. Run `terraform login` to authenticate with Terraform Cloud
4. Initialize Terraform with the remote backend: `terraform init`

## Modules

### Networking

Provisions the VPC, subnets, and security groups for the infrastructure.

### Database

Sets up the PostgreSQL database for the microservices.

### Cache

Configures Redis for caching and session management.

### Monitoring

Deploys the monitoring stack: Prometheus, Grafana, and ELK stack.

### Services

Provisions the infrastructure for the microservices components.

## Best Practices

1. **State Management**: Use remote state with locking
2. **Sensitive Data**: Never commit sensitive data to version control
3. **Modularity**: Use modules for reusable components
4. **Documentation**: Keep documentation up-to-date
5. **Versioning**: Pin provider and module versions 