data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = var.namespace
  }

  # optional but recommended if you have helm_release "argocd" in this module:
  # depends_on = [helm_release.argocd]
}

data "kubernetes_secret" "argocd_initial_admin" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.namespace
  }

  # optional but recommended if you have helm_release "argocd" in this module:
  # depends_on = [helm_release.argocd]
}

output "argocd_lb_hostname" {
  value = try(
    data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname,
    null
  )
}

output "argocd_admin_password" {
  value     = try(base64decode(data.kubernetes_secret.argocd_initial_admin.data.password), null)
  sensitive = true
}