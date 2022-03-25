resource "kubernetes_ingress" "wso2-mojaloop-ingress" {
  metadata {
    name      = "wso2-mojaloop-ingress"
    namespace = "mojaloop"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }
  spec {
    rule {
      host = data.terraform_remote_state.infrastructure.outputs.interop_switch_private_fqdn

      http {
        path {
          backend {
            service_name = "${var.helm_mojaloop_release_name}-account-lookup-service"
            service_port = 80
          }
          path = "/participants"
        }
        path {
          backend {
            service_name = "${var.helm_mojaloop_release_name}-account-lookup-service"
            service_port = 80
          }
          path = "/parties"
        }
        path {
          backend {
            service_name = "${var.helm_mojaloop_release_name}-quoting-service"
            service_port = 80
          }
          path = "/quotes"
        }
        path {
          backend {
            service_name = "${var.helm_mojaloop_release_name}-ml-api-adapter-service"
            service_port = 80
          }
          path = "/transfers"
        }
        path {
          backend {
            service_name = "bulk-quoting-service"
            service_port = 80
          }
          path = "/bulkQuotes"
        }
        path {
          backend {
            service_name = "${var.helm_mojaloop_release_name}-transaction-requests-service"
            service_port = 80
          }
          path = "/transactionRequests"
        }
        path {
          backend {
            service_name = "${var.helm_mojaloop_release_name}-transaction-requests-service"
            service_port = 80
          }
          path = "/authorizations"
        }
      }
    }
  }
  provider   = kubernetes.k8s-gateway
  depends_on = [helm_release.mojaloop]
}
resource "helm_release" "mojaloop" {
  name       = var.helm_mojaloop_release_name
  repository = "http://mojaloop.io/helm/repo"
  chart      = "mojaloop"
  version    = var.helm_mojaloop_version
  namespace  = "mojaloop"
  timeout    = 800
  create_namespace = true
  values = [
    templatefile(split(".", var.helm_mojaloop_version)[0] == "12" ? "${path.module}/templates/values-lab-oss.yaml.tpl" : "${path.module}/templates/values-lab-oss-v13.yaml.tpl", local.oss_values),
    templatefile("${path.module}/templates/testing-tool-kit/mojaloop-simulator.yaml.tpl", local.oss_values),
    templatefile("${path.module}/templates/testing-tool-kit/ml-testing-toolkit.yaml.tpl", local.oss_values)
  ]
 
  provider = helm.helm-gateway

  depends_on = [module.fin-portal-iskm]
}
data "vault_generic_secret" "mojaloop_als_db_password" {
  path = "${var.stateful_resources[local.ml_als_resource_index].vault_credential_paths.pw_data.user_password_path_prefix}/account-lookup-db"
}
data "vault_generic_secret" "mojaloop_cl_db_password" {
  path = "${var.stateful_resources[local.ml_cl_resource_index].vault_credential_paths.pw_data.user_password_path_prefix}/central-ledger-db"
}
data "vault_generic_secret" "mojaloop_als_root_db_password" {
  path = "${var.stateful_resources[local.ml_als_resource_index].vault_credential_paths.pw_data.root_password_path_prefix}/account-lookup-db"
}
data "vault_generic_secret" "mojaloop_cl_root_db_password" {
  path = "${var.stateful_resources[local.ml_cl_resource_index].vault_credential_paths.pw_data.root_password_path_prefix}/central-ledger-db"
}
data "vault_generic_secret" "bulk_mongodb_password" {
  path = "${var.stateful_resources[local.bulk_mongodb_resource_index].vault_credential_paths.pw_data.user_password_path_prefix}/bulk-mongodb"
}
data "vault_generic_secret" "cep_mongodb_password" {
  path = "${var.stateful_resources[local.cep_mongodb_resource_index].vault_credential_paths.pw_data.user_password_path_prefix}/cep-mongodb"
}
locals {
  ml_als_resource_index = index(var.stateful_resources.*.resource_name, "account-lookup-db")
  ml_cl_resource_index = index(var.stateful_resources.*.resource_name, "central-ledger-db")
  bulk_mongodb_resource_index = index(var.stateful_resources.*.resource_name, "bulk-mongodb")
  cep_mongodb_resource_index = index(var.stateful_resources.*.resource_name, "cep-mongodb")
  mojaloop_kafka_resource_index = index(var.stateful_resources.*.resource_name, "mojaloop-kafka")
  oss_values = {
    env    = var.environment
    name   = var.client
    domain = data.terraform_remote_state.tenant.outputs.domain
    kafka_host = "${var.stateful_resources[local.mojaloop_kafka_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    account_lookup_db_password = data.vault_generic_secret.mojaloop_als_db_password.data.value
    account_lookup_db_user = "account_lookup"
    account_lookup_db_host = "${var.stateful_resources[local.ml_als_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    central_ledger_db_password = data.vault_generic_secret.mojaloop_cl_db_password.data.value
    central_ledger_db_user = "central_ledger"
    central_ledger_db_host = "${var.stateful_resources[local.ml_cl_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    central_settlement_db_password = data.vault_generic_secret.mojaloop_cl_db_password.data.value
    central_settlement_db_user = "central_ledger"
    central_settlement_db_host = "${var.stateful_resources[local.ml_cl_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    quoting_db_password = data.vault_generic_secret.mojaloop_cl_db_password.data.value
    quoting_db_user = "central_ledger"
    quoting_db_host = "${var.stateful_resources[local.ml_cl_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    finance_portal_db_password = data.vault_generic_secret.mojaloop_cl_db_password.data.value
    finance_portal_db_user = "central_ledger"
    finance_portal_db_host = "${var.stateful_resources[local.ml_cl_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    cep_mongodb_database = var.stateful_resources[local.cep_mongodb_resource_index].local_resource.mongodb_data.database_name
    cep_mongodb_user = var.stateful_resources[local.cep_mongodb_resource_index].local_resource.mongodb_data.user
    cep_mongodb_host = "${var.stateful_resources[local.cep_mongodb_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    cep_mongodb_pass = data.vault_generic_secret.cep_mongodb_password.data.value
    cl_mongodb_database = var.stateful_resources[local.bulk_mongodb_resource_index].local_resource.mongodb_data.database_name
    cl_mongodb_user = var.stateful_resources[local.bulk_mongodb_resource_index].local_resource.mongodb_data.user
    cl_mongodb_host = "${var.stateful_resources[local.bulk_mongodb_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    cl_mongodb_pass = data.vault_generic_secret.bulk_mongodb_password.data.value
    elasticsearch_url = "http://localhost" 
    kibana_url = "http://localhost"
    wso2is_host = "https://iskm.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
    portal_oauth_app_id = vault_generic_secret.mojaloop_fin_portal_backend_client_id.data.value
    portal_oauth_app_token = vault_generic_secret.mojaloop_fin_portal_backend_client_secret.data.value
    internal_ttk_enabled = var.internal_ttk_enabled
    internal_sim_enabled = var.internal_sim_enabled
    mojaloop_thirdparty_support_enabled = "false"
    storage_class_name = var.storage_class_name
    jws_signing_priv_key = data.terraform_remote_state.support-svcs.outputs.switch_jws_private_key
  }
  portal_users = [
    for user in var.finance_portal_users :
    {
      "username" = user.username
      "password" = vault_generic_secret.finance_portal_user_password[user.username].data.value
      "roles" = user.roles
    }
  ]
}

resource "kubernetes_secret" "central-ledger-mysql-secret" {
  metadata {
    name = "${var.helm_mojaloop_release_name}-centralledger-mysql"
    namespace = "mojaloop"
  }

  data = {
    mysql-root-password = data.vault_generic_secret.mojaloop_cl_root_db_password.data.value
    mysql-password = data.vault_generic_secret.mojaloop_cl_db_password.data.value
  }

  type = "opaque"
  provider = kubernetes.k8s-gateway
}

resource "kubernetes_secret" "account-lookup-mysql-secret" {
  metadata {
    name = "${var.helm_mojaloop_release_name}-account-lookup-mysql"
    namespace = "mojaloop"
  }

  data = {
    mysql-root-password = data.vault_generic_secret.mojaloop_als_root_db_password.data.value
    mysql-password = data.vault_generic_secret.mojaloop_als_db_password.data.value
  }

  type = "opaque"
  provider = kubernetes.k8s-gateway
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
      ELASTICSEARCH_HOST = data.terraform_remote_state.infrastructure.outputs.elasticsearch-services-private-fqdn,
      APM_HOST           = data.terraform_remote_state.infrastructure.outputs.apm-services-private-fqdn
    })
  ]
  set {
    name  = "config.kafka_host"
    value = "${var.helm_mojaloop_release_name}-kafka"
    type  = "string"
  }

  provider = helm.helm-gateway

  depends_on = [helm_release.mojaloop]
} */


resource "random_password" "mojaloop_fin_portal_backend_client_id" {
  length = 16
  special = true
  override_special = "_"
}

resource "vault_generic_secret" "mojaloop_fin_portal_backend_client_id" {
  path = "secret/mojaloop/finportalbackend/clientid"

  data_json = jsonencode({
    "value" = random_password.mojaloop_fin_portal_backend_client_id.result
  })
}

resource "random_password" "mojaloop_fin_portal_backend_client_secret" {
  length = 30
  special = true
  override_special = "_"
}

resource "vault_generic_secret" "mojaloop_fin_portal_backend_client_secret" {
  path = "secret/mojaloop/finportalbackend/clientsecret"

  data_json = jsonencode({
    "value" = random_password.mojaloop_fin_portal_backend_client_secret.result
  })
}

resource "random_password" "finance_portal_user_password" {
  for_each = {for user in var.finance_portal_users: user.username => user}
  length = 30
  special = true
  override_special = "_"
}

resource "vault_generic_secret" "finance_portal_user_password" {
  for_each = {for user in var.finance_portal_users: user.username => user}
  path = "secret/mojaloop/finportalbackend/${each.value.username}"
  data_json = jsonencode({
    "value" = random_password.finance_portal_user_password[each.value.username].result
  })
}

module "fin-portal-iskm" {
  source    = "git::https://github.com/mojaloop/wso2is-populate.git//terraform?ref=v2.0.4"
  wso2_host = "https://iskm.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}:443"
  admin_user = "admin"
  admin_password  = data.vault_generic_secret.ws02_admin_password.data.value
  auth_server_clientkey = vault_generic_secret.mojaloop_fin_portal_backend_client_id.data.value
  auth_server_clientsecret = vault_generic_secret.mojaloop_fin_portal_backend_client_secret.data.value
  wso2_oauth2_application_name = "portaloauth"
  portal_users = local.portal_users
}
