locals {
  env_values = {
    db_host               = var.db_host
    db_port               = var.db_port
    db_user               = var.db_user
    db_password           = var.db_password
    keystore_password     = var.keystore_password
    mojaloop_jws_password = var.jws_password
    intgw                 = var.intgw_fqdn
    iskm                  = var.iskm_fqdn
    wso2_admin_pw         = var.wso2_admin_pw
    ingress_host          = var.intgw_fqdn
    token_ingress_host    = "token-${var.intgw_fqdn}"
  }
}

resource "helm_release" "app" {
  name         = "wso2-am-int"
  repository   = "https://mojaloop.github.io/wso2-helm-charts-simple/repo"
  chart        = "wso2-am"
  version      = "2.2.12"
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
  set {
    name  = "persistentVolume.storageClass"
    value = var.efs_storage_class_name
    type  = "string"
  }
}
