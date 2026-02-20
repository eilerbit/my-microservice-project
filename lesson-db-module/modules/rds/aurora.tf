resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier = "${var.name}-aurora"
  engine             = var.engine
  engine_version     = var.engine_version

  database_name   = var.db_name
  master_username = var.db_username
  master_password = var.db_password
  port            = local.port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora[0].name

  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  apply_immediately       = var.apply_immediately
  skip_final_snapshot     = var.skip_final_snapshot
}

resource "aws_rds_cluster_instance" "writer" {
  count = var.use_aurora ? 1 : 0

  identifier         = "${var.name}-aurora-writer"
  cluster_identifier = aws_rds_cluster.this[0].id

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_parameter_group_name = aws_db_parameter_group.aurora_instance[0].name

  publicly_accessible = false
}