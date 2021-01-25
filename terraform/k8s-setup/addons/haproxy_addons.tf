resource "null_resource" "deploy-simulator-server-certificates" {
  for_each = toset(var.simulator_names)

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_addons_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = "${vault_pki_secret_backend_cert.simulators-server[each.value].certificate}\n${vault_pki_secret_backend_cert.simulators-server[each.value].ca_chain}\n${vault_pki_secret_backend_cert.simulators-server[each.value].private_key}"
    destination = "/tmp/${each.value}.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")}.bundle.server.crt"
  }

  provisioner "remote-exec" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_addons_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    inline = [
      "echo /etc/haproxy/certificates/${each.value}.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")}.bundle.server.crt ${each.value}.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")} | sudo tee -a /tmp/ssl_sims.lst",
    ]

  }
}

resource "null_resource" "deploy_simulators_client_ca_cert_to_addons" {

  for_each = toset(var.simulator_names)

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_addons_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = "${vault_pki_secret_backend_cert.simulators-personal-client[each.value].certificate}\n${vault_pki_secret_backend_root_sign_intermediate.intermediate_simulators[each.value].certificate}\n${data.terraform_remote_state.k8s-base.outputs.root_signed_intermediate_certificate}\n${data.terraform_remote_state.k8s-base.outputs.ca_cert_cert_pem}"
    destination = "/tmp/${each.value}.client.ca.crt"
  }
}

resource "null_resource" "deploy-haproxy-addons-cfg" {
  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_addons_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content = templatefile("${var.project_root_path}/terraform/k8s-setup/templates/confd.service.tpl", {
      vault_addr = "http://vault.${data.terraform_remote_state.infrastructure.outputs.private_subdomain}"
      //vault_token = vault_token.haproxy-vault-token.client_token
      // There is an issue with the token. It seems to be expiring (should be automatically renewed). Using root token for testing purposes
      vault_token = jsondecode(file("${var.project_root_path}/vault_seal_key"))["root_token"]
    })
    destination = "/tmp/confd.service"
  }

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_addons_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = file("${var.project_root_path}/terraform/k8s-setup/assets/whitelist_mcm.toml")
    destination = "/tmp/whitelist_mcm.toml"
  }

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_addons_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = file("${var.project_root_path}/terraform/k8s-setup/assets/whitelist_mcm.tmpl")
    destination = "/tmp/whitelist_mcm.tmpl"
  }

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_addons_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content = templatefile("${var.project_root_path}/terraform/k8s-setup/templates/haproxy-addons.cfg.tpl", {
      workernodes = zipmap(data.terraform_remote_state.infrastructure.outputs.addons_k8s_worker_nodes_private_ip, data.terraform_remote_state.infrastructure.outputs.addons_k8s_worker_nodes_private_dns)
      mcm         = data.terraform_remote_state.infrastructure.outputs.mcm_fqdn
      prom        = data.terraform_remote_state.infrastructure.outputs.prometheus-add-ons-private-fqdn
      pm4ml       = data.terraform_remote_state.infrastructure.outputs.pm4ml_fqdn
    })
    destination = "/tmp/haproxy.cfg"
  }

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_addons_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = "0.0.0.0/0"
    destination = "/tmp/whitelist"
  }

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_addons_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = "0.0.0.0/0"
    destination = "/tmp/whitelist_mcm"
  }

  provisioner "remote-exec" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_addons_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    inline = [
      "sudo apt update",
      "sudo apt install -y haproxy",
      "sudo curl -LO  https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64",
      "sudo cp confd-0.16.0-linux-amd64 /usr/bin/confd",
      "sudo chmod 0755 /usr/bin/confd",
      "sudo mkdir -p /etc/confd/conf.d/",
      "sudo mkdir -p /etc/confd/templates/",
      "sudo cp /tmp/*.toml /etc/confd/conf.d/",
      "sudo cp /tmp/*.tmpl /etc/confd/templates/",
      "sudo cp /tmp/confd.service /etc/systemd/system/",
      "sudo rm /tmp/*.toml /tmp/*.tmpl /tmp/confd.service",
      "sudo chown root:root /etc/systemd/system/confd.service",
      "sudo chmod 0600 /etc/systemd/system/confd.service",
      "sudo systemctl enable confd.service",
      "sudo service confd start",
      "sudo mkdir -p /etc/haproxy/certificates",
      "sudo cp /tmp/whitelist* /etc/haproxy/",
      "sudo cp /tmp/ssl_sims.lst /etc/haproxy/",
      "sudo cp /tmp/*.server.crt /etc/haproxy/certificates/",
      "sudo chmod 0640 /etc/haproxy/certificates/*.server.crt -R",
      "sudo cat /tmp/*.client.ca.crt | sudo tee  /etc/haproxy/certificates/ca_bundle.crt",
      "sudo cp /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg",
      "sudo systemctl enable rsyslog",
      "sudo systemctl enable haproxy",
      "sudo service rsyslog restart",
      "sudo service haproxy stop",
      "sudo killall -s SIGKILL -e haproxy",
      "sudo service haproxy start"
    ]

  }

  depends_on = [null_resource.deploy-simulator-server-certificates, null_resource.deploy_simulators_client_ca_cert_to_addons]
}
