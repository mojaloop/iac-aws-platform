// Backend Dependencies

//// Ory Services
resource "helm_release" "keto" {
  name       = "keto"
  repository = "https://k8s.ory.sh/helm/charts"
  chart      = "keto"
  version    = var.helm_keto_version
  namespace  = "mojaloop"
  timeout    = 300

  values = [
    templatefile("${path.module}/templates/values-keto.yaml.tpl", {
      keto_db_password = data.vault_generic_secret.keto_db_password.data.value
      keto_db_user = var.stateful_resources[local.keto_resource_index].local_resource.mysql_data.user
      keto_db_host = "${var.stateful_resources[local.keto_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
      keto_db_database = var.stateful_resources[local.keto_resource_index].local_resource.mysql_data.database_name
    })
  ]
  provider = helm.helm-main
  depends_on = [helm_release.mojaloop]
}

resource "helm_release" "oathkeeper" {
  name       = "oathkeeper"
  repository = "https://k8s.ory.sh/helm/charts"
  chart      = "oathkeeper"
  version    = var.helm_oathkeeper_version
  namespace  = "mojaloop"
  timeout    = 300

  values = [  
    templatefile(split(".", var.k8s_api_version)[1] > 18 ? "${path.module}/templates/values-oathkeeper.yaml.tpl" : "${path.module}/templates/values-oathkeeper_pre_1_19.yaml.tpl", {
      wso2_host = "https://iskm.${var.public_subdomain}"
      wso2_admin_creds = base64encode("admin:${data.vault_generic_secret.ws02_admin_password.data.value}")
      portal_fqdn = "${var.bofportal_name}.${var.public_subdomain}"
    })
  ]
  provider = helm.helm-main
  depends_on = [helm_release.bof-rules]
}

resource "helm_release" "oathkeeper-maester" {
  name       = "oathkeeper-maester"
  repository = "https://k8s.ory.sh/helm/charts"
  chart      = "oathkeeper-maester"
  version    = var.helm_oathkeeper_version
  namespace  = "mojaloop"
  timeout    = 300
  skip_crds  = false

  values = [
    templatefile("${path.module}/templates/values-oathkeeper-maester.yaml.tpl", {
    })
  ]
  provider = helm.helm-main
  depends_on = [helm_release.mojaloop]
}

resource "helm_release" "kratos" {
  name       = "kratos"
  repository = "https://k8s.ory.sh/helm/charts"
  chart      = "kratos"
  version    = var.helm_kratos_version
  namespace  = "mojaloop"
  timeout    = 300

  values = [
    templatefile("${path.module}/templates/values-kratos.yaml.tpl", {
      wso2_host = "https://iskm.${var.public_subdomain}"
      portal_fqdn = "${var.bofportal_name}.${var.public_subdomain}"
      wso2_client_id = module.bizops-portal-iskm.consumer-key
      wso2_client_secret = module.bizops-portal-iskm.consumer-secret
      kratos_db_password = data.vault_generic_secret.kratos_db_password.data.value
      kratos_db_user = var.stateful_resources[local.kratos_resource_index].local_resource.mysql_data.user
      kratos_db_host = "${var.stateful_resources[local.kratos_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
      kratos_db_database = var.stateful_resources[local.kratos_resource_index].local_resource.mysql_data.database_name
    })
  ]
  provider = helm.helm-main
  depends_on = [helm_release.mojaloop]
}

// BOF consolidated chart

