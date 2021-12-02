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

  depends_on = [module.wso2_init, module.fin-portal-iskm]
}

locals {
  oss_values = {
    env    = var.environment
    name   = var.client
    domain = data.terraform_remote_state.tenant.outputs.domain
    kafka  = var.kafka
    mysql_password = vault_generic_secret.mojaloop_mysql_password.data.value
    mysql_root_password = vault_generic_secret.mojaloop_mysql_root_password.data.value
    elasticsearch_url = "http://${data.terraform_remote_state.infrastructure.outputs.elasticsearch-services-private-fqdn}:30000" 
    kibana_url = "http://${data.terraform_remote_state.infrastructure.outputs.kibana-services-private-fqdn}:30000"
    wso2is_host = "https://${data.terraform_remote_state.infrastructure.outputs.iskm_private_fqdn}"
    portal_oauth_app_id = vault_generic_secret.mojaloop_fin_portal_backend_client_id.data.value
    portal_oauth_app_token = vault_generic_secret.mojaloop_fin_portal_backend_client_secret.data.value
    internal_ttk_enabled = var.internal_ttk_enabled
    internal_sim_enabled = var.internal_sim_enabled
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

resource "helm_release" "esp-mojaloop" {
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
}

resource "random_password" "mojaloop_mysql_password" {
  length = 16
  special = false
}

resource "vault_generic_secret" "mojaloop_mysql_password" {
  path = "secret/mojaloop/mysqlpassword"

  data_json = jsonencode({
    "value" = random_password.mojaloop_mysql_password.result
  })
}

resource "random_password" "mojaloop_mysql_root_password" {
  length = 16
  special = false
}

resource "vault_generic_secret" "mojaloop_mysql_root_password" {
  path = "secret/mojaloop/mysqlrootpassword"

  data_json = jsonencode({
    "value" = random_password.mojaloop_mysql_root_password.result
  })
}

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
  wso2_host = "https://${data.terraform_remote_state.infrastructure.outputs.iskm_private_fqdn}:9443"
  admin_user = "admin"
  admin_password  = vault_generic_secret.wso2_admin_password.data.value
  auth_server_clientkey = vault_generic_secret.mojaloop_fin_portal_backend_client_id.data.value
  auth_server_clientsecret = vault_generic_secret.mojaloop_fin_portal_backend_client_secret.data.value
  wso2_oauth2_application_name = "portaloauth"
  portal_users = local.portal_users
  depends_on = [null_resource.wait_for_iskm_readiness]
}
