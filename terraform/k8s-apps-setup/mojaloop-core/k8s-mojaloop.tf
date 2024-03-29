resource "kubernetes_ingress_v1" "wso2-mojaloop-ingress" {
  metadata {
    name      = "wso2-mojaloop-ingress"
    namespace = "mojaloop"
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = var.interop_switch_private_fqdn

      http {
        path {
          backend {
            service {
              name = "${var.helm_mojaloop_release_name}-account-lookup-service"
              port {
                number = 80
              }
            }
          }
          path = "/participants"
        }
        path {
          backend {
            service {
              name = "${var.helm_mojaloop_release_name}-account-lookup-service"
              port {
                number = 80
              }
            }
          }
          path = "/parties"
        }
        path {
          backend {
            service {
              name = "${var.helm_mojaloop_release_name}-quoting-service"
              port {
                number = 80
              }
            }
          }
          path = "/quotes"
        }
        path {
          backend {
            service {
              name = "${var.helm_mojaloop_release_name}-ml-api-adapter-service"
              port {
                number = 80
              }
            }
          }
          path = "/transfers"
        }
        path {
          backend {
            service {
              name = "${var.helm_mojaloop_release_name}-quoting-service"
              port {
                number = 80
              }
            }
          }
          path = "/bulkQuotes"
        }
        path {
          backend {
            service {
              name = "${var.helm_mojaloop_release_name}-bulk-api-adapter-service"
              port {
                number = 80
              }
            }
          }
          path = "/bulkTransfers"
        }
        path {
          backend {
            service {
              name = "${var.helm_mojaloop_release_name}-transaction-requests-service"
              port {
                number = 80
              }
            }
          }
          path = "/transactionRequests"
        }
        path {
          backend {
            service {
              name = "${var.helm_mojaloop_release_name}-transaction-requests-service"
              port {
                number = 80
              }
            }
          }
          path = "/authorizations"
        }
      }
    }
  }
  provider   = kubernetes.k8s-main
  depends_on = [helm_release.mojaloop]
}
resource "helm_release" "mojaloop" {
  name             = var.helm_mojaloop_release_name
  repository       = var.helm_mojaloop_repo
  chart            = "mojaloop"
  version          = var.helm_mojaloop_version
  namespace        = "mojaloop"
  timeout          = 600
  create_namespace = true
  values = [
    templatefile("${path.module}/templates/values-ml-v${local.ml_chart_major_version}.yaml.tpl", local.oss_values),
    templatefile("${path.module}/templates/testing-tool-kit/mojaloop-simulator-v${local.ml_chart_major_version}.yaml.tpl", local.oss_values)
  ]

  provider   = helm.helm-main
  depends_on = [helm_release.ttksimsredis]
}

resource "helm_release" "ttksimsredis" {
  name             = "ttksims-redis"
  count            = var.ttksims_enabled ? 1 : 0
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "redis"
  version          = "17.3.7"
  namespace        = "mojaloop"
  create_namespace = true
  values = [
    templatefile("${path.module}/templates/values-ttksims-redis.yaml.tpl", {})
  ]
  provider = helm.helm-main
}

