resource "helm_release" "haproxy-callback" {
  name       = "haproxy-callback"
  repository = "https://mojaloop.github.io/haproxy-helm-charts/repo"
  chart      = "haproxy"
  version    = var.helm_haproxy_version
  namespace  = "wso2"
  timeout    = 150
  create_namespace = true
  values = [
    templatefile("${path.module}/templates/values-haproxy.yaml.tpl", {
      vault_role_name               = vault_kubernetes_auth_backend_role.kubernetes-gateway.role_name
      vault_secret_file_name        = "haproxy.conf"
      vault_secret_name             = "secret/onboarding_pm4mls"
      service_account_name          = kubernetes_service_account.vault-auth-gateway.metadata[0].name
    })
  ]
  provider = helm.helm-gateway
  depends_on = [kubernetes_config_map.vault-haproxy]
}

resource "kubernetes_config_map" "vault-haproxy" {
  metadata {
    name = "vault-haproxy"
    namespace  = "wso2"
  }

  data = {
    "config.hcl" = templatefile("${path.module}/templates/vault-haproxy.hcl.tpl", {
      vault_role_name               = vault_kubernetes_auth_backend_role.kubernetes-gateway.role_name
      vault_secret_file_name        = "haproxy.conf"
      vault_secret_name             = "secret/onboarding_pm4mls"
      vault_k8sauth_backend         = vault_auth_backend.kubernetes-gateway.path
      haproxy_common_name           = "haproxy-callback.wso2.svc.cluster.local"
      k8s_version                   = var.k8s_api_version
    })
    "config-init.hcl" = templatefile("${path.module}/templates/vault-haproxy-init.hcl.tpl", {
      vault_role_name               = vault_kubernetes_auth_backend_role.kubernetes-gateway.role_name
      vault_secret_file_name        = "haproxy.conf"
      vault_secret_name             = "secret/onboarding_pm4mls"
      vault_k8sauth_backend         = vault_auth_backend.kubernetes-gateway.path
    })
  }
  provider = kubernetes.k8s-gateway
}
