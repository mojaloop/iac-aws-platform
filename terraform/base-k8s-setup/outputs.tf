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

output "storage_class_name" {
  description = "storage class name"
  value       = var.storage_class_name
}