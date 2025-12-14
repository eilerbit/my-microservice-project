# Lesson 5 – Terraform IaC (AWS)

## Structure

### Modules

- **s3-backend**
  - Creates S3 bucket for Terraform remote state:
    - Versioning enabled
    - Server-side encryption (AES256)
    - Public access blocked
  - Creates DynamoDB table for state locking.

- **vpc**
  - Creates VPC (`10.0.0.0/16`).
  - 3 public subnets and 3 private subnets across 3 AZ.
  - Internet Gateway for public subnets.
  - NAT Gateway for private subnets.
  - Route tables and associations.

- **ecr**
  - Creates ECR repository.
  - Enables image scanning on push.
  - Sets basic repository policy.

## Commands

Initialize:

```bash
terraform init
terraform plan
terraform apply
terraform destroy

