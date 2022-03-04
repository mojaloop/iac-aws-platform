output "root_private_key" {
  description = "Private key for root CA"
  value = tls_private_key.root_ca_private_key.private_key_pem
}

output "root_certificate" {
  description = "Self signed root CA"
  value = tls_self_signed_cert.root_ca_ssc.cert_pem
}