resource "helm_release" "bof" {
  name       = "bof"
  repository = "http://docs.mojaloop.io/charts/repo"
  chart      = "bof"
  version    = var.helm_bof_version
  devel      = true
  namespace  = "mojaloop"
  timeout    = 300
  force_update = true

  values = [
    templatefile("${path.module}/templates/values-bof.yaml.tpl", {
      wso2_host = "https://iskm.${var.public_subdomain}"
      portal_fqdn = "${var.bofportal_name}.${var.public_subdomain}"
      api_fqdn = "${var.bofapi_name}.${var.public_subdomain}"
      iamui_fqdn = "${var.bofiamui_name}.${var.public_subdomain}"
      transfersui_fqdn = "${var.boftransfersui_name}.${var.public_subdomain}"
      settlementsui_fqdn = "${var.bofsettlementsui_name}.${var.public_subdomain}"
      positionsui_fqdn = "${var.bofpositionsui_name}.${var.public_subdomain}"
      central_admin_host = "moja-centralledger-service"
      central_settlements_host = "moja-centralsettlement-service"
      account_lookup_service_host = "moja-account-lookup-service"
      sim_payer_backend_host = "moja-sim-payerfsp-backend"
      sim_payee_backend_host = "moja-sim-payeefsp-backend"
      kafka_host = "${var.stateful_resources[local.mojaloop_kafka_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
      mojaloop_reports_config = local.mojaloop_reports_config
      reporting_db_host = "${var.stateful_resources[local.ml_cl_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
      reporting_db_port = var.stateful_resources[local.central_ledger_index].logical_service_port
      reporting_db_user = var.stateful_resources[local.central_ledger_index].local_resource.mysql_data.user
      reporting_db_database = var.stateful_resources[local.central_ledger_index].local_resource.mysql_data.database_name
      reporting_db_secret_name = var.stateful_resources[local.central_ledger_index].generate_secret_name
      reporting_db_secret_key = "mysql-password"
      reporting_events_mongodb_secret_name = var.stateful_resources[local.rpt_mongodb_resource_index].generate_secret_name
      reporting_events_mongodb_host = "${var.stateful_resources[local.rpt_mongodb_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
      reporting_events_mongodb_user = var.stateful_resources[local.rpt_mongodb_resource_index].local_resource.mongodb_data.user
      reporting_events_mongodb_database = var.stateful_resources[local.rpt_mongodb_resource_index].local_resource.mongodb_data.database_name
      release_name = "bof"
      test_user_name = "test1"
      test_user_password = vault_generic_secret.bizops_portal_user_password["test1"].data.value
      report_tests_payer = "payerfsp"
      report_tests_payee = "payeefsp"
      report_tests_currency = var.ttk_test_currency2
    })
  ]
  provider = helm.helm-main
  depends_on = [helm_release.mojaloop, helm_release.kratos]
}

resource "kubernetes_secret" "wso2-is-admin-creds" {
  metadata {
    name = "wso2-is-admin-creds"
    namespace = "mojaloop"
  }

  data = {
    username = "admin"
    password = data.vault_generic_secret.ws02_admin_password.data.value
  }

  type = "kubernetes.io/basic-auth"
  provider = kubernetes.k8s-main
  depends_on = [helm_release.mojaloop]
}

resource "helm_release" "bof-rules" {
  name       = "bof-oathkeeper-rules"
  chart      = "${var.bof_custom_resources_dir}/oathkeeper-rules"
  namespace  = "mojaloop"
  timeout    = 300
  provider   = helm.helm-main
  force_update = true
  set {
    name  = "base_domain"
    value = var.public_subdomain
    type  = "string"
  }
  set {
    name  = "bof_release_name"
    value = "bof"
    type  = "string"
  }
  set {
    name  = "moja_release_name"
    value = "moja"
    type  = "string"
  }
  depends_on = [helm_release.oathkeeper-maester]
}

data "vault_generic_secret" "keto_db_password" {
  path = "${var.stateful_resources[local.keto_resource_index].generate_secret_vault_base_path}/${var.stateful_resources[local.keto_resource_index].resource_name}/password"
}

data "vault_generic_secret" "kratos_db_password" {
  path = "${var.stateful_resources[local.kratos_resource_index].generate_secret_vault_base_path}/${var.stateful_resources[local.kratos_resource_index].resource_name}/password"
}

locals {
  keto_resource_index = index(var.stateful_resources.*.resource_name, "keto-db")
  central_ledger_index = index(var.stateful_resources.*.resource_name, "central-ledger-db")
  kratos_resource_index = index(var.stateful_resources.*.resource_name, "kratos-db")
  rpt_mongodb_resource_index = index(var.stateful_resources.*.resource_name, "reporting-events-mongodb")
  mojaloop_reports_config = jsondecode(file("${path.module}/mojaloop-custom-reports/config.json"))
}

resource "kubernetes_ingress_v1" "kratos-public" {
  metadata {
    name      = "kratos-public"
    namespace = "mojaloop"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "${var.bofportal_name}.${var.public_subdomain}"
      http {
        path {
          backend {
            service {
              name = "kratos-public"
              port {
                name = "http"
              }
            }
          }
          path = "/kratos(/|$)(.*)"
        }
      }
    }
    tls {
      hosts = ["${var.bofportal_name}.${var.public_subdomain}"]
    }
  }
  provider   = kubernetes.k8s-main
  depends_on = [helm_release.kratos]
}
