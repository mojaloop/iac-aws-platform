resource "null_resource" "haproxy-callback-client-sdks" {
  provisioner "file" {
    connection {
      host        = var.haproxy_callback_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = "${vault_pki_secret_backend_cert.personal_client.private_key}\n${vault_pki_secret_backend_cert.personal_client.certificate}\n${vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate}\n${var.ca_cert_cert_pem}"
    destination = "/tmp/${var.name}.client.fullchain.crt"
  }
}

# Save the server ca for the sdk dsfps out to file for haproxy to be able to verify the dfsp server cert
resource "null_resource" "deploy-sdk-ca-bundles" {
  provisioner "file" {
    connection {
      host        = var.haproxy_callback_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }

    content     = "${vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate}\n${var.ca_cert_cert_pem}"
    destination = "/tmp/${var.name}_server_ca.pem"
  }
}
