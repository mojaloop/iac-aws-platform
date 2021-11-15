locals {
  env_values = {
    prom-add-ons-url     = "http://${data.terraform_remote_state.infrastructure.outputs.prometheus-add-ons-private-fqdn}:30001"
    prom-mojaloop-url    = "http://prometheus-support-services-server"
    grafana-slack-url    = var.grafana_slack_notifier_url
  }
}

resource "helm_release" "elasticsearch-support-services" {
  name         = "elasticsearch-support-services"
  repository   = "https://helm.elastic.co"
  chart        = "elasticsearch"
  version      = var.helm_elasticsearch_version
  namespace    = "logging"
  force_update = true
  create_namespace = true

  values = [
    file("${var.project_root_path}/helm/values-support-services-efk-elasticsearch.yaml")
  ]
  set {
    name  = "ingress.hosts"
    value = "{${data.terraform_remote_state.infrastructure.outputs.elasticsearch-services-private-fqdn}}"
    type  = "string"
  }
  provider = helm.helm-gateway

  depends_on = [module.wso2_init.storage_class]
}

resource "helm_release" "fluentd-support-services" {
  name         = "fluentd-support-services"
  repository   = "https://kiwigrid.github.io"
  chart        = "fluentd-elasticsearch"
  version      = var.helm_fluentd_version
  namespace    = "logging"
  force_update = true
  create_namespace = true

  values = [templatefile("${path.module}/templates/values-fluentd.yaml.tpl", {
    es_host = "elasticsearch-master:9200"
    })]

  provider = helm.helm-gateway

  depends_on = [helm_release.elasticsearch-support-services]
}

resource "helm_release" "kibana-support-services" {
  name         = "kibana-support-services"
  repository   = "https://helm.elastic.co"
  chart        = "kibana"
  version      = var.helm_kibana_version
  namespace    = "logging"
  force_update = true
  create_namespace = true

  values = [
    file("${var.project_root_path}/helm/values-support-services-efk-kibana.yaml")
  ]
  set {
    name  = "ingress.hosts"
    value = "{${data.terraform_remote_state.infrastructure.outputs.kibana-services-private-fqdn}}"
    type  = "string"
  }
  provider = helm.helm-gateway

  depends_on = [helm_release.elasticsearch-support-services]
}

resource "helm_release" "apm-support-services" {
  name         = "apm-support-services"
  repository   = "https://charts.helm.sh/stable"
  chart        = "apm-server"
  version      = var.helm_apm_version
  namespace    = "logging"
  force_update = true
  create_namespace = true

  values = [
    file("${var.project_root_path}/helm/values-support-services-efk-apm.yaml")
  ]

  set {
    name  = "ingress.hosts"
    value = "{${data.terraform_remote_state.infrastructure.outputs.apm-services-private-fqdn}}"
    type  = "string"
  }
  provider = helm.helm-gateway

  depends_on = [module.wso2_init.storage_class]
}

resource "helm_release" "prometheus-support-services" {
  name         = "prometheus-support-services"
  repository   = "https://charts.helm.sh/stable"
  chart        = "prometheus"
  version      = var.helm_prometheus_version
  namespace    = "monitoring"
  force_update = true
  create_namespace = true

  values = [
    file("${var.project_root_path}/helm/values-support-services-prometheus.yaml")
  ]
  set {
    name  = "server.ingress.hosts"
    value = "{${data.terraform_remote_state.infrastructure.outputs.prometheus-services-private-fqdn}}"
    type  = "string"
  }
  provider = helm.helm-gateway

  depends_on = [module.wso2_init.storage_class]
}

resource "random_password" "grafana_admin_password" {
  length = 16
  special = false
}

resource "vault_generic_secret" "grafana_admin_password" {
  path = "secret/grafana/adminpw"

  data_json = jsonencode({
    "value" = random_password.grafana_admin_password.result
  })
}

resource "helm_release" "grafana-support-services" {
  name         = "grafana-support-services"
  repository   = "https://charts.helm.sh/stable"
  chart        = "grafana"
  version      = var.helm_grafana_version
  namespace    = "monitoring"
  force_update = true
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/values-support-services-grafana.yaml.tpl", local.env_values)
  ]
  set {
    name  = "ingress.hosts"
    value = "{${data.terraform_remote_state.infrastructure.outputs.grafana-services-private-fqdn}}"
    type  = "string"
  }
  set {
    name  = "sidecar.dashboards.enabled"
    value = "true"
  }
  set {
    name  = "sidecar.dashboards.searchNamespace"
    value = "monitoring"
    type  = "string"
  }
  set {
    name  = "sidecar.dashboards.label"
    value = "mojaloop_dashboard"
    type  = "string"
  }
  set {
    name  = "adminPassword"
    value = random_password.grafana_admin_password.result
    type  = "string"
  }

  provider = helm.helm-gateway

  depends_on = [kubernetes_config_map.grafana-support-services-dashboards]
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

  depends_on = [helm_release.prometheus-support-services]
}