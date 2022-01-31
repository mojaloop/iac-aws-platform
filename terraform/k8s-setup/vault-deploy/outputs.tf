output "cert_man_secret_id" {
  description = "cert_man_secret_id"
  value       = aws_iam_access_key.route53-external-dns.id
}

output "cert_man_secret_key" {
  value       = aws_iam_access_key.route53-external-dns.secret
  sensitive   = true
  description = "cert_man_secret_key"
}

output "int_wildcard_cert_sec_name" {
  description = "wildcard cert for internal ops tls"
  value       = var.int_wildcard_cert_sec_name
}

output "keycloak_secret_key" {
  value       = random_password.keycloak_pw.result
  sensitive   = true
  description = "keycloak admin pw"
}

output "keycloak_namespace" {
  description = "namespace keycloak is deployed to"
  value       = kubernetes_namespace.keycloak.metadata[0].name
}