# Getting Started with Terraform

This guide will help you understand and use Terraform to manage the infrastructure for the Grok NestJS Microservices project.

## What is Terraform?

Terraform is an Infrastructure as Code (IaC) tool that allows you to define and provision infrastructure resources in a declarative configuration language. With Terraform, you can version, reuse, and share your infrastructure configurations.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (v1.0.0 or newer)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate permissions
- [Docker](https://www.docker.com/get-started) and Docker Compose (for local development)
- Git

## Project Structure

Our Terraform configuration is organized as follows:

```
terraform/
├── main.tf                # Main Terraform configuration
├── variables.tf           # Variable definitions
├── terraform.tfvars       # Non-sensitive variable values
├── .env.terraform         # Environment variables for sensitive data
├── .env.terraform.example # Example environment file
├── modules/               # Terraform modules for different components
│   ├── networking/        # VPC, subnets, security groups
│   ├── database/          # PostgreSQL database
│   ├── cache/             # Redis cache
│   ├── monitoring/        # Prometheus, Grafana, ELK stack
│   └── services/          # Microservices infrastructure
└── .gitignore             # Git ignore file
```

## Step-by-Step Guide

### 1. Clone the Repository

```bash
git clone <repository-url>
cd grok_cmd
```

### 2. Set Up Environment Variables

Terraform uses environment variables to securely manage sensitive data like passwords and API keys:

```bash
# Navigate to the terraform directory
cd terraform

# Copy the example environment file
cp .env.terraform.example .env.terraform

# Edit the file with your actual values
nano .env.terraform
```

Update the `.env.terraform` file with your actual values:

```bash
# AWS Credentials
export TF_VAR_aws_access_key="your-actual-access-key"
export TF_VAR_aws_secret_key="your-actual-secret-key"

# PostgreSQL Sensitive Data
export TF_VAR_postgres_password="your-actual-postgres-password"

# JWT Sensitive Data
export TF_VAR_jwt_secret="your-actual-jwt-secret"
```

Then, source the environment file to make the variables available to Terraform:

```bash
source .env.terraform
```

### 3. Initialize Terraform

Initialize Terraform to download providers and set up the backend:

```bash
terraform init
```

This command:
- Downloads required provider plugins
- Initializes the backend for storing state
- Prepares the working directory for use with Terraform

### 4. Review the Terraform Plan

Generate and review an execution plan to see what Terraform will do:

```bash
terraform plan
```

This command:
- Shows what resources will be created, modified, or destroyed
- Validates your configuration
- Helps you understand the changes before applying them

### 5. Apply the Configuration

Apply the Terraform configuration to create or update the infrastructure:

```bash
terraform apply
```

When prompted, type `yes` to confirm the changes.

### 6. Verify the Resources

After Terraform completes, verify that your resources were created correctly:

```bash
# For AWS resources
aws rds describe-db-instances --query "DBInstances[?DBInstanceIdentifier=='postgres-dev'].Endpoint.Address" --output text

# For local Docker resources
docker ps
```

### 7. Working with Different Environments

To manage different environments (dev, staging, prod), you can use workspace or variable files:

```bash
# Using workspaces
terraform workspace new prod
terraform apply -var-file=prod.tfvars

# Or using different variable files
terraform apply -var-file=prod.tfvars
```

## Understanding Key Components

### Variables and Sensitive Data

Our project separates variables into different categories:

1. **Non-sensitive variables** in `terraform.tfvars`:
   ```hcl
   # PostgreSQL configuration
   postgres_user = "admin"
   postgres_db   = "grok_nest_ms"
   postgres_port = 5432
   ```

2. **Sensitive variables** via environment variables:
   ```bash
   export TF_VAR_postgres_password="your-secure-password"
   ```

3. **Variable definitions** in `variables.tf`:
   ```hcl
   variable "postgres_password" {
     description = "PostgreSQL password"
     type        = string
     sensitive   = true
   }
   ```

### Modules

We use modules to organize and reuse infrastructure components:

```hcl
module "database" {
  source = "./modules/database"
  
  environment      = var.environment
  vpc_id           = module.networking.vpc_id
  subnet_ids       = module.networking.private_subnet_ids
  postgres_user    = var.postgres_user
  postgres_db      = var.postgres_db
  postgres_port    = var.postgres_port
}
```

Each module has:
- `main.tf` - Resource definitions
- `variables.tf` - Input variables
- `outputs.tf` - Output values

## Common Tasks

### Adding a New Resource

To add a new resource:

1. Identify the appropriate module
2. Add the resource definition to the module's `main.tf`
3. Update `variables.tf` if needed
4. Add outputs in `outputs.tf` if needed

Example of adding an S3 bucket to a module:

```hcl
resource "aws_s3_bucket" "logs" {
  bucket = "logs-${var.environment}"
  
  tags = {
    Name        = "logs-${var.environment}"
    Environment = var.environment
  }
}
```

### Destroying Resources

To destroy resources when they're no longer needed:

```bash
terraform destroy
```

Or to target specific resources:

```bash
terraform destroy -target=module.database
```

### Updating Resources

To update existing resources:

1. Modify the Terraform configuration
2. Run `terraform plan` to see the changes
3. Run `terraform apply` to apply the changes

## Best Practices

1. **State Management**
   - Use remote state with locking (S3 + DynamoDB)
   - Never edit state files manually

2. **Sensitive Data**
   - Never commit sensitive data to version control
   - Use environment variables or secure vaults

3. **Modularity**
   - Use modules for reusable components
   - Keep modules focused on specific concerns

4. **Documentation**
   - Document your infrastructure
   - Include comments in your Terraform code

5. **Version Control**
   - Commit Terraform configurations to version control
   - Use branches for different environments or features

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Ensure environment variables are set correctly
   - Check AWS credentials and permissions

2. **State Lock Errors**
   - If using remote state, ensure the lock can be acquired
   - Force-unlock if necessary: `terraform force-unlock LOCK_ID`

3. **Provider Errors**
   - Ensure provider versions are compatible
   - Run `terraform init -upgrade` to update providers

### Getting Help

- Run `terraform validate` to check for configuration errors
- Use `terraform fmt` to format your configuration files
- Check the [Terraform documentation](https://developer.hashicorp.com/terraform/docs)

## Advanced Topics

### Terraform Cloud/Enterprise Integration

To use Terraform Cloud or Enterprise:

1. Uncomment the backend configuration in `main.tf`:
   ```hcl
   backend "remote" {
     organization = "your-organization"
     workspaces {
       name = "grok-nest-ms"
     }
   }
   ```

2. Set up authentication:
   ```bash
   terraform login
   ```

3. Initialize with the remote backend:
   ```bash
   terraform init
   ```

### CI/CD Integration

Integrate Terraform with CI/CD pipelines:

1. Store sensitive variables in CI/CD secrets
2. Use `terraform plan` in pull requests
3. Apply changes only after approval
4. Store state in a secure, shared location

## Conclusion

This guide covered the basics of using Terraform with our Grok NestJS Microservices project. By following these practices, you can manage infrastructure efficiently and consistently across environments.

For more detailed information, refer to the [official Terraform documentation](https://developer.hashicorp.com/terraform/docs) or the README in the `terraform/` directory of this project. 