output "helm_release_name" {
  description = "Name of Helm release"
  value = helm_release.app.name
}
output "fqdn" {
  description = "FQDN of iskm Service"
  value       = var.iskm_fqdn
}
output "iskm_cert" {
  description = "Cert of ISKM https"
  value       = tls_locally_signed_cert.wso2.cert_pem
}
output "iskm_status" {
  description = "status of ISKM helm install"
  value       = helm_release.app.status
}
