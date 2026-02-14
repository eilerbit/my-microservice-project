resource "helm_release" "argo_cd" {
  name       = var.release_name
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  create_namespace = true

  values = [file("${path.module}/values.yaml")]

  timeout = 900
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = var.app_namespace
  }
}
