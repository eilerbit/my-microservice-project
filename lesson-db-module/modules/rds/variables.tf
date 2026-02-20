variable "name" {
  type        = string
  description = "Base name for resources (db, sg, subnet group, parameter groups)."
}

variable "use_aurora" {
  type        = bool
  description = "true -> Aurora Cluster + writer instance, false -> single aws_db_instance"
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "VPC id where DB will be placed"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet ids for DB subnet group"
}

variable "engine" {
  type        = string
  description = "DB engine. RDS: postgres/mysql. Aurora: aurora-postgresql/aurora-mysql"
  default     = "postgres"

  validation {
    condition     = var.use_aurora ? can(regex("^aurora-", var.engine)) : true
    error_message = "When use_aurora=true, engine must start with 'aurora-' (e.g. aurora-postgresql or aurora-mysql)."
  }
}

variable "engine_version" {
  type        = string
  description = "Engine version. Make sure it matches chosen engine family."
  default     = "16.3"
}

variable "instance_class" {
  type        = string
  description = "DB instance class (RDS instance or Aurora instance class)."
  default     = "db.t3.micro"
}

variable "multi_az" {
  type        = bool
  description = "Only for non-Aurora RDS instance."
  default     = false
}

variable "allocated_storage" {
  type        = number
  description = "Only for non-Aurora RDS instance."
  default     = 20
}

variable "storage_type" {
  type        = string
  description = "Only for non-Aurora RDS instance."
  default     = "gp3"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "db_username" {
  type        = string
  description = "Master username"
}

variable "db_password" {
  type        = string
  description = "Master password"
  sensitive   = true
}

variable "db_port" {
  type        = number
  description = "DB port. If null, auto: 5432 for postgres, 3306 for mysql."
  default     = null
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to connect to DB (optional)."
  default     = []
}

variable "allowed_security_group_ids" {
  type        = list(string)
  description = "Security group ids allowed to connect to DB (optional)."
  default     = []
}

variable "backup_retention_period" {
  type        = number
  description = "Backups retention for Aurora cluster."
  default     = 1
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot on delete."
  default     = true
}

variable "deletion_protection" {
  type        = bool
  description = "Deletion protection."
  default     = false
}

variable "apply_immediately" {
  type        = bool
  description = "Apply changes immediately."
  default     = true
}

variable "parameter_group_family" {
  type        = string
  description = "Optional override for RDS parameter group family (e.g. postgres16, mysql8.0). If null, will try to build automatically."
  default     = null
}

variable "cluster_parameter_group_family" {
  type        = string
  description = "Optional override for Aurora cluster parameter group family (e.g. aurora-postgresql16). If null, will try to build automatically."
  default     = null
}

variable "db_port_override" {
  type        = number
  description = "Deprecated. Use db_port instead."
  default     = null
}

locals {
  # guard: at least one ingress source
  _ingress_ok = length(var.allowed_cidr_blocks) > 0 || length(var.allowed_security_group_ids) > 0
}

# hard validation for ingress sources
resource "null_resource" "validate_ingress" {
  count = local._ingress_ok ? 0 : 1

  provisioner "local-exec" {
    command = "echo 'ERROR: Provide allowed_cidr_blocks or allowed_security_group_ids' && exit 1"
  }
}

variable "parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  description = "Custom DB parameters for parameter group"
  default     = []
}

variable "port" {
  type        = number
  description = "Optional override for DB port"
  default     = null
}