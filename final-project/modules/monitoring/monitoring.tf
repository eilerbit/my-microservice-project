resource "helm_release" "metrics_server" {
  name             = "metrics-server"
  namespace        = var.namespace
  create_namespace = true

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  timeout    = 600
}

resource "helm_release" "kube_prom_stack" {
  name             = var.release_name
  namespace        = var.namespace
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version
  timeout    = 900
  
  values = [
    file("${path.module}/values.yaml"),
    yamlencode({
      grafana = {
        adminPassword = var.grafana_admin_password
      }
    })
  ]

  depends_on = [helm_release.metrics_server]
}

