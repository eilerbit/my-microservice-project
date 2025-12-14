output "s3_backend_bucket_name" {
  description = "S3 bucket name used for Terraform backend"
  value       = module.s3_backend.bucket_name
}

output "s3_backend_dynamodb_table_name" {
  description = "DynamoDB table name used for state locking"
  value       = module.s3_backend.dynamodb_table_name
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the created VPC"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "IDs of public subnets"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "IDs of private subnets"
}

output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "URL of the ECR repository"
}
