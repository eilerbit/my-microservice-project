terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "goit-devops-anton-tf-state"
  table_name  = "terraform-locks"
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.1.0.0/16"
  public_subnets     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  private_subnets    = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_name           = "lesson-db-module-vpc"
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-db-module-django-ecr"
  scan_on_push = true
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = "lesson-db-module-eks"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids

  node_instance_type = "t3.small"
  desired_size       = 2
  min_size           = 2
  max_size           = 4
}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

module "jenkins" {
  source = "./modules/jenkins"

  namespace = "jenkins"

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }

  depends_on = [module.eks]
}

module "argo_cd" {
  source = "./modules/argo_cd"

  namespace = "argocd"

  # repo Argo will watch (GitOps repo)
  repo_url        = "https://github.com/eilerbit/my-microservice-project.git"
  target_revision = "lesson-db-module"
  chart_path      = "lesson-db-module/charts/django-app"
  app_namespace   = "lesson-db-module"

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }

  depends_on = [module.eks]
}

module "rds" {
  source = "./modules/rds"

  name               = "lesson-db"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  allowed_cidr_blocks = ["10.1.0.0/16"]

  use_aurora     = false
  engine         = "postgres"
  engine_version = "16.3"
  instance_class = "db.t3.micro"
  multi_az       = false

  db_name     = "django_db"
  db_username = "django_user"
  db_password = var.db_password
}
