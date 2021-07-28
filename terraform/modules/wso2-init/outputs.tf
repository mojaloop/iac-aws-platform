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

output "storage_class" {
  description = "Storage Class for EBS"
  value = kubernetes_storage_class.wso2
}

output "efs_helm_release_name" {
  description = "Name of EFS Helm release"
  value = helm_release.efs-setup.name
}

output "mysql_helm_release_name" {
  description = "name of Mysql Helm release"
  value = helm_release.mysql.name
} 
