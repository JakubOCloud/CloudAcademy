resource "aws_db_subnet_group" "postgres" {
  name = "${var.project_name}-db-subnets"

  subnet_ids = aws_subnet.private_db[*].id

  tags = {
    Name = "${var.project_name}-db-subnets"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds"
  description = "RDS PostgreSQL Security Group"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "PostgreSQL from EKS nodes"

    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    cidr_blocks = var.private_app_subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_password" "postgres" {
  length  = 24
  special = true
}

resource "aws_db_instance" "postgres" {

  identifier = "${var.project_name}-postgres"

  engine         = "postgres"
  engine_version = "16"

  instance_class = "db.t4g.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.postgres.result

  port = 5432

  multi_az = true

  publicly_accessible = false

  db_subnet_group_name = aws_db_subnet_group.postgres.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  backup_retention_period = 7

  performance_insights_enabled = true

  deletion_protection = false

  skip_final_snapshot = true
}
