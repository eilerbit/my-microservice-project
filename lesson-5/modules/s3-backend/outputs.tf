output "bucket_name" {
  value       = aws_s3_bucket.terraform_state.bucket
  description = "S3 bucket name for Terraform state"
}

output "bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "S3 bucket ARN"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "DynamoDB table name for Terraform state lock"
}

output "dynamodb_table_arn" {
  value       = aws_dynamodb_table.terraform_locks.arn
  description = "DynamoDB table ARN"
}
