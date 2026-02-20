resource "kubernetes_manifest" "django_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "django-app"
      namespace = var.namespace
    }
    spec = {
      project = "default"

      source = {
        repoURL        = var.repo_url
        targetRevision = var.target_revision
        path           = var.chart_path
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.app_namespace
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  depends_on = [
    helm_release.argo_cd,
    kubernetes_namespace.app
  ]
}
