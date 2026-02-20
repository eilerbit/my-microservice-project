locals {
  is_postgres = var.engine == "postgres"
  is_mysql    = var.engine == "mysql"

  pg_major    = tonumber(split(".", var.engine_version)[0])
  mysql_major = tonumber(split(".", var.engine_version)[0])

  # Default DB port (can be overridden via var.port)
  port = var.port != null ? var.port : (
    local.is_postgres ? 5432 :
    local.is_mysql ? 3306 :
    0
  )

  # Parameter group family (can be overridden via var.parameter_group_family)
  rds_family = var.parameter_group_family != null ? var.parameter_group_family : (
    local.is_postgres ? "postgres${local.pg_major}" :
    local.is_mysql ? "mysql${local.mysql_major}.0" :
    null
  )

  aurora_family = var.parameter_group_family != null ? var.parameter_group_family : (
    local.is_postgres ? "aurora-postgresql${local.pg_major}" :
    local.is_mysql ? "aurora-mysql${local.mysql_major}.0" :
    null
  )

  # If user provided custom parameters -> use them, otherwise apply sane defaults
  base_parameters = length(var.parameters) > 0 ? var.parameters : (
    local.is_postgres ? [
      { name = "max_connections", value = "200", apply_method = "pending-reboot" },
      { name = "log_statement", value = "none", apply_method = "immediate" },
      { name = "work_mem", value = "4MB", apply_method = "immediate" },
    ] :
    local.is_mysql ? [
      { name = "max_connections", value = "200", apply_method = "pending-reboot" },
      { name = "general_log", value = "0", apply_method = "immediate" },
      { name = "sort_buffer_size", value = "262144", apply_method = "immediate" },
    ] :
    []
  )
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.name}-db-subnets"
  }
}

resource "aws_security_group" "this" {
  name        = "${var.name}-db-sg"
  description = "DB access security group"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      from_port   = local.port
      to_port     = local.port
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
      description = "DB access from CIDRs"
    }
  }

  dynamic "ingress" {
    for_each = length(var.allowed_security_group_ids) > 0 ? [1] : []
    content {
      from_port       = local.port
      to_port         = local.port
      protocol        = "tcp"
      security_groups = var.allowed_security_group_ids
      description     = "DB access from security groups"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-db-sg"
  }
}

# Parameter group for normal RDS instance
resource "aws_db_parameter_group" "rds" {
  count  = var.use_aurora ? 0 : 1
  name   = "${var.name}-rds-params"
  family = local.rds_family

  dynamic "parameter" {
    for_each = local.base_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = {
    Name = "${var.name}-rds-params"
  }
}

# Cluster parameter group for Aurora
resource "aws_rds_cluster_parameter_group" "aurora" {
  count  = var.use_aurora ? 1 : 0
  name   = "${var.name}-aurora-cluster-params"
  family = local.aurora_family

  dynamic "parameter" {
    for_each = local.base_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = {
    Name = "${var.name}-aurora-cluster-params"
  }
}

# Instance parameter group for Aurora instances (optional but nice)
resource "aws_db_parameter_group" "aurora_instance" {
  count  = var.use_aurora ? 1 : 0
  name   = "${var.name}-aurora-instance-params"
  family = local.aurora_family

  dynamic "parameter" {
    for_each = local.base_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = {
    Name = "${var.name}-aurora-instance-params"
  }
}