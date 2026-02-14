resource "helm_release" "jenkins" {
  name       = var.release_name
  namespace  = var.namespace
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.chart_version

  create_namespace = true

  values = [file("${path.module}/values.yaml")]

  timeout = 900
}
