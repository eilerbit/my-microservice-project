data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = var.namespace
  }

  depends_on = [helm_release.argo_cd]
}

data "kubernetes_secret" "argocd_initial_admin" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.namespace
  }

  depends_on = [helm_release.argo_cd]
}

output "argocd_lb_hostname" {
  value = try(data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname, null)
}

output "argocd_admin_password" {
  value     = try(base64decode(data.kubernetes_secret.argocd_initial_admin.data.password), null)
  sensitive = true
}
data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = var.namespace
  }

  depends_on = [helm_release.argo_cd]
}

data "kubernetes_secret" "argocd_initial_admin" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.namespace
  }

  depends_on = [helm_release.argo_cd]
}

output "argocd_lb_hostname" {
  value = try(data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname, null)
}

output "argocd_admin_password" {
  value     = try(base64decode(data.kubernetes_secret.argocd_initial_admin.data.password), null)
  sensitive = true
}
