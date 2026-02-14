resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.name}-db-subnets"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.name}-rds-sg"
  description = "Allow Postgres from EKS cluster SG"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Postgres from EKS cluster SG"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [var.allowed_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-rds-sg"
  }
}
