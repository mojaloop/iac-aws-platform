resource "kubernetes_namespace" "wso2" {
  metadata {
   name = var.wso2_namespace
  }
  provider = kubernetes.k8s-main
}
resource "kubernetes_service_account" "vault-auth-gateway" {
  metadata {
    name      = "vault-auth-gateway"
    namespace = kubernetes_namespace.wso2.metadata[0].name
  }
  automount_service_account_token = true
  provider                        = kubernetes.k8s-main
}
resource "kubernetes_role" "nginx-ext-cm-all" {
  metadata {
    name = "nginx-ext-cm-all"
    namespace = "nginx-ext"
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
  provider = kubernetes.k8s-main
}
resource "kubernetes_role_binding" "nginx-ext-cm-all-binding" {
  metadata {
    name      = "nginx-ext-cm-all-binding"
    namespace = "nginx-ext"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.nginx-ext-cm-all.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault-auth-gateway.metadata[0].name
    namespace = kubernetes_namespace.wso2.metadata[0].name
  }
  provider = kubernetes.k8s-main
}
resource "kubernetes_cluster_role_binding" "role-tokenreview-binding-vault" {
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
    namespace = kubernetes_namespace.wso2.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault-auth-mcm.metadata[0].name
    namespace = kubernetes_namespace.mcm.metadata[0].name
  }
  provider   = kubernetes.k8s-main
}

data "kubernetes_secret" "generated-vault-auth-gateway" {
  metadata {
    name      = kubernetes_service_account.vault-auth-gateway.default_secret_name
    namespace = kubernetes_namespace.wso2.metadata[0].name
  }
  provider   = kubernetes.k8s-main
  depends_on = [kubernetes_cluster_role_binding.role-tokenreview-binding-vault]
}

resource "vault_auth_backend" "kubernetes-gateway" {
  type = "kubernetes"
  path = var.kubernetes_auth_path
}

resource "vault_kubernetes_auth_backend_config" "kubernetes-gateway" {
  backend            = vault_auth_backend.kubernetes-gateway.path
  kubernetes_host    =  "https://${dependency.baseinfra.outputs.internal_load_balancer_dns}:6443"
  kubernetes_ca_cert = split(".", var.k8s_api_version)[1] > 18 ? null : data.kubernetes_secret.generated-vault-auth-gateway.data["ca.crt"]
  token_reviewer_jwt = split(".", var.k8s_api_version)[1] > 18 ? null : data.kubernetes_secret.generated-vault-auth-gateway.data.token
  issuer             = "https://kubernetes.default.svc.cluster.local"
  disable_iss_validation = split(".", var.k8s_api_version)[1] > 18 ? "false" : "true"
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

path "secret/onboarding_*" {
  capabilities = ["read", "list"]
}

path "pki-root-ca/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "kubernetes-gateway" {
  backend                          = vault_auth_backend.kubernetes-gateway.path
  role_name                        = "kubernetes-gateway-role"
  bound_service_account_names      = [kubernetes_service_account.vault-auth-gateway.metadata[0].name]
  bound_service_account_namespaces = [kubernetes_namespace.wso2.metadata[0].name]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.read-whitelist-addresses-gateway.name]
}

resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "certman-issuer" {
  backend        = vault_auth_backend.approle.path
  role_name      = "certman-issuer-role"
  token_ttl      = 3600
  token_policies = [vault_policy.read-whitelist-addresses-gateway.name]
}

resource "vault_approle_auth_backend_role_secret_id" "certman-issuer-secret-id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.certman-issuer.role_name
}

resource "kubernetes_secret" "certman-issuer-secret" {
  metadata {
    name = "certman-issuer-secret"
    namespace = var.cert_man_namespace
  }

  data = {
    secretId = vault_approle_auth_backend_role_secret_id.certman-issuer-secret-id.secret_id
  }

  type = "opaque"
  provider = kubernetes.k8s-main
}

/* resource "kubernetes_secret" "client-cert-tls-ca" {
  metadata {
    name = "client-cert-tls-ca"
    namespace = kubernetes_namespace.wso2.metadata[0].name
  }

  data = {
    "ca.crt" = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
    "tls.key" = ""
    "tls.crt" = ""
  }

  type = "kubernetes.io/tls"
  provider = kubernetes.k8s-main
} */

resource "kubernetes_manifest" "vault-issuer-root" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      name = var.cert_man_vault_cluster_issuer_name
    }

    spec = {
      vault = {
        server = "http://vault.default.svc.cluster.local:8200"
        path = "pki-root-ca/sign/${vault_pki_secret_backend_role.role-server-cert.name}"
        auth = {
          appRole = {
            path = "approle"
            roleId = vault_approle_auth_backend_role.certman-issuer.role_id
            secretRef = {
              name = kubernetes_secret.certman-issuer-secret.metadata[0].name
              key = "secretId"
            }
          }
          /* kubernetes = {
            mountPath = "v1/auth/${var.kubernetes_auth_path}"
            role = kubernetes_service_account.vault-cert-manager.metadata[0].name
            secretRef = {
              name = kubernetes_service_account.vault-cert-manager.default_secret_name
              key = "token"
            }
          } */
        }
      }
    }
  }
  provider = kubernetes.k8s-main
}

resource "vault_pki_secret_backend_role" "role-server-cert" {
  backend            = vault_mount.root.path
  name               = "server-cert-role"
  allowed_domains    = [trimsuffix(dependency.baseinfra.outputs.private_subdomain, "."), trimsuffix(dependency.baseinfra.outputs.public_subdomain, "."), "wso2.svc.cluster.local"]
  allow_subdomains   = true
  allow_glob_domains = false
  allow_any_name     = false
  enforce_hostnames  = true
  allow_ip_sans      = true
  server_flag        = true
  client_flag        = false
  ou                 = ["Infrastructure Team"]
  organization       = ["ModusBox"]
  key_bits           = 2048
  # 2 years
  max_ttl  = 2592000
  ttl      = 2592000
  no_store = true
  require_cn = false
}

resource "vault_pki_secret_backend_role" "role-client-cert" {
  backend            = vault_mount.root.path
  name               = "client-cert-role"
  allowed_domains    = [dependency.baseinfra.outputs.private_subdomain, trimsuffix(dependency.baseinfra.outputs.public_subdomain, ".")]
  allow_subdomains   = true
  allow_glob_domains = false
  allow_bare_domains = true # needed for email address verification
  allow_any_name     = false
  enforce_hostnames  = true
  allow_ip_sans      = true
  server_flag        = false
  client_flag        = true
  ou                 = ["Infrastructure Team"]
  organization       = ["ModusBox"]
  key_bits           = 2048
  # 2 years
  max_ttl  = 2592000
  ttl      = 2592000
  no_store = true
  require_cn = false
}

resource "kubectl_manifest" "vault-tls-cert" {
    yaml_body = templatefile("${path.module}/templates/vault-cert.yaml.tpl", {
      domain_name = "extgw-data.${dependency.baseinfra.outputs.public_subdomain}"
      secret_name = var.vault-certman-secretname
      issuer_name = kubernetes_manifest.vault-issuer-root.manifest.metadata.name})
    override_namespace = kubernetes_namespace.wso2.metadata[0].name
    provider = kubectl.k8s-main
}