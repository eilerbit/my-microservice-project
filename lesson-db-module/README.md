# Lesson db-module – Jenkins + Terraform + ECR + Helm + Argo CD (GitOps)

cd lesson-db-module

terraform init
terraform plan
terraform apply

# Connect kubectl to EKS
aws eks update-kubeconfig --region us-west-2 --name lesson-db-module-eks
kubectl get nodes

# Check Jenkins & ArgoCD are installed (Terraform via Helm)
kubectl get pods -n jenkins
kubectl get svc  -n jenkins

kubectl get pods -n argocd
kubectl get svc  -n argocd

# (Optional) Get Jenkins admin password
kubectl -n jenkins get secret jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 -d
echo

# (Optional) Access Jenkins locally if service is ClusterIP
kubectl -n jenkins port-forward svc/jenkins 8080:8080
# Open: http://localhost:8080

# (Optional) Get Argo CD initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo

# (Optional) Access Argo CD locally if service is ClusterIP
kubectl -n argocd port-forward svc/argocd-server 8081:80
# Open: http://localhost:8081 (user: admin, password: from secret above)

# --------------------------------------------------------------------
# CI (Jenkins): build & push Docker image to ECR + update Helm values.yaml
# --------------------------------------------------------------------
# Jenkins pipeline (Jenkinsfile) does:
# 1. Build Docker image (Kaniko agent)
# 2. Push image to ECR (lesson-db-module-django-ecr)
# 3. Update image tag in: lesson-db-module/charts/django-app/values.yaml
# 4. Commit & push to Git branch: lesson-db-module

# Verify ECR repository exists (optional)
aws ecr describe-repositories --region us-west-2 --repository-names lesson-db-module-django-ecr

# --------------------------------------------------------------------
# CD (Argo CD): auto-sync from Git after Jenkins pushes chart change
# --------------------------------------------------------------------
# Argo CD Application watches:
# repo: https://github.com/eilerbit/my-microservice-project.git
# branch: lesson-db-module
# path: lesson-db-module/charts/django-app
# namespace: lesson-db-module
#
# After Jenkins updates values.yaml and pushes to Git,
# Argo CD automatically syncs the Helm release.

# Check Django app after Argo sync
kubectl get pods -n lesson-db-module
kubectl get svc  -n lesson-db-module
kubectl get hpa  -n lesson-db-module

# --------------------------------------------------------------------
# Приклад використання (RDS instance)
# --------------------------------------------------------------------
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
# --------------------------------------------------------------------
# Manual Helm deploy (optional, for debug only)
# --------------------------------------------------------------------
helm upgrade --install django-app ./charts/django-app `
  --namespace lesson-db-module `
  --create-namespace

kubectl get pods -n lesson-db-module
kubectl get svc  -n lesson-db-module

# --------------------------------------------------------------------
# Delete everything
# --------------------------------------------------------------------
# Remove app (optional)
helm uninstall django-app -n lesson-db-module

# Destroy infrastructure (IMPORTANT to avoid AWS costs)
cd lesson-db-module
terraform destroy
