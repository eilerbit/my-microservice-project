resource "aws_db_instance" "this" {
  count = var.use_aurora ? 0 : 1

  identifier     = "${var.name}-postgres"
  engine         = var.engine
  engine_version = var.engine_version

  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  multi_az          = var.multi_az

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = local.port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  parameter_group_name = aws_db_parameter_group.rds[0].name

  publicly_accessible = false
  deletion_protection = var.deletion_protection
  apply_immediately   = var.apply_immediately
  skip_final_snapshot = var.skip_final_snapshot
}