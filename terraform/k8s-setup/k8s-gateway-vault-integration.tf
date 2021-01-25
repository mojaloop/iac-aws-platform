#create security related elements in current cluster
locals {
  vault_address = "http://vault.${data.terraform_remote_state.infrastructure.outputs.private_subdomain}"
  #kube_master_url = yamldecode(file("${var.project_root_path}/admin-gateway.conf"))["clusters"].cluster[0].server
  kube_master_url = "https://${data.terraform_remote_state.infrastructure.outputs.gateway_k8s_master_nodes_private_ip[0]}:6443"
}

resource "kubernetes_service_account" "vault-auth-gateway" {
  metadata {
    name      = "vault-auth-gateway"
    namespace = module.wso2_init.k8s_namespace
  }
  automount_service_account_token = true
  provider                        = kubernetes.k8s-gateway
}

resource "kubernetes_secret" "vault-auth-gateway" {
  metadata {
    name      = "vault-auth-gateway"
    namespace = module.wso2_init.k8s_namespace
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
    namespace = module.wso2_init.k8s_namespace
  }
  provider   = kubernetes.k8s-gateway
  depends_on = [kubernetes_secret.vault-auth-gateway]
}

data "kubernetes_secret" "generated-vault-auth-gateway" {
  metadata {
    name      = kubernetes_service_account.vault-auth-gateway.metadata[0].name
    namespace = module.wso2_init.k8s_namespace
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

resource "vault_policy" "read-whitelist-addresses-gateway" {
  name = "whitelist_read_policy"

  policy = <<EOT
path "${var.whitelist_secret_name_prefix}*" {
  capabilities = ["read", "list"]
}
EOT
}

resource "vault_token" "haproxy-vault-token" {
  policies  = [vault_policy.read-whitelist-addresses-gateway.name]
  renewable = true
}

resource "vault_kubernetes_auth_backend_role" "kubernetes-gateway" {
  backend                          = vault_auth_backend.kubernetes-gateway.path
  role_name                        = "kubernetes-gateway-role"
  bound_service_account_names      = [kubernetes_service_account.vault-auth-gateway.metadata[0].name]
  bound_service_account_namespaces = [module.wso2_init.k8s_namespace]
  ttl                              = 3600
  policies                         = [vault_policy.read-whitelist-addresses-gateway.name]
}

resource "null_resource" "get-helm-chart" {
  triggers = {
    id = uuid()
  }
  provisioner "local-exec" {
    command = <<EOF
      export KUBECONFIG=${var.project_root_path}/admin-gateway.conf && curl -LJ -o ${var.project_root_path}/helm-chart-v0.5.0.tar.gz https://github.com/hashicorp/vault-helm/archive/v0.5.0.tar.gz && helm upgrade --install --set injector.authPath=auth/${vault_auth_backend.kubernetes-gateway.path} --set injector.externalVaultAddr=${local.vault_address} vault ${var.project_root_path}/helm-chart-v0.5.0.tar.gz
    EOF
  }
}
