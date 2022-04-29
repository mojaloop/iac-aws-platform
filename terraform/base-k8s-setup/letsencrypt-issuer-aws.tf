# Create a secret to store the aws secret key which is passed to the clusterissuer below
resource "kubectl_manifest" "lets-encrypt-issuer" {
    yaml_body = templatefile("${path.module}/templates/lets-cluster-issuer.yaml.tpl", {
      external_dns_iam_access_key = aws_iam_access_key.route53-external-dns.id
      region = var.region
      domain = dependency.baseinfra.outputs.public_subdomain
      letsencrypt_server = var.letsencrypt_server == "production" ? "https://acme-v02.api.letsencrypt.org/directory" : "https://acme-staging-v02.api.letsencrypt.org/directory"
      letsencrypt_email = var.wso2_email
      secret_name = kubernetes_secret.certmanager-route53-credentials.metadata[0].name
      issuer_name = var.cert_man_letsencrypt_cluster_issuer_name
    })
    override_namespace = var.cert_man_namespace
    provider = kubectl.k8s-main
    depends_on = [helm_release.cert-manager]
}


resource "kubectl_manifest" "lets-encrypt-wildcard-cert" {
    yaml_body = templatefile("${path.module}/templates/lets-wildcard-cert.yaml.tpl", {
      domain_name = dependency.baseinfra.outputs.public_subdomain
      secret_name = var.int_wildcard_cert_sec_name
      issuer_name = var.cert_man_letsencrypt_cluster_issuer_name})
    override_namespace = "default"
    provider = kubectl.k8s-main
    depends_on = [time_sleep.wait_90_seconds-issuer]
}

resource "time_sleep" "wait_90_seconds-issuer" {
  depends_on = [kubectl_manifest.lets-encrypt-issuer]
  create_duration = "90s"
  destroy_duration = "90s"
}
resource "time_sleep" "wait_90_seconds-cert" {
  depends_on = [kubectl_manifest.lets-encrypt-wildcard-cert]
  create_duration = "90s"
  destroy_duration = "90s"
}