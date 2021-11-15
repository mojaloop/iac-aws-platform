resource "null_resource" "haproxy-wso2" {
  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = "${vault_pki_secret_backend_cert.extgw.private_key}\n${vault_pki_secret_backend_cert.extgw.certificate}\n${vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate}\n${tls_self_signed_cert.ca_cert.cert_pem}"
    destination = "/tmp/extgw.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")}.fullchain.crt"
  }
  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    source      = "${path.module}/assets/49-haproxy.conf"
    destination = "/tmp/49-haproxy.conf"
  }
  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = "${vault_pki_secret_backend_cert.intgw.private_key}\n${vault_pki_secret_backend_cert.intgw.certificate}\n${vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate}\n${tls_self_signed_cert.ca_cert.cert_pem}"
    destination = "/tmp/intgw.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")}.fullchain.crt"
  }
  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = "${vault_pki_secret_backend_cert.iskm.private_key}\n${vault_pki_secret_backend_cert.iskm.certificate}\n${vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate}\n${tls_self_signed_cert.ca_cert.cert_pem}"
    destination = "/tmp/iskm.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")}.fullchain.crt"
  }
  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = "${acme_certificate.iskm_acme_certificate.private_key_pem}\n${acme_certificate.iskm_acme_certificate.certificate_pem}\n${acme_certificate.iskm_acme_certificate.issuer_pem}"
    destination = "/tmp/iskm.acme.crt"
  }
  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = "${vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate}\n${tls_self_signed_cert.ca_cert.cert_pem}"
    destination = "/tmp/CA.crt"
  }
  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content = templatefile("${path.module}/templates/haproxy-gateway.cfg.tpl", {

      workerservers = zipmap(data.terraform_remote_state.infrastructure.outputs.gateway_k8s_worker_nodes_private_ip, data.terraform_remote_state.infrastructure.outputs.gateway_k8s_worker_nodes_private_dns)

      masterservers = zipmap(data.terraform_remote_state.infrastructure.outputs.gateway_k8s_master_nodes_private_ip, data.terraform_remote_state.infrastructure.outputs.gateway_k8s_master_nodes_private_dns)
      extgw_host    = data.terraform_remote_state.infrastructure.outputs.extgw_public_fqdn
      intgw_host    = data.terraform_remote_state.infrastructure.outputs.intgw_private_fqdn
      iskm_host     = data.terraform_remote_state.infrastructure.outputs.iskm_private_fqdn
      iskmssl_host  = aws_route53_record.iskm-public-private.fqdn
    })
    destination = "/tmp/haproxy.cfg"
  }

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content = templatefile("${path.module}/templates/confd.service.tpl", {
      vault_addr = "http://vault.${data.terraform_remote_state.infrastructure.outputs.private_subdomain}"
      //vault_token = vault_token.haproxy-vault-token.client_token
      // There is an issue with the token. It seems to be expiring (should be automatically renewed). Using root token for testing purposes
      vault_token = jsondecode(file("${var.project_root_path}/vault_seal_key"))["root_token"]
    })
    destination = "/tmp/confd.service"
  }

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = file("${path.module}/assets/whitelist_intgw.toml")
    destination = "/tmp/whitelist_intgw.toml"
  }

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = file("${path.module}/assets/whitelist_intgw.tmpl")
    destination = "/tmp/whitelist_intgw.tmpl"
  }

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = file("${path.module}/assets/whitelist_extgw.toml")
    destination = "/tmp/whitelist_extgw.toml"
  }

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = file("${path.module}/assets/whitelist_extgw.tmpl")
    destination = "/tmp/whitelist_extgw.tmpl"
  }

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = file("${path.module}/assets/whitelist_iskm.toml")
    destination = "/tmp/whitelist_iskm.toml"
  }

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = file("${path.module}/assets/whitelist_iskm.tmpl")
    destination = "/tmp/whitelist_iskm.tmpl"
  }

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = file("${path.module}/assets/whitelist_priv.toml")
    destination = "/tmp/whitelist_priv.toml"
  }

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = file("${path.module}/assets/whitelist_priv.tmpl")
    destination = "/tmp/whitelist_priv.tmpl"
  }

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }

    content = templatefile("${var.project_root_path}/terraform/k8s-setup/templates/filebeat.yml.tpl", {
      elasticsearch_endpoint = "${data.terraform_remote_state.infrastructure.outputs.elasticsearch-services-private-fqdn}:30000"
    })
    destination = "/tmp/filebeat.yml"
  }

  provisioner "remote-exec" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    inline = [
      "sudo apt update",
      "sudo add-apt-repository ppa:vbernat/haproxy-2.2 --yes",
      "sudo apt update",
      "sudo apt install -y haproxy",
      "curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-oss-7.8.1-amd64.deb",
      "sudo dpkg -i filebeat-oss-7.8.1-amd64.deb",
      "sudo cp /tmp/filebeat.yml /etc/filebeat/filebeat.yml",
      "sudo filebeat modules enable haproxy",
      "sudo systemctl restart filebeat",
      "sudo wget https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64",
      "sudo cp confd-0.16.0-linux-amd64 /usr/bin/confd",
      "sudo chmod 0755 /usr/bin/confd",
      "sudo mkdir -p /etc/confd/conf.d/",
      "sudo mkdir -p /etc/confd/templates/",
      "sudo cp /tmp/*.toml /etc/confd/conf.d/",
      "sudo cp /tmp/*.tmpl /etc/confd/templates/",
      "sudo cp /tmp/confd.service /etc/systemd/system/",  
      "sudo chown root:root /etc/systemd/system/confd.service",
      "sudo chmod 0600 /etc/systemd/system/confd.service",
      "sudo systemctl restart confd",
      "sudo mkdir -p /etc/haproxy/certs",
      "sudo cp /tmp/*.crt /etc/haproxy/certs/",
      "sudo chmod 0640 -R /etc/haproxy/certs/",
      "sudo openssl dhparam -out /etc/haproxy/certs/dhparams.pem  1024",
      "sudo chown root:root -R /etc/haproxy/certs/",
      "sudo cp /tmp/49-haproxy.conf /etc/rsyslog.d/49-haproxy.conf",
      "sudo chown root:root /etc/rsyslog.d/49-haproxy.conf",
      "sudo cp /tmp/haproxy.cfg /etc/haproxy/",
      "sudo chmod 0644 /etc/haproxy/haproxy.cfg",
      "sudo systemctl restart rsyslog",
      "sudo systemctl restart haproxy",
      "sudo systemctl enable confd.service haproxy filebeat rsyslog",
      "echo result is $?"
    ]
  }

  triggers = {
    vault_token = vault_token.haproxy-vault-token.id
  }
  depends_on = [vault_generic_secret.whitelist_nat, vault_generic_secret.whitelist_gateway, vault_generic_secret.whitelist_vpn]
}
