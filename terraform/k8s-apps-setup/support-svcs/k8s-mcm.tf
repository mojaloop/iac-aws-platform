resource "vault_mount" "root" {
  type                      = "pki"
  path                      = "pki-root-ca"
  default_lease_ttl_seconds = 31556952  # 1 years
  max_lease_ttl_seconds     = 157680000 # 5 years
  description               = "Root Certificate Authority"
}

resource "null_resource" "wait_for_iskm_readiness" {
  provisioner "local-exec" {
    command = "sleep 60"
  }
  depends_on = [module.iskm]
}

module "mcm-iskm-key-secret-gen" {
  source    = "git::https://github.com/mojaloop/iac-shared-modules.git//wso2/iskm-mcm?ref=v1.0.21-rolesfixed"
  iskm_fqdn = "iskm.${var.public_subdomain}"
  user      = "admin"
  password  = vault_generic_secret.wso2_admin_password.data.value
  iskm_rest_port = 443
  providers = {
    external = external.wso2-automation-iskm-mcm
  }
  depends_on = [null_resource.wait_for_iskm_readiness]
}

data "vault_generic_secret" "mcm_db_password" {
  path = "${var.stateful_resources[local.mcm_resource_index].generate_secret_vault_base_path}/${var.stateful_resources[local.mcm_resource_index].resource_name}/password"
}

resource "helm_release" "mcm-connection-manager" {
  name       = "connection-manager"
  repository = "https://pm4ml.github.io/helm"
  chart      = "connection-manager"
  version    = var.helm_mcm_connection_manager_version
  namespace  = kubernetes_namespace.mcm.metadata[0].name
  create_namespace = true
  timeout    = 500

  values = [
    templatefile("${path.module}/templates/values-mcm.yaml.tpl", local.mcm_values)
  ]
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

  set {
    name  = "api.wso2TokenIssuer.cert.stringValue"
    value = module.iskm.iskm_cert
    type  = "string"
  }

  provider = helm.helm-main
}

locals {
  mcm_resource_index = index(var.stateful_resources.*.resource_name, "mcm-db")
  mcm_values = {
    db_password       = data.vault_generic_secret.mcm_db_password.data.value
    db_user           = var.stateful_resources[local.mcm_resource_index].local_resource.mysql_data.user
    db_schema         = var.stateful_resources[local.mcm_resource_index].local_resource.mysql_data.database_name
    db_port           = var.stateful_resources[local.mcm_resource_index].logical_service_port
    db_host           = "${var.stateful_resources[local.mcm_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
    totp_issuer       = var.mcm-totp-issuer
    mcm_public_fqdn   = "${var.mcm_name}.${var.public_subdomain}"
    iskm_private_fqdn = "iskm.${var.public_subdomain}"
    admin_pw          = vault_generic_secret.wso2_admin_password.data.value
    env_name          = var.environment
    env_cn            = var.public_subdomain
    env_o             = "Modusbox"
    env_ou            = "Infra"
    storage_class_name = var.storage_class_name
    k8s_vault_role    = vault_kubernetes_auth_backend_role.kubernetes-mcm.role_name
    vault_endpoint    = "http://vault.default.svc.cluster.local:8200"
    pki_base_domain   = var.public_subdomain
    service_account_name = kubernetes_service_account.vault-auth-mcm.metadata[0].name
    k8s_auth_path     = vault_auth_backend.kubernetes-gateway.path
    mcm_kv_secret_path = var.mcm_secret_path
    pki_path          = vault_mount.root.path
    dfsp_client_cert_bundle = "${var.onboarding_secret_name_prefix}_pm4mls"
    dfsp_internal_whitelist_secret = "${var.whitelist_secret_name_prefix}_pm4mls"
    dfsp_external_whitelist_secret = "${var.whitelist_secret_name_prefix}_fsps"
    pki_client_role = vault_pki_secret_backend_role.role-client-cert.name
    pki_server_role = vault_pki_secret_backend_role.role-server-cert.name
    server_cert_secret_name = var.vault-certman-secretname
    server_cert_secret_namespace = kubernetes_namespace.wso2.metadata[0].name
    switch_domain        = var.public_subdomain
    ingress_class        = "nginx-ext"
  }
}

resource "kubernetes_namespace" "mcm" {
  metadata {
   name = var.mcm_namespace
  }
  provider = kubernetes.k8s-main
}
resource "kubernetes_service_account" "vault-auth-mcm" {
  metadata {
    name      = "vault-auth-mcm"
    namespace = kubernetes_namespace.mcm.metadata[0].name
  }
  automount_service_account_token = true
  provider                        = kubernetes.k8s-main
}


resource "kubernetes_role" "wso2-secret-update" {
  metadata {
    name = "wso2-secret-update"
    namespace = kubernetes_namespace.wso2.metadata[0].name
  }
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
  provider = kubernetes.k8s-main
}
resource "kubernetes_role_binding" "mcm-wso2-secret-update-binding" {
  metadata {
    name      = "mcm-wso2-secret-update-binding"
    namespace = kubernetes_namespace.wso2.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.wso2-secret-update.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault-auth-mcm.metadata[0].name
    namespace = kubernetes_namespace.mcm.metadata[0].name
  }
  provider = kubernetes.k8s-main
}

resource "vault_kubernetes_auth_backend_role" "kubernetes-mcm" {
  backend                          = vault_auth_backend.kubernetes-gateway.path
  role_name                        = "kubernetes-mcm-role"
  bound_service_account_names      = [kubernetes_service_account.vault-auth-mcm.metadata[0].name]
  bound_service_account_namespaces = [kubernetes_namespace.mcm.metadata[0].name]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.mcm-policy.name]
}

resource "vault_policy" "mcm-policy" {
  name = "mcm_policy"

  policy = <<EOT
path "${var.whitelist_secret_name_prefix}*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/onboarding_*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "pki-root-ca/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "${var.mcm_secret_path}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

EOT
}
