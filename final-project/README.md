# Final Project – Terraform + AWS (VPC, EKS, RDS, ECR) + Jenkins + Argo CD + Monitoring

cd final-project

## 1 Preparation

terraform init
terraform validate
terraform plan

## 2 Deploy infrastructure

terraform apply

## 3 Connect kubectl to EKS

aws eks update-kubeconfig --region us-west-2 --name final-eks
kubectl get nodes

## 4 Verify namespaces and resources

kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring

## 5 Access services (port-forward)

### Jenkins
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
# Open: http://localhost:8080

# Jenkins admin password:
kubectl -n jenkins get secret jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 -d
echo

### Argo CD
kubectl port-forward svc/argocd-server 8081:443 -n argocd
# Open: https://localhost:8081

# ArgoCD initial password:
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo

### Grafana (Monitoring)
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
# Open: http://localhost:3000

# Grafana credentials:
# user: admin
# password: value from Terraform variable grafana_admin_password

## 6 CI/CD flow (what to check)

Jenkins pipeline (Jenkinsfile) does:
1) Build Docker image from Dockerfile
2) Push image to Amazon ECR
3) Update Helm values.yaml with the new image tag
4) Push changes to Git branch: final-project

Argo CD watches the repo/branch/path with Helm chart and automatically syncs to the cluster.

## 7 Verify application after sync

kubectl get pods -n final
kubectl get svc  -n final
kubectl get hpa  -n final

## 8 IMPORTANT: cleanup to avoid AWS costs

terraform destroy

⚠️ WARNING:
If you destroy everything, S3 bucket and DynamoDB (Terraform state backend) may also be destroyed.
To recreate infra after destroy:
- bootstrap backend (S3 + DynamoDB)
- re-init terraform
- terraform apply again
