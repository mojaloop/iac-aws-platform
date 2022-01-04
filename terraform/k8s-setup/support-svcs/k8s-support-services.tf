locals {
  env_values = {
    prom-mojaloop-url    = "http://loki-stack-prometheus-server"
    grafana-slack-url    = var.grafana_slack_notifier_url
    grafana_host = "grafana.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
    storage_class_name = var.ebs_storage_class_name
    dashboard_namespace = "monitoring"
  }
}

resource "helm_release" "loki-stack" {
  name         = "loki-stack"
  repository   = "https://grafana.github.io/helm-charts"
  chart        = "loki-stack"
  version      = var.helm_loki_stack_version
  namespace    = "monitoring"
  force_update = true
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/values-loki-stack.yaml.tpl", local.env_values)
  ]
  provider = helm.helm-gateway

}

data "kubernetes_secret" "grafana_admin_pw" {
  metadata {
    name      = "loki-stack-grafana"
    namespace = "monitoring"
  }
  provider   = kubernetes.k8s-gateway
  depends_on = [helm_release.loki-stack]
}

resource "vault_generic_secret" "grafana_admin_password" {
  path = "secret/grafana/adminpw"

  data_json = jsonencode({
    "value" = data.kubernetes_secret.grafana_admin_pw.data["admin-password"]
  })
}

resource "kubernetes_config_map" "grafana-support-services-dashboards" {
  for_each = fileset("${path.module}/templates/grafana-dashboards", "*.json")
  metadata {
    name      = substr("graf-sup-svcs-dbs-${trimsuffix(lower(each.value), ".json")}", 0, 63)
    namespace = "monitoring"
    labels = {
      mojaloop_dashboard = "1"
    }
  }
  data = {
    "${each.value}" = file("${path.module}/templates/grafana-dashboards/${each.value}")
  }
  provider = kubernetes.k8s-gateway
  depends_on = [helm_release.loki-stack]
}