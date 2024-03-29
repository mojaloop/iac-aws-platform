resource "vault_jwt_auth_backend" "gitlab-oidc" {
  description         = "terraform oidc auth backend"
  path                = "oidc"
  type                = "oidc"
  oidc_discovery_url  = "https://${var.gitlab_hostname}"
  oidc_client_id      = local.vault_oauth_app_client_id
  oidc_client_secret  = local.vault_oauth_app_client_secret
  bound_issuer        = "https://${var.gitlab_hostname}"
}

resource "vault_jwt_auth_backend_role" "techops-admin-oidc" {
  backend         = vault_jwt_auth_backend.gitlab-oidc.path
  role_name       = "techops-admin"
  token_policies  = [vault_policy.read-secrets.name]
  bound_audiences = [local.vault_oauth_app_client_id]
  oidc_scopes     = ["openid"]
  user_claim            = "sub"
  role_type             = "oidc"
  allowed_redirect_uris = ["https://vault.${var.public_subdomain}/ui/vault/auth/oidc/oidc/callback"]
  bound_claims  = {
      groups = local.gitlab_admin_group_name
  }
}

resource "vault_policy" "read-secrets" {
  name = "read_secrets_read_policy"

  policy = <<EOT

path "secret/*" {
  capabilities = ["read", "list"]
}

EOT
}

resource "kubernetes_cluster_role" "oidc-cluster-viewer" {
  metadata {
    name = "oidc-cluster-viewer"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods"]
    verbs      = ["get", "list", "watch"]
  }
  provider = kubernetes.k8s-main
}

resource "kubernetes_cluster_role_binding" "oidc-cluster-viewer-binding" {
  metadata {
    name = "oidc-cluster-viewer-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "oidc-cluster-viewer"
  }
  subject {
    kind      = "Group"
    name      = "tenant-viewers"
  }
  provider   = kubernetes.k8s-main
}

resource "kubernetes_cluster_role_binding" "oidc-cluster-admin-binding" {
  metadata {
    name = "oidc-cluster-admin-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "Group"
    name      = "tenant-admins"
  }
  provider   = kubernetes.k8s-main
}

data "local_sensitive_file" "grafana-oauth-app" {
  filename = "${path.module}/oauth-apps/oauth-app-grafana-${var.environment}.json"
}

data "local_sensitive_file" "vault-oauth-app" {
  filename = "${path.module}/oauth-apps/oauth-app-vault-${var.environment}.json"
}

locals {
  vault_oauth_app_client_id = jsondecode(data.local_sensitive_file.vault-oauth-app.content)["application_id"]
  vault_oauth_app_client_secret = jsondecode(data.local_sensitive_file.vault-oauth-app.content)["secret"]
  grafana_oauth_app_client_id = jsondecode(data.local_sensitive_file.grafana-oauth-app.content)["application_id"]
  grafana_oauth_app_client_secret = jsondecode(data.local_sensitive_file.grafana-oauth-app.content)["secret"]
  gitlab_admin_group_name = "tenant-admins"
}

