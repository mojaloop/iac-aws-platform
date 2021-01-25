resource "tls_private_key" "wso2" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_cert_request" "wso2" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.wso2.private_key_pem

  dns_names = ["${var.hostname}.${var.public_domain_name}"]

  subject {
    common_name         = "${var.hostname}.${var.public_domain_name}"
    organization        = "Self Signed"
    country             = "US"
    organizational_unit = "infra team"
  }
}

resource "tls_locally_signed_cert" "wso2" {
  cert_request_pem   = tls_cert_request.wso2.cert_request_pem
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = var.root_private_key
  ca_cert_pem        = var.root_certificate

  validity_period_hours = 87659

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
    "data_encipherment",
  ]
}

resource "kubernetes_secret" "secrets" {
  metadata {
    name      = "wso2-am-ext"
    namespace = var.namespace
  }
  data = {
    "key.pem"     = tls_private_key.wso2.private_key_pem
    "cert.pem"    = tls_locally_signed_cert.wso2.cert_pem
    "root_ca.pem" = var.root_certificate
  }
  type = "Opaque"
}
