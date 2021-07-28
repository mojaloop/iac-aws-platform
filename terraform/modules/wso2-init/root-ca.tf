resource "tls_private_key" "root_ca_private_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "root_ca_ssc" {
  key_algorithm     = "RSA"
  private_key_pem   = tls_private_key.root_ca_private_key.private_key_pem
  is_ca_certificate = true

  subject {
    common_name         = "MBOX ACME Self Signed CA"
    organization        = "MBOX ACME Self Signed"
    organizational_unit = "modusbox infra team"
  }

  validity_period_hours = 87659

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
    "data_encipherment",
  ]
}
