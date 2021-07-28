resource "vault_mount" "root" {
  type                      = "pki"
  path                      = "pki-root-ca"
  default_lease_ttl_seconds = 31556952  # 1 years
  max_lease_ttl_seconds     = 157680000 # 5 years
  description               = "Root Certificate Authority"
}

resource "vault_pki_secret_backend_config_urls" "config_urls" {
  depends_on              = [vault_mount.root]
  backend                 = vault_mount.root.path
  issuing_certificates    = ["${local.vault_addr}/v1/pki/ca"]
  crl_distribution_points = ["${local.vault_addr}/v1/pki/crl"]
}

# Create a private key for use with the Root CA.
resource tls_private_key ca_key {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# This is a highly sensitive output of this process.
resource local_file private_key {
  sensitive_content = tls_private_key.ca_key.private_key_pem
  filename          = "${path.root}/output/root_ca/ca_key.pem"
  file_permission   = "0400"
}

# 
# Create a Self Signed Root Certificate Authority
#
resource tls_self_signed_cert ca_cert {
  private_key_pem = tls_private_key.ca_key.private_key_pem
  key_algorithm   = "RSA"
  subject {
    common_name         = "${var.environment} Root CA"
    organization        = "ModusBox"
    organizational_unit = "Infrastructure Team"
  }
  validity_period_hours = 175200
  allowed_uses = [
    "cert_signing",
    "crl_signing"
  ]
  is_ca_certificate = true
}

resource local_file ca_file {
  sensitive_content = tls_self_signed_cert.ca_cert.cert_pem
  filename          = "${path.root}/output/root_ca/ca_cert.pem"
  file_permission   = "0400"
}

resource local_file ca_pem_bundle {
  sensitive_content = "${tls_private_key.ca_key.private_key_pem}${tls_self_signed_cert.ca_cert.cert_pem}"
  filename          = "${path.root}/output/root_ca/ca_cert_key_bundle.pem"
  file_permission   = "0400"
}

resource "vault_pki_secret_backend_config_ca" "ca_config" {
  depends_on = [vault_mount.root, tls_private_key.ca_key]
  backend    = vault_mount.root.path
  pem_bundle = local_file.ca_pem_bundle.sensitive_content
}
