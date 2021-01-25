output "root_private_key" {
  description = "Private key for root CA"
  value = tls_private_key.root_ca_private_key.private_key_pem
}

output "root_certificate" {
  description = "Self signed root CA"
  value = tls_self_signed_cert.root_ca_ssc.cert_pem
}

output "db_host" {
  description = "Hostname for WSO2 DB"
  value = var.db_host
}

output "k8s_namespace" {
  description = "Namespace to deploy WSO2 applications into"
  value = kubernetes_namespace.ns.metadata[0].name
}

output "storage_class" {
  description = "Storage Class for EBS"
  value = kubernetes_storage_class.wso2
}
