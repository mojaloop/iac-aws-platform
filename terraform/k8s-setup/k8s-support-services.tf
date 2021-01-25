locals {
  env_values = {
    prom-gateway-url     = "http://${data.terraform_remote_state.infrastructure.outputs.prometheus-gateway-private-fqdn}:30000"
    prom-add-ons-url     = "http://${data.terraform_remote_state.infrastructure.outputs.prometheus-add-ons-private-fqdn}:30001"
    prom-mojaloop-url    = "http://${data.terraform_remote_state.infrastructure.outputs.prometheus-mojaloop-private-fqdn}:30000"
    prom-sup-service-url = "http://prometheus-support-services-server"
    grafana-slack-url    = var.grafana_slack_notifier_url
  }
}

resource "kubernetes_storage_class" "slow-support-services" {
  metadata {
    name = "slow"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Retain"
  parameters = {
    type      = "gp2"
    iopsPerGB = "10"
    fsType    = "ext4"
  }
  provider = kubernetes.k8s-support-services
}


resource "helm_release" "elasticsearch-support-services" {
  name         = "elasticsearch-support-services"
  repository   = "https://helm.elastic.co"
  chart        = "elasticsearch"
  version      = var.helm_elasticsearch_version
  namespace    = "logging"
  force_update = true

  values = [
    file("${var.project_root_path}/helm/values-support-services-efk-elasticsearch.yaml")
  ]
  set {
    name  = "ingress.hosts"
    value = "{${data.terraform_remote_state.infrastructure.outputs.elasticsearch-services-private-fqdn}}"
  }
  provider = helm.helm-support-services

  depends_on = [kubernetes_storage_class.slow-support-services, helm_release.kafka-support-services]
}

resource "helm_release" "fluentd-support-services" {
  name         = "fluentd-support-services"
  repository   = "https://kiwigrid.github.io"
  chart        = "fluentd-elasticsearch"
  version      = var.helm_fluentd_version
  namespace    = "logging"
  force_update = true

  values = [
    file("${var.project_root_path}/helm/values-support-services-efk-fluentd.yaml")
  ]
  set {
    name  = "elasticsearch.host"
    value = "elasticsearch-master"
  }
  provider = helm.helm-support-services

  depends_on = [helm_release.elasticsearch-support-services]
}

resource "helm_release" "kibana-support-services" {
  name         = "kibana-support-services"
  repository   = "https://helm.elastic.co"
  chart        = "kibana"
  version      = var.helm_kibana_version
  namespace    = "logging"
  force_update = true

  values = [
    file("${var.project_root_path}/helm/values-support-services-efk-kibana.yaml")
  ]
  set {
    name  = "ingress.hosts"
    value = "{${data.terraform_remote_state.infrastructure.outputs.kibana-services-private-fqdn}}"
  }
  provider = helm.helm-support-services

  depends_on = [helm_release.elasticsearch-support-services]
}

resource "helm_release" "apm-support-services" {
  name         = "apm-support-services"
  repository   = "https://charts.helm.sh/stable"
  chart        = "apm-server"
  version      = var.helm_apm_version
  namespace    = "logging"
  force_update = true

  values = [
    file("${var.project_root_path}/helm/values-support-services-efk-apm.yaml")
  ]

  set {
    name  = "ingress.hosts"
    value = "{${data.terraform_remote_state.infrastructure.outputs.apm-services-private-fqdn}}"
  }
  provider = helm.helm-support-services

  depends_on = [kubernetes_storage_class.slow-support-services]
}

resource "helm_release" "prometheus-support-services" {
  name         = "prometheus-support-services"
  repository   = "https://charts.helm.sh/stable"
  chart        = "prometheus"
  version      = var.helm_prometheus_version
  namespace    = "monitoring"
  force_update = true

  values = [
    file("${var.project_root_path}/helm/values-support-services-prometheus.yaml")
  ]
  set {
    name  = "server.ingress.hosts"
    value = "{${data.terraform_remote_state.infrastructure.outputs.prometheus-services-private-fqdn}}"
  }
  provider = helm.helm-support-services

  depends_on = [kubernetes_storage_class.slow-support-services]
}

resource "helm_release" "grafana-support-services" {
  name         = "grafana-support-services"
  repository   = "https://charts.helm.sh/stable"
  chart        = "grafana"
  version      = var.helm_grafana_version
  namespace    = "monitoring"
  force_update = true

  values = [
    templatefile("${path.module}/templates/values-support-services-grafana.yaml.tpl", local.env_values)
  ]
  set {
    name  = "ingress.hosts"
    value = "{${data.terraform_remote_state.infrastructure.outputs.grafana-services-private-fqdn}}"
  }
  set {
    name  = "sidecar.dashboards.enabled"
    value = "true"
  }
  set {
    name  = "sidecar.dashboards.searchNamespace"
    value = "monitoring"
  }
  set {
    name  = "sidecar.dashboards.label"
    value = "mojaloop_dashboard"
  }

  provider = helm.helm-support-services

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
  provider = kubernetes.k8s-support-services

  depends_on = [helm_release.prometheus-support-services]
}

resource "helm_release" "kafka-support-services" {
  name         = "kafka-support-services"
  repository   = "https://charts.helm.sh/incubator"
  chart        = "kafka"
  version      = var.helm_kafka_version
  namespace    = "logging"
  force_update = true

  set {
    name  = "storageClass"
    value = "slow"
  }
  values = [
    "${file("${var.project_root_path}/helm/values-support-services-kafka.yaml")}"
  ]
  provider = helm.helm-support-services

  depends_on = [kubernetes_storage_class.slow-support-services]
}

resource "helm_release" "deploy-support-services-nginx-ingress-controller" {
  namespace  = "kube-public"
  name       = "nginx-ingress"
  repository = "https://charts.helm.sh/stable"
  chart      = "nginx-ingress"
  version    = var.helm_nginx_version
  wait       = false

  set {
    name  = "controller.service.nodePorts.http"
    value = 30001
  }
  provider = helm.helm-support-services
}
