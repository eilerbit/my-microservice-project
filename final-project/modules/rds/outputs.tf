output "endpoint" {
  value = aws_db_instance.this.address
}

output "port" {
  value = aws_db_instance.this.port
}

output "db_name" {
  value = var.db_name
}

output "username" {
  value = var.db_username
}

output "security_group_id" {
  value = aws_security_group.rds.id
}

output "subnet_group_name" {
  value = aws_db_subnet_group.this.name
}
