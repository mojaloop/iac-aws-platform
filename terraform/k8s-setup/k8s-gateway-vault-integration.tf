#create security related elements in current cluster
locals {
  #kube_master_url = yamldecode(file("${var.project_root_path}/admin-gateway.conf"))["clusters"].cluster[0].server
  kube_master_url = "https://${data.terraform_remote_state.infrastructure.outputs.gateway_k8s_master_nodes_private_ip[0]}:6443"
}

resource "kubernetes_service_account" "vault-auth-gateway" {
  metadata {
    name      = "vault-auth-gateway"
    namespace = var.wso2_namespace
  }
  automount_service_account_token = true
  provider                        = kubernetes.k8s-gateway
  depends_on = [module.wso2_init]
}

resource "kubernetes_secret" "vault-auth-gateway" {
  metadata {
    name      = "vault-auth-gateway"
    namespace = var.wso2_namespace
    annotations = {
      "kubernetes.io/service-account.name" = "vault-auth-gateway"
    }
  }
  type       = "kubernetes.io/service-account-token"
  provider   = kubernetes.k8s-gateway
  depends_on = [kubernetes_service_account.vault-auth-gateway]
}

resource "kubernetes_cluster_role_binding" "role-tokenreview-binding-gateway" {
  metadata {
    name = "role-tokenreview-binding-vault"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault-auth-gateway.metadata[0].name
    namespace = var.wso2_namespace
  }
  provider   = kubernetes.k8s-gateway
  depends_on = [kubernetes_secret.vault-auth-gateway]
}

data "kubernetes_secret" "generated-vault-auth-gateway" {
  metadata {
    name      = kubernetes_service_account.vault-auth-gateway.metadata[0].name
    namespace = var.wso2_namespace
  }
  provider   = kubernetes.k8s-gateway
  depends_on = [kubernetes_cluster_role_binding.role-tokenreview-binding-gateway]
}

resource "vault_auth_backend" "kubernetes-gateway" {
  type = "kubernetes"
  path = "kubernetes-gateway"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes-gateway" {
  backend            = vault_auth_backend.kubernetes-gateway.path
  kubernetes_host    = local.kube_master_url
  kubernetes_ca_cert = data.kubernetes_secret.generated-vault-auth-gateway.data["ca.crt"]
  token_reviewer_jwt = data.kubernetes_secret.generated-vault-auth-gateway.data.token
  issuer             = "api"
  depends_on         = [data.kubernetes_secret.generated-vault-auth-gateway]
}

resource "vault_policy" "base-token-polcies" {
  name = "base-token-polcies"

  policy = <<EOT
path "auth/token/lookup-accessor" {
  capabilities = ["update"]
}

path "auth/token/revoke-accessor" {
  capabilities = ["update"]
}
EOT
}

resource "vault_policy" "read-whitelist-addresses-gateway" {
  name = "whitelist_read_policy"

  policy = <<EOT
path "${var.whitelist_secret_name_prefix}*" {
  capabilities = ["read", "list"]
}
EOT
}

resource "vault_token" "haproxy-vault-token" {
  policies  = [vault_policy.read-whitelist-addresses-gateway.name, vault_policy.base-token-polcies.name]
  renewable = true
}

resource "vault_kubernetes_auth_backend_role" "kubernetes-gateway" {
  backend                          = vault_auth_backend.kubernetes-gateway.path
  role_name                        = "kubernetes-gateway-role"
  bound_service_account_names      = [kubernetes_service_account.vault-auth-gateway.metadata[0].name]
  bound_service_account_namespaces = [var.wso2_namespace]
  token_ttl                        = 3600
  policies                         = [vault_policy.read-whitelist-addresses-gateway.name]
}

resource "helm_release" "vault-agent" {
  name       = "vault-agent"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.5.0"
  namespace  = "default"
  set {
    name  = "injector.externalVaultAddr"
    value = local.vault_addr
    type  = "string"
  }	  
  set {
    name  = "injector.authPath"
    value = "auth/${vault_auth_backend.kubernetes-gateway.path}"
    type  = "string"
  }
  provider = helm.helm-gateway
}