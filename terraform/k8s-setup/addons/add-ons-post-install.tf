resource "helm_release" "mysql-mcm" {
  name       = "mysql-mcm"
  repository = "https://charts.helm.sh/stable"
  chart      = "mysql"
  version    = var.helm_mysql_mcm_version
  namespace  = "mysql-mcm"

  values = [
    templatefile("${path.module}/templates/values-lab-mcm.yaml.tpl", local.mcm_values)
  ]
  provider = helm
}

module "mcm-iskm-key-secret-gen" {
  source    = "git::git@github.com:mojaloop/iac-shared-modules.git//wso2/iskm-mcm?ref=v0.0.2"
  iskm_fqdn = data.terraform_remote_state.infrastructure.outputs.iskm_private_fqdn
  user      = "admin"
  password  = local.wso2_admin_pw
}

resource "helm_release" "mcm-connection-manager" {
  name       = "connection-manager"
  repository = "https://modusintegration.github.io/mcm-helm/repo/"
  chart      = "connection-manager"
  version    = var.helm_mcm_connection_manager_version
  namespace  = "mcm"

  values = [
    templatefile("${path.module}/templates/values-lab-mcm.yaml.tpl", local.mcm_values)
  ]

  set {
    name  = "api.extraTLS.rootCert.enabled"
    value = "1"
  }
  set {
    name  = "api.extraTLS.rootCert.stringValue"
    value = data.terraform_remote_state.k8s-base.outputs.ca_cert_cert_pem
  }
  set {
    name  = "api.wso2TokenIssuer.cert.enabled"
    value = "1"
  }
  set {
    name  = "api.wso2TokenIssuer.cert.stringValue"
    value = data.terraform_remote_state.k8s-base.outputs.iskm_cert
  }
  set_string {
    name  = "api.oauth.enabled"
    value = "FALSE"
  }
  set {
    name  = "api.oauth.key"
    value = module.mcm-iskm-key-secret-gen.mcm-key
  }
  set {
    name  = "api.oauth.secret"
    value = module.mcm-iskm-key-secret-gen.mcm-secret
  }

  provider   = helm
  depends_on = [helm_release.mysql-mcm]
}

resource "null_resource" "create-mcm-env" {
  provisioner "local-exec" {
    command = <<EOF
      for i in `seq 1 15`; do \
      curl -w '\n' -f -i -X POST \
      -H 'content-type: application/json' \
      http://${data.terraform_remote_state.infrastructure.outputs.mcm_fqdn}:30000/api/environments \
      --data '{"name": "${data.terraform_remote_state.infrastructure.outputs.environment}","defaultDN": {"CN": "${data.terraform_remote_state.infrastructure.outputs.private_subdomain}","O": "Infra","OU": "MCM"}}' && exit 0; sleep 15; done; exit 1 
    EOF
  }
  depends_on = [helm_release.mcm-connection-manager]
}

locals {
  mcm_values = {
    password          = var.mcm-mysql-password
    root_password     = var.mcm-mysql-root-password
    totp_issuer       = var.mcm-totp-issuer
    mcm_public_fqdn   = data.terraform_remote_state.infrastructure.outputs.mcm_fqdn
    iskm_private_fqdn = data.terraform_remote_state.infrastructure.outputs.iskm_private_fqdn
  }
}
