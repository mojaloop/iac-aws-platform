locals {
  env_values = {
    db_host                = var.db_host
    db_port                = var.db_port
    db_user                = var.db_user
    db_password            = var.db_password
    keystore_password      = var.keystore_password
    iskm                   = var.iskm_fqdn
    iskm_internal          = "${var.wso2_iskm_helm_name}-${var.helm_deployment}"
    service_account_name   = var.service_account_name
    vault_role_name        = var.vault_role_name
    vault_secret_file_name = var.vault_secret_file_name
    vault_secret_name      = var.vault_secret_name
    vault_pm4ml_wl_secret_name = var.vault_pm4ml_wl_secret_name
    vault_pm4ml_wl_secret_file_name = var.vault_pm4ml_wl_secret_file_name
    wso2_admin_pw = var.wso2_admin_pw

    mgmt_int_host = "${var.hostname}-mgmt-int.${var.public_domain_name}"
    data_int_host = "${var.hostname}-data-int.${var.public_domain_name}"
    mgmt_ext_host = "${var.hostname}-mgmt.${var.public_domain_name}"
    data_ext_host = "${var.hostname}-data.${var.public_domain_name}"
    api_gw_host = "${var.hostname}-mgmt.${var.public_domain_name}"
    api_store_host = "${var.hostname}-mgmt.${var.public_domain_name}"
    api_pub_host = "${var.hostname}-mgmt.${var.public_domain_name}"
    namespace     = var.namespace
    data_ext_issuer_name       = var.data_ext_issuer_name
    ext_ingress_controller_name = var.ext_ingress_controller_name
    int_ingress_controller_name = var.int_ingress_controller_name
  }
}

resource "helm_release" "app" {
  name          = "wso2-am-ext"
  repository    = "https://mojaloop.github.io/wso2-helm-charts-simple/repo"
  chart         = "wso2-am"
  version       = "2.2.14"
  namespace     = var.namespace
  timeout       = 500
  force_update  = true
  create_namespace = true
  reuse_values  = true
  values = [
    templatefile("${path.module}/helm/values.yaml", local.env_values),
    templatefile("${path.module}/templates/env-values.yaml.tpl", local.env_values),
    templatefile("${path.module}/templates/annotations.yaml.tpl", local.env_values),
    templatefile("${path.module}/templates/pm4ml_annotations.yaml.tpl", local.env_values)
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
  set {
    name  = "externalServiceAccount.enabled"
    value = true
  }
  set {
    name  = "externalServiceAccount.serviceAccountName"
    value = var.service_account_name
    type  = "string"
  }
  set {
    name  = "persistentVolume.storageClass"
    value = var.efs_storage_class_name
    type  = "string"
  }
}
