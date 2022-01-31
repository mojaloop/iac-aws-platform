resource "kubernetes_namespace" "keycloak" {
  metadata {
   name = "keycloak"
  }
  provider = kubernetes.k8s-gateway
}

resource "helm_release" "keycloak" {
  name       = "keycloak"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "keycloak"
  version    = var.helm_keycloak_version
  namespace  = kubernetes_namespace.keycloak.metadata[0].name
  timeout    = 300
  create_namespace = true
  values = [
    templatefile("${path.module}/chart-values/values-keycloak.yaml.tpl", {
      ingress_class = "nginx-ext"
      keycloak_host = "keycloak.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
      existing_secretname = kubernetes_secret.local-wildcard-secret.metadata[0].name
      storage_class_name = var.ebs_storage_class_name
    })
  ]
  set {
    name  = "postgresql.postgresqlPassword"
    value = random_password.keycloak_pw.result
    type  = "string"
  }
  set {
    name  = "auth.adminPassword"
    value = random_password.keycloak_pw.result
    type  = "string"
  }
  provider = helm.helm-gateway
}

data "kubernetes_secret" "wildcard-secret" {
  metadata {
    name      = var.int_wildcard_cert_sec_name
    namespace = "default"
  }
  provider   = kubernetes.k8s-gateway
  depends_on = [time_sleep.wait_90_seconds]
}

resource "kubernetes_secret" "local-wildcard-secret" {
  metadata {
    name = "local-wildcard-secret"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }

  data = {
    "tls.crt" = data.kubernetes_secret.wildcard-secret.data["tls.crt"]
    "tls.key" = data.kubernetes_secret.wildcard-secret.data["tls.key"]
  }

  type = "kubernetes.io/tls"
  provider = kubernetes.k8s-gateway
}

resource "random_password" "keycloak_pw" {
  length = 16
  special = true
}