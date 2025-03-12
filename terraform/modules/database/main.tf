resource "aws_db_subnet_group" "postgres" {
  name       = "postgres-${var.environment}"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "postgres-subnet-group-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_security_group" "postgres" {
  name        = "postgres-sg-${var.environment}"
  description = "Allow PostgreSQL inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = var.postgres_port
    to_port     = var.postgres_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "postgres-sg-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_db_instance" "postgres" {
  identifier             = "postgres-${var.environment}"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "15.3"
  instance_class         = "db.t3.micro"
  db_name                = var.postgres_db
  username               = var.postgres_user
  password               = var.postgres_password
  parameter_group_name   = "default.postgres15"
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = var.environment == "prod" ? true : false

  tags = {
    Name        = "postgres-${var.environment}"
    Environment = var.environment
  }
} 