output "cert_man_secret_id" {
  description = "cert_man_secret_id"
  value       = aws_iam_access_key.route53-external-dns.id
}

output "cert_man_secret_key" {
  value       = aws_iam_access_key.route53-external-dns.secret
  sensitive   = true
  description = "cert_man_secret_key"
}