# Create a secret to store the aws secret key which is passed to the clusterissuer below
resource "kubernetes_secret" "certmanager-route53-credentials" {
  metadata {
    name = "certmanager-route53-credentials"
    namespace = var.cert_man_namespace
  }

  data = {
    secret-access-key = aws_iam_access_key.route53-external-dns.secret
  }

  type = "opaque"
  provider = kubernetes.k8s-gateway
  depends_on = [helm_release.cert-manager]
}
resource "helm_release" "issuer-crds" {
  name       = "issuer-crds"
  chart = "./k8s-manifests"
  namespace  = var.cert_man_namespace
  timeout    = 300
  provider = helm.helm-gateway
  set {
    name  = "letsencrypt.external_dns_iam_access_key"
    value = aws_iam_access_key.route53-external-dns.id
    type  = "string"
  }
  set {
    name  = "letsencrypt.region"
    value = var.region
    type  = "string"
  }
  set {
    name  = "letsencrypt.domain"
    value = data.terraform_remote_state.infrastructure.outputs.public_subdomain
    type  = "string"
  }
  set {
    name  = "letsencrypt.letsencrypt_server"
    value = var.letsencrypt_server == "production" ? "https://acme-v02.api.letsencrypt.org/directory" : "https://acme-staging-v02.api.letsencrypt.org/directory"
    type  = "string"
  }
  set {
    name  = "letsencrypt.letsencrypt_email"
    value = var.wso2_email
    type  = "string"
  }
  set {
    name  = "letsencrypt.secret_name"
    value = kubernetes_secret.certmanager-route53-credentials.metadata[0].name
    type  = "string"
  }
  set {
    name  = "letsencrypt.issuer_name"
    value = var.cert_man_letsencrypt_cluster_issuer_name
    type  = "string"
  }
  depends_on = [helm_release.cert-manager]
}

resource "time_sleep" "wait_90_seconds" {
  depends_on = [helm_release.issuer-crds]
  create_duration = "90s"
  destroy_duration = "90s"
}