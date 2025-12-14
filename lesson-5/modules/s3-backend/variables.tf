variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

variable "table_name" {
  description = "Name of DynamoDB table for Terraform state lock"
  type        = string
}
