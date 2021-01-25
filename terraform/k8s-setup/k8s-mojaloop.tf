resource "kubernetes_storage_class" "slow-mojaloop" {
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
  provider = kubernetes.k8s-mojaloop
}

resource "kubernetes_ingress" "wso2-mojaloop-ingress" {
  metadata {
    name      = "wso2-mojaloop-ingress"
    namespace = "mojaloop"
  }
  spec {
    rule {
      host = data.terraform_remote_state.infrastructure.outputs.interop_switch_private_fqdn

      http {
        path {
          backend {
            service_name = "mojaloop-account-lookup-service"
            service_port = 80
          }
          path = "/participants"
        }
      }
    }
    rule {
      host = data.terraform_remote_state.infrastructure.outputs.interop_switch_private_fqdn

      http {
        path {
          backend {
            service_name = "mojaloop-account-lookup-service"
            service_port = 80
          }
          path = "/parties"
        }
      }
    }
    rule {
      host = data.terraform_remote_state.infrastructure.outputs.interop_switch_private_fqdn

      http {
        path {
          backend {
            service_name = "mojaloop-quoting-service"
            service_port = 80
          }
          path = "/quotes"
        }
      }
    }
    rule {
      host = data.terraform_remote_state.infrastructure.outputs.interop_switch_private_fqdn

      http {
        path {
          backend {
            service_name = "mojaloop-ml-api-adapter-service"
            service_port = 80
          }
          path = "/transfers"
        }
      }
    }
    rule {
      host = data.terraform_remote_state.infrastructure.outputs.interop_switch_private_fqdn

      http {
        path {
          backend {
            service_name = "bulk-quoting-service"
            service_port = 80
          }
          path = "/bulkQuotes"
        }
      }
    }
  }
  provider   = kubernetes.k8s-mojaloop
  depends_on = [helm_release.mojaloop]
}

resource "helm_release" "nginx-ingress" {
  count      = 1
  name       = "nginx-ingress"
  repository = "https://charts.helm.sh/stable"
  chart      = "nginx-ingress"
  version    = var.helm_nginx_version
  namespace  = "kube-public"
  wait       = false

  set {
    name  = "controller.service.nodePorts.http"
    value = "30001"
  }

  provider = helm.helm-mojaloop
}

resource "helm_release" "mojaloop" {
  name       = "mojaloop"
  repository = "http://mojaloop.io/helm/repo"
  chart      = "mojaloop"
  version    = var.helm_mojaloop_version
  namespace  = "mojaloop"
  timeout    = 800

  values = [
    templatefile("${path.module}/templates/values-lab-oss.yaml.tpl", local.oss_values)
  ]
  provider = helm.helm-mojaloop

  depends_on = [module.wso2_init]
}

resource "helm_release" "ml-bulk-quoting-service" {
  name       = "bulk-quoting"
  repository = "http://mojaloop.io/helm/repo"
  chart      = "quoting-service"
  version    = "10.4.1"
  namespace  = "mojaloop"
  timeout    = 300


  provider = helm.helm-mojaloop

  set {
    name  = "image.tag"
    value = "v11.1.0"
  }
  set {
    name  = "config.db_host"
    value = "${helm_release.mojaloop.name}-centralledger-mysql"
  }
  set {
    name  = "config.db_password"
    value = "KWvT8pzuBQ63Qp"
  }

  depends_on = [helm_release.mojaloop]
}

locals {
  oss_values = {
    env    = var.environment
    name   = var.name
    domain = data.terraform_remote_state.tenant.outputs.domain
    kafka  = var.kafka
  }
}


resource "kubernetes_job" "mojaloop_post_install" {

  metadata {
    name      = "mojaloop-post-install"
    namespace = "mojaloop"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "mojaloop-post-install"
          image   = "alpine"
          command = ["/bin/sh", "-c", "apk add git curl && git clone -b ${var.iac_post_init_version} https://github.com/mojaloop/iac_post_deploy.git && cd iac_post_deploy/backend-post-setup && sh switch_setup.sh"]
        }
        restart_policy = "Never"
      }
    }
    #ttl_seconds_after_finished = 60
    backoff_limit = 4
  }
  provider   = kubernetes.k8s-mojaloop
  depends_on = [helm_release.mojaloop]
}
#monitoring and logging deployments
resource "helm_release" "prometheus-mojaloop" {
  name         = "prometheus-mojaloop"
  repository   = "https://charts.helm.sh/stable"
  chart        = "prometheus"
  version      = var.helm_prometheus_version
  namespace    = "monitoring"
  force_update = true

  values = [
    file("${var.project_root_path}/helm/values-workload-clusters-prometheus.yaml")
  ]
  set {
    name  = "server.ingress.hosts"
    value = "{${data.terraform_remote_state.infrastructure.outputs.prometheus-mojaloop-private-fqdn}}"
  }
  provider = helm.helm-mojaloop

  depends_on = [kubernetes_storage_class.slow-mojaloop]
}

resource "helm_release" "fluentd-mojaloop" {
  name         = "fluentd-mojaloop"
  repository   = "https://kiwigrid.github.io"
  chart        = "fluentd-elasticsearch"
  version      = var.helm_fluentd_version
  namespace    = "logging"
  force_update = true

  values = [
    file("${var.project_root_path}/helm/values-workload-clusters-efk-fluentd.yaml")
  ]
  set {
    name  = "elasticsearch.host"
    value = data.terraform_remote_state.infrastructure.outputs.elasticsearch-services-private-fqdn
  }
  set {
    name  = "elasticsearch.port"
    value = "30000"
  }
  provider = helm.helm-mojaloop

  depends_on = [helm_release.kafka-support-services]
}

resource "helm_release" "esp-mojaloop" {
  name         = "esp-mojaloop"
  repository   = "http://mojaloop.io/helm/repo"
  chart        = "eventstreamprocessor"
  version      = var.helm_esp_version
  namespace    = "mojaloop"
  force_update = true

  values = [
    templatefile("${path.module}/templates/values-mojaloop-esp.yaml.tpl", {
      ELASTICSEARCH_HOST = data.terraform_remote_state.infrastructure.outputs.elasticsearch-services-private-fqdn,
      APM_HOST           = data.terraform_remote_state.infrastructure.outputs.apm-services-private-fqdn
    })
  ]
  set {
    name  = "config.kafka_host"
    value = "mojaloop-kafka"
  }

  provider = helm.helm-mojaloop

  depends_on = [helm_release.mojaloop]
}
