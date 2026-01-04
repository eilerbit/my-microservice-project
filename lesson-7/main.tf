terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# module "s3_backend" {
#   source      = "./modules/s3-backend"
#   bucket_name = "goit-devops-anton-tf-state"
#   table_name  = "terraform-locks"
# }

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.1.0.0/16"
  public_subnets     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  private_subnets    = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_name           = "lesson-7-vpc"
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-7-django-ecr"
  scan_on_push = true
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = "lesson-7-eks"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids

  node_instance_type = "t3.small"
  desired_size       = 2
  min_size           = 2
  max_size           = 4
}

