locals {
  env_values = {
    db_host               = var.db_host
    db_port               = var.db_port
    db_user               = var.db_user
    db_password           = var.db_password
    keystore_password     = var.keystore_password
    mojaloop_jws_password = var.jws_password
    iskm                  = var.iskm_fqdn
    wso2_admin_pw         = var.wso2_admin_pw
    mgmt_int_host = "${var.hostname}-mgmt-int.${var.public_domain_name}"
    data_int_host = "${var.hostname}-data-int.${var.public_domain_name}"
    api_gw_host = "${var.hostname}-mgmt-int.${var.public_domain_name}"
    api_store_host = "${var.hostname}-mgmt-int.${var.public_domain_name}"
    api_pub_host = "${var.hostname}-mgmt-int.${var.public_domain_name}"
    int_ingress_controller_name = var.int_ingress_controller_name
    storage_class_name = var.storage_class_name
  }
}

resource "helm_release" "app" {
  name         = "wso2-am-int"
  repository   = "https://mojaloop.github.io/wso2-helm-charts-simple/repo"
  chart        = "wso2-am"
  version      = "2.2.14"
  namespace    = var.namespace
  timeout      = 500
  force_update = true
  create_namespace = true
  values = [
    templatefile("${path.module}/helm/values.yaml", local.env_values),
    templatefile("${path.module}/templates/env-values.yaml.tpl", local.env_values)
  ]
  set {
    name  = "secret.externalSecretName"
    value = kubernetes_secret.secrets.metadata[0].name
    type  = "string"
  }
  set {
    name  = "configmap.externalConfigMapName"
    value = kubernetes_config_map.configs.metadata[0].name
    type  = "string"
  }
  set {
    name  = "binconfigmap.externalConfigMapName"
    value = kubernetes_config_map.binconfigs.metadata[0].name
    type  = "string"
  }
}
