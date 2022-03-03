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
      cert_secret_name              = kubernetes_secret.haproxy-ssl-certificate-secret.metadata[0].name
    })
  ]
  provider = helm.helm-gateway
  depends_on = [kubernetes_config_map.vault-haproxy, helm_release.mcm-connection-manager]
}

resource "kubernetes_secret" "haproxy-ssl-certificate-secret" {
  metadata {
    name = "haproxy-ssl-certificate-secret"
    namespace = "wso2"
  }

  data = {
    "tls_cert.pem" = "${module.wso2_init.root_certificate}\n${module.wso2_init.root_private_key}"
  }

  type = "opaque"
  provider = kubernetes.k8s-gateway
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
      vault_secret_name             = "${var.onboarding_secret_name_prefix}_pm4mls"
      vault_k8sauth_backend         = vault_auth_backend.kubernetes-gateway.path
      haproxy_common_name           = "haproxy-callback.wso2.svc.cluster.local"
      k8s_version                   = var.k8s_api_version
      vault_server_role             = vault_pki_secret_backend_role.role-server-cert.name
      vault_pki_name                = vault_mount.root.path
    })
    "config-init.hcl" = templatefile("${path.module}/templates/vault-haproxy-init.hcl.tpl", {
      vault_role_name               = vault_kubernetes_auth_backend_role.kubernetes-gateway.role_name
      vault_secret_file_name        = "haproxy.conf"
      vault_secret_name             = "${var.onboarding_secret_name_prefix}_pm4mls"
      vault_k8sauth_backend         = vault_auth_backend.kubernetes-gateway.path
    })
  }
  provider = kubernetes.k8s-gateway
}