locals {
  ml_als_resource_index                        = index(var.stateful_resources.*.resource_name, "account-lookup-db")
  ml_cl_resource_index                         = index(var.stateful_resources.*.resource_name, "central-ledger-db")
  bulk_mongodb_resource_index                  = index(var.stateful_resources.*.resource_name, "bulk-mongodb")
  ttk_mongodb_resource_index                   = index(var.stateful_resources.*.resource_name, "ttk-mongodb")
  cep_mongodb_resource_index                   = index(var.stateful_resources.*.resource_name, "cep-mongodb")
  mojaloop_kafka_resource_index                = index(var.stateful_resources.*.resource_name, "mojaloop-kafka")
  third_party_redis_resource_index             = index(var.stateful_resources.*.resource_name, "thirdparty-auth-svc-redis")
  third_party_auth_db_resource_index           = index(var.stateful_resources.*.resource_name, "thirdparty-auth-svc-db")
  third_party_consent_oracle_db_resource_index = index(var.stateful_resources.*.resource_name, "mysql-consent-oracle-db")

  ml_chart_major_version = split(".", var.helm_mojaloop_version)[0]
  oss_values = {
    env                                         = var.environment
    name                                        = var.client
    kafka_host                                  = "${var.stateful_resources[local.mojaloop_kafka_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    kafka_port                                  = var.stateful_resources[local.mojaloop_kafka_resource_index].logical_service_port
    account_lookup_db_existing_secret           = var.stateful_resources[local.ml_als_resource_index].generate_secret_name
    account_lookup_db_user                      = var.stateful_resources[local.ml_als_resource_index].local_resource.mysql_data.user
    account_lookup_db_host                      = "${var.stateful_resources[local.ml_als_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    account_lookup_db_port                      = var.stateful_resources[local.ml_als_resource_index].logical_service_port
    account_lookup_db_database                  = var.stateful_resources[local.ml_als_resource_index].local_resource.mysql_data.database_name
    central_ledger_db_existing_secret           = var.stateful_resources[local.ml_cl_resource_index].generate_secret_name
    central_ledger_db_user                      = var.stateful_resources[local.ml_cl_resource_index].local_resource.mysql_data.user
    central_ledger_db_host                      = "${var.stateful_resources[local.ml_cl_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    central_ledger_db_port                      = var.stateful_resources[local.ml_cl_resource_index].logical_service_port
    central_ledger_db_database                  = var.stateful_resources[local.ml_cl_resource_index].local_resource.mysql_data.database_name
    central_settlement_db_existing_secret       = var.stateful_resources[local.ml_cl_resource_index].generate_secret_name
    central_settlement_db_user                  = var.stateful_resources[local.ml_cl_resource_index].local_resource.mysql_data.user
    central_settlement_db_host                  = "${var.stateful_resources[local.ml_cl_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    central_settlement_db_port                  = var.stateful_resources[local.ml_cl_resource_index].logical_service_port
    central_settlement_db_database              = var.stateful_resources[local.ml_cl_resource_index].local_resource.mysql_data.database_name
    quoting_db_existing_secret                  = var.stateful_resources[local.ml_cl_resource_index].generate_secret_name
    quoting_db_user                             = var.stateful_resources[local.ml_cl_resource_index].local_resource.mysql_data.user
    quoting_db_host                             = "${var.stateful_resources[local.ml_cl_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    quoting_db_port                             = var.stateful_resources[local.ml_cl_resource_index].logical_service_port
    quoting_db_database                         = var.stateful_resources[local.ml_cl_resource_index].local_resource.mysql_data.database_name
    cep_mongodb_database                        = var.stateful_resources[local.cep_mongodb_resource_index].local_resource.mongodb_data.database_name
    cep_mongodb_user                            = var.stateful_resources[local.cep_mongodb_resource_index].local_resource.mongodb_data.user
    cep_mongodb_host                            = "${var.stateful_resources[local.cep_mongodb_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    cep_mongodb_existing_secret                 = var.stateful_resources[local.cep_mongodb_resource_index].generate_secret_name
    cep_mongodb_port                            = var.stateful_resources[local.cep_mongodb_resource_index].logical_service_port
    cl_mongodb_database                         = var.stateful_resources[local.bulk_mongodb_resource_index].local_resource.mongodb_data.database_name
    cl_mongodb_user                             = var.stateful_resources[local.bulk_mongodb_resource_index].local_resource.mongodb_data.user
    cl_mongodb_host                             = "${var.stateful_resources[local.bulk_mongodb_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    cl_mongodb_existing_secret                  = var.stateful_resources[local.bulk_mongodb_resource_index].generate_secret_name
    cl_mongodb_port                             = var.stateful_resources[local.bulk_mongodb_resource_index].logical_service_port
    ttk_mongodb_database                        = var.stateful_resources[local.ttk_mongodb_resource_index].local_resource.mongodb_data.database_name
    ttk_mongodb_user                            = var.stateful_resources[local.ttk_mongodb_resource_index].local_resource.mongodb_data.user
    ttk_mongodb_host                            = "${var.stateful_resources[local.ttk_mongodb_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    ttk_mongodb_existing_secret                 = var.stateful_resources[local.ttk_mongodb_resource_index].generate_secret_name
    ttk_mongodb_port                            = var.stateful_resources[local.ttk_mongodb_resource_index].logical_service_port
    third_party_consent_db_existing_secret      = var.stateful_resources[local.third_party_consent_oracle_db_resource_index].generate_secret_name
    third_party_consent_db_user                 = var.stateful_resources[local.third_party_consent_oracle_db_resource_index].local_resource.mysql_data.user
    third_party_consent_db_host                 = "${var.stateful_resources[local.third_party_consent_oracle_db_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    third_party_consent_db_port                 = var.stateful_resources[local.third_party_consent_oracle_db_resource_index].logical_service_port
    third_party_consent_db_database             = var.stateful_resources[local.third_party_consent_oracle_db_resource_index].local_resource.mysql_data.database_name
    third_party_auth_db_existing_secret         = var.stateful_resources[local.third_party_auth_db_resource_index].generate_secret_name
    third_party_auth_db_user                    = var.stateful_resources[local.third_party_auth_db_resource_index].local_resource.mysql_data.user
    third_party_auth_db_host                    = "${var.stateful_resources[local.third_party_auth_db_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    third_party_auth_db_port                    = var.stateful_resources[local.third_party_auth_db_resource_index].logical_service_port
    third_party_auth_db_database                = var.stateful_resources[local.third_party_auth_db_resource_index].local_resource.mysql_data.database_name
    third_party_auth_redis_host                 = "${var.stateful_resources[local.third_party_redis_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    third_party_auth_redis_port                 = var.stateful_resources[local.third_party_redis_resource_index].logical_service_port
    ttksims_redis_host                          = "ttksims-redis-master"
    ttksims_redis_port                          = "6379"
    elasticsearch_url                           = "http://localhost"
    kibana_url                                  = "http://localhost"
    wso2is_host                                 = "https://iskm.${var.public_subdomain}"
    internal_ttk_enabled                        = var.internal_ttk_enabled
    ttk_test_currency1                          = var.ttk_test_currency1
    ttk_test_currency2                          = var.ttk_test_currency2
    ttk_test_currency3                          = var.ttk_test_currency3
    internal_sim_enabled                        = var.internal_sim_enabled
    mojaloop_thirdparty_support_enabled         = var.third_party_enabled
    bulk_enabled                                = var.bulk_enabled
    ttksims_enabled                             = var.ttksims_enabled
    storage_class_name                          = var.storage_class_name
    jws_signing_priv_key                        = var.switch_jws_private_key
    ingress_class_name                          = "nginx"
    private_subdomain                           = var.private_subdomain
    quoting_service_simple_routing_mode_enabled = var.quoting_service_simple_routing_mode_enabled
  }
}

/* resource "helm_release" "esp-mojaloop" {
  name         = "esp-mojaloop"
  repository   = "http://mojaloop.io/helm/repo"
  chart        = "eventstreamprocessor"
  version      = var.helm_esp_version
  namespace    = "mojaloop"
  force_update = true
  create_namespace = true
  reuse_values = true

  values = [
    templatefile("${path.module}/templates/values-mojaloop-esp.yaml.tpl", {
      ELASTICSEARCH_HOST = var.elasticsearch-services-private-fqdn,
      APM_HOST           = var.apm-services-private-fqdn
    })
  ]
  set {
    name  = "config.kafka_host"
    value = "${var.helm_mojaloop_release_name}-kafka"
    type  = "string"
  }

  provider = helm.helm-main

  depends_on = [helm_release.mojaloop]
} */
