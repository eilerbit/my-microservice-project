# Lesson 8–9 – Jenkins + Terraform + ECR + Helm + Argo CD (GitOps)

cd lesson-8-9

terraform init
terraform plan
terraform apply

# Connect kubectl to EKS
aws eks update-kubeconfig --region us-west-2 --name lesson-8-9-eks
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
# 2. Push image to ECR (lesson-8-9-django-ecr)
# 3. Update image tag in: lesson-8-9/charts/django-app/values.yaml
# 4. Commit & push to Git branch: lesson-8-9

# Verify ECR repository exists (optional)
aws ecr describe-repositories --region us-west-2 --repository-names lesson-8-9-django-ecr

# --------------------------------------------------------------------
# CD (Argo CD): auto-sync from Git after Jenkins pushes chart change
# --------------------------------------------------------------------
# Argo CD Application watches:
# repo: https://github.com/eilerbit/my-microservice-project.git
# branch: lesson-8-9
# path: lesson-8-9/charts/django-app
# namespace: lesson-8-9
#
# After Jenkins updates values.yaml and pushes to Git,
# Argo CD automatically syncs the Helm release.

# Check Django app after Argo sync
kubectl get pods -n lesson-8-9
kubectl get svc  -n lesson-8-9
kubectl get hpa  -n lesson-8-9

# --------------------------------------------------------------------
# Manual Helm deploy (optional, for debug only)
# --------------------------------------------------------------------
helm upgrade --install django-app ./charts/django-app `
  --namespace lesson-8-9 `
  --create-namespace

kubectl get pods -n lesson-8-9
kubectl get svc  -n lesson-8-9

# --------------------------------------------------------------------
# Delete everything
# --------------------------------------------------------------------
# Remove app (optional)
helm uninstall django-app -n lesson-8-9

# Destroy infrastructure (IMPORTANT to avoid AWS costs)
cd lesson-8-9
terraform destroy
