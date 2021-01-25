
resource "null_resource" "haproxy-callback-client-simulators" {
  for_each = toset(var.simulator_names)
  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = "${vault_pki_secret_backend_cert.simulators-personal-client[each.value].private_key}\n${vault_pki_secret_backend_cert.simulators-personal-client[each.value].certificate}\n${vault_pki_secret_backend_root_sign_intermediate.intermediate_simulators[each.value].certificate}\n${data.terraform_remote_state.k8s-base.outputs.ca_cert_cert_pem}"
    destination = "/tmp/${each.value}.client.fullchain.crt"
  }
}

resource "null_resource" "deploy-simulators-ca-bundles" {
  for_each = toset(var.simulator_names)

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = vault_pki_secret_backend_cert.simulators-server[each.value].ca_chain
    destination = "/tmp/${each.value}_server_ca.crt"
  }
}

resource "null_resource" "haproxy-wso2-calbacks" {
  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content = templatefile("${var.project_root_path}/terraform/k8s-setup/templates/haproxy-callback.cfg.tpl", {
      backends   = aws_route53_record.simulators-public,
      env_domain = data.terraform_remote_state.infrastructure.outputs.public_subdomain,
      sdks       = var.sdks
    })
    destination = "/tmp/haproxy.cfg"
  }

  provisioner "remote-exec" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    inline = [
      "set -x",
      "sudo apt update",
      "sudo apt install -y haproxy",
      "sudo cp /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg",
      "sudo chmod 0640 /etc/haproxy/haproxy.cfg",
      "sudo mkdir -p /etc/haproxy/certificates",
      "sudo cp /tmp/*.client.fullchain.crt /etc/haproxy/certificates/",
      "sudo cp /tmp/*_server_ca.crt /etc/haproxy/certificates/",
      "sudo cp /tmp/*_server_ca.pem /etc/haproxy/certificates/",
      "sudo mkdir -p /tmp/haproxy_chroot",
      "sudo chmod 0640 /etc/haproxy/certificates",
      "sudo cp /tmp/haproxy-callback.fullchain.crt /etc/haproxy/certificates/",
      "sudo service rsyslog restart",
      "sudo service haproxy stop",
      "sudo killall -s SIGKILL -e haproxy",
      "sudo service haproxy start"
    ]

  }
  depends_on = [null_resource.deploy-simulators-ca-bundles, null_resource.haproxy-callback-client-simulators]
}
