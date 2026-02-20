data "kubernetes_service" "jenkins" {
  metadata {
    name      = var.release_name
    namespace = var.namespace
  }

  depends_on = [helm_release.jenkins]
}

output "jenkins_lb_hostname" {
  value = try(data.kubernetes_service.jenkins.status[0].load_balancer[0].ingress[0].hostname, null)
}