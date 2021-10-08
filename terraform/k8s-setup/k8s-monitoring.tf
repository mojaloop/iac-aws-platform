locals {
  env_values = {
    grafana-slack-url    = var.grafana_slack_notifier_url
  }
}

resource "helm_release" "loki-stack" {
  name         = "loki-stack"
  repository   = "https://grafana.github.io/helm-charts"
  chart        = "loki-stack"
  version      = var.helm_lokistack_version
  namespace    = "monitoring"
  force_update = true
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/values-loki.yaml.tpl", local.env_values)
  ]
  set {
    name  = "grafana.enabled"
    value = false
  }
  set {
    name  = "prometheus.enabled"
    value = false
  }
  provider = helm.helm-gateway

  depends_on = [module.wso2_init.storage_class]
}



resource "helm_release" "prom-op" {
  name         = "prometheus-operator"
  repository   = "https://charts.bitnami.com/bitnami"
  chart        = "kube-prometheus"
  version      = var.helm_kube_prom_op_version
  namespace    = "monitoring"
  force_update = true
  create_namespace = true
  values = [
    templatefile("${path.module}/templates/values-prom-oper.yaml.tpl", local.env_values)
  ]
  provider = helm.helm-gateway

  depends_on = [module.wso2_init.storage_class]
}

resource "helm_release" "grafana-op" {
  name         = "grafana-op"
  repository   = "https://charts.bitnami.com/bitnami"
  chart        = "grafana-operator"
  version      = var.helm_grafana_op_version
  namespace    = "monitoring"
  force_update = true
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/values-grafana-op.yaml.tpl", local.env_values)
  ]
  set {
    name  = "grafana.ingress.hostname"
    value = "${data.terraform_remote_state.infrastructure.outputs.grafana-services-private-fqdn}"
    type  = "string"
  }
  set {
    name  = "grafana.ingress.enabled"
    value = "true"
  }

  provider = helm.helm-gateway

  depends_on = [kubernetes_config_map.grafana-support-services-dashboards]
}
##get admin pw after and put in vault
/* resource "kubernetes_config_map" "grafana-support-services-dashboards" {
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

  depends_on = [helm_release.prometheus-support-services]
} */