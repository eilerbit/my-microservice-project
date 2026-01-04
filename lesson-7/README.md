# Lesson 7 – Helm

cd lesson-7

terraform init
terraform plan
terraform apply

aws eks update-kubeconfig --region us-west-2 --name lesson-7-eks
kubectl get nodes

# Build & push Docker image to ECR
aws ecr get-login-password --region us-west-2 `
  | docker login --username AWS --password-stdin 177121335853.dkr.ecr.us-west-2.amazonaws.com

docker build -t lesson-7-django-ecr -f Dockerfile .

docker tag lesson-7-django-ecr:latest 177121335853.dkr.ecr.us-west-2.amazonaws.com/lesson-7-django-ecr:latest

docker push 177121335853.dkr.ecr.us-west-2.amazonaws.com/lesson-7-django-ecr:latest

# Deploy Helm chart
helm upgrade --install django-app ./charts/django-app `
  --namespace lesson-7 `
  --create-namespace

kubectl get pods -n lesson-7
kubectl get svc -n lesson-7

# Update release
helm upgrade django-app ./charts/django-app -n lesson-7

# Delete everything
helm uninstall django-app -n lesson-7
terraform destroy
