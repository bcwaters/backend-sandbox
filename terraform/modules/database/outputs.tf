output "postgres_endpoint" {
  description = "The connection endpoint for the PostgreSQL instance"
  value       = aws_db_instance.postgres.endpoint
}

output "postgres_port" {
  description = "The port on which the PostgreSQL instance accepts connections"
  value       = aws_db_instance.postgres.port
}

output "postgres_db_name" {
  description = "The database name"
  value       = aws_db_instance.postgres.db_name
}

output "postgres_security_group_id" {
  description = "The ID of the security group for the PostgreSQL instance"
  value       = aws_security_group.postgres.id
}

# Note: We're not outputting sensitive information like username and password 