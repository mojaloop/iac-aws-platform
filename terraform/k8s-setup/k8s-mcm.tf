resource "helm_release" "mysql-mcm" {
  name       = "mysql-mcm"
  repository = "https://charts.helm.sh/stable"
  chart      = "mysql"
  version    = var.helm_mysql_mcm_version
  namespace  = "mysql-mcm"
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/values-lab-mcm.yaml.tpl", local.mcm_values)
  ]
  provider = helm.helm-gateway
}

resource "null_resource" "wait_for_iskm_readiness" {
  provisioner "local-exec" {
    command = "sleep 60"
  }
  depends_on = [module.iskm, null_resource.haproxy-wso2]
}

module "mcm-iskm-key-secret-gen" {
  source    = "git::https://github.com/mojaloop/iac-shared-modules.git//wso2/iskm-mcm?ref=v1.0.21"
  iskm_fqdn = data.terraform_remote_state.infrastructure.outputs.iskm_private_fqdn
  user      = "admin"
  password  = vault_generic_secret.wso2_admin_password.data.value
  providers = {
    external = external.wso2-automation-iskm-mcm
  }
  depends_on = [null_resource.wait_for_iskm_readiness]
}

resource "helm_release" "mcm-connection-manager" {
  name       = "connection-manager"
  repository = "https://modusbox.github.io/helm"
  chart      = "connection-manager"
  version    = var.helm_mcm_connection_manager_version
  namespace  = "mcm"
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/values-lab-mcm.yaml.tpl", local.mcm_values)
  ]

  set {
    name  = "api.extraTLS.rootCert.stringValue"
    value = tls_self_signed_cert.ca_cert.cert_pem
    type  = "string"
  }
  set {
    name  = "api.wso2TokenIssuer.cert.stringValue"
    value = module.iskm.iskm_cert
    type  = "string"
  }
  set {
    name  = "api.oauth.key"
    value = module.mcm-iskm-key-secret-gen.mcm-key
    type  = "string"
  }
  set {
    name  = "api.oauth.secret"
    value = module.mcm-iskm-key-secret-gen.mcm-secret
    type  = "string"
  }

  provider = helm.helm-gateway
  depends_on = [helm_release.mysql-mcm]
}

locals {
  mcm_values = {
    password          = vault_generic_secret.mcm_mysql_password.data.value
    root_password     = vault_generic_secret.mcm_mysql_root_password.data.value
    totp_issuer       = var.mcm-totp-issuer
    mcm_public_fqdn   = data.terraform_remote_state.infrastructure.outputs.mcm_fqdn
    iskm_private_fqdn = data.terraform_remote_state.infrastructure.outputs.iskm_private_fqdn
    admin_pw          = vault_generic_secret.wso2_admin_password.data.value
    env_name          = data.terraform_remote_state.infrastructure.outputs.environment
    env_cn            = data.terraform_remote_state.infrastructure.outputs.mcm_fqdn
    env_o             = "Modusbox"
    env_ou            = "MCM"
  }
}

resource "random_password" "mcm_mysql_password" {
  length = 16
  special = false
}

resource "vault_generic_secret" "mcm_mysql_password" {
  path = "secret/mcm/mysqlpassword"

  data_json = jsonencode({
    "value" = random_password.mcm_mysql_password.result
  })
}

resource "random_password" "mcm_mysql_root_password" {
  length = 16
  special = false
}

resource "vault_generic_secret" "mcm_mysql_root_password" {
  path = "secret/mcm/mysqlrootpassword"

  data_json = jsonencode({
    "value" = random_password.mcm_mysql_root_password.result
  })
}
