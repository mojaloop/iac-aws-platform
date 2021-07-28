resource "null_resource" "haproxy-wso2-callbacks" {
  
  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    source      = "${path.module}/assets/49-haproxy.conf"
    destination = "/tmp/49-haproxy.conf"
  }
  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = "${vault_pki_secret_backend_cert.haproxy-callback-cert.private_key}\n${vault_pki_secret_backend_cert.haproxy-callback-cert.certificate}\n${vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate}\n${tls_self_signed_cert.ca_cert.cert_pem}"
    destination = "/tmp/haproxy-callback.fullchain.crt"
  }

  /* provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
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
  } */
  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }

    content = templatefile("${var.project_root_path}/terraform/k8s-setup/templates/filebeat.yml.tpl", {
      elasticsearch_endpoint = "${data.terraform_remote_state.infrastructure.outputs.elasticsearch-services-private-fqdn}:30000"
    })
    destination = "/tmp/filebeat.yml"
  }
  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = vault_approle_auth_backend_role_secret_id.callback-haproxy-secret-id.secret_id
    destination = "/tmp/secid.cfg"
  }
  
  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = vault_approle_auth_backend_role.callback-haproxy.role_id
    destination = "/tmp/roleid.cfg"
  }

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = file("${path.module}/assets/genfilesfromyaml.sh")
    destination = "/tmp/genfilesfromyaml.sh"
  }

 provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = file("${path.module}/assets/posthaproxygen.sh")
    destination = "/tmp/posthaproxygen.sh"
 }
 provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = file("${path.module}/assets/postcertgen.sh")
    destination = "/tmp/postcertgen.sh"
 }
 provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = templatefile("${path.module}/templates/haproxy-callback.cfg.ctmpl.tpl", {
      secret_path = var.onboarding_secret_name_prefix
    })
    destination = "/tmp/haproxy.cfg.ctmpl"
  }
  
  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = templatefile("${path.module}/templates/getkeys_from_vault.ctmpl.tpl", {
      secret_path = var.onboarding_secret_name_prefix
    })
    destination = "/tmp/getkeys_from_vault.ctmpl"
  }
  
  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = templatefile("${path.module}/templates/vault.service.tpl", {
      vault_config = "/etc/vault/conf/vault_agent_callback_haproxy.hcl"
    })
    destination = "/tmp/vault.service"
  }

  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = templatefile("${path.module}/templates/vault_agent_callback_haproxy.hcl.tpl", {
      vault_address = local.vault_addr,
      role_id_file_path = "/etc/vault/conf/init/roleid.cfg",
      secret_id_file_path = "/etc/vault/conf/init/secid.cfg",
      keytemplate_file_path = "/etc/vault/conf/templates/keytemplate.ctmpl"
      haproxy_template_file_path = "/etc/vault/conf/templates/haproxy.cfg.ctmpl"
    })
    destination = "/tmp/vault_agent_callback_haproxy.hcl"
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
      "sudo add-apt-repository ppa:vbernat/haproxy-2.2 --yes",
      "sudo apt update",
      "sudo apt install -y haproxy unzip",
      "curl -L -o /tmp/vault.zip https://releases.hashicorp.com/vault/1.6.3/vault_1.6.3_linux_amd64.zip",
      "unzip -o /tmp/vault.zip -d /tmp",
      "sudo mv /tmp/vault /usr/bin",
      "curl -L -o /tmp/yq https://github.com/mikefarah/yq/releases/download/v4.6.1/yq_linux_amd64",
      "sudo chmod +x /tmp/yq",
      "sudo mv /tmp/yq /usr/bin",
      "sudo mkdir -p /etc/vault/conf/init/ /etc/vault/conf/templates/ /etc/vault/scripts/",
      "sudo mkdir -p /etc/haproxy/certificates",
      "sudo cp /tmp/genfilesfromyaml.sh /tmp/postcertgen.sh /tmp/posthaproxygen.sh /etc/vault/scripts/",
      "sudo chmod +x /etc/vault/scripts/*.sh",
      "sudo cp /tmp/roleid.cfg /etc/vault/conf/init",
      "sudo cp /tmp/secid.cfg /etc/vault/conf/init",
      "sudo cp /tmp/vault_agent_callback_haproxy.hcl /etc/vault/conf/",
      "sudo cp /tmp/getkeys_from_vault.ctmpl /etc/vault/conf/templates/keytemplate.ctmpl",
      "sudo cp /tmp/haproxy.cfg.ctmpl /etc/vault/conf/templates/haproxy.cfg.ctmpl",
      "sudo cp /tmp/vault.service /etc/systemd/system/",
      "sudo chown root:root /etc/systemd/system/vault.service",
      "sudo chmod 0600 /etc/systemd/system/vault.service",
      "sudo systemctl restart vault",
      "curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-oss-7.8.1-amd64.deb",
      "sudo dpkg -i filebeat-oss-7.8.1-amd64.deb",
      "sudo cp /tmp/filebeat.yml /etc/filebeat/filebeat.yml",
      "sudo filebeat modules enable haproxy",
      "sudo systemctl restart filebeat",
      /* "sudo cp /tmp/*.client.fullchain.crt /etc/haproxy/certificates/",
      "sudo cp /tmp/*_server_ca.crt /etc/haproxy/certificates/",
      "sudo cp /tmp/*_server_ca.pem /etc/haproxy/certificates/", */
      "sudo mkdir -p /tmp/haproxy_chroot",
      "sudo chmod 0640 /etc/haproxy/certificates",
      "sudo cp /tmp/haproxy-callback.fullchain.crt /etc/haproxy/certificates/",
      "sudo cp /tmp/49-haproxy.conf /etc/rsyslog.d/49-haproxy.conf",
      "sudo chown root:root /etc/rsyslog.d/49-haproxy.conf",
      /* "sudo cp /tmp/haproxy.cfg /etc/haproxy/", */
      /* "sudo chmod 0644 /etc/haproxy/haproxy.cfg", */
      /* "sudo wget https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64",
      "sudo cp confd-0.16.0-linux-amd64 /usr/bin/confd",
      "sudo chmod 0755 /usr/bin/confd",
      "sudo mkdir -p /etc/confd/conf.d/",
      "sudo mkdir -p /etc/confd/templates/",
      "sudo cp /tmp/*.toml /etc/confd/conf.d/",
      "sudo cp /tmp/*.tmpl /etc/confd/templates/",
      "sudo cp /tmp/confd.service /etc/systemd/system/",  
      "sudo chown root:root /etc/systemd/system/confd.service",
      "sudo chmod 0600 /etc/systemd/system/confd.service", */
      "sudo systemctl restart rsyslog haproxy",
      "sudo systemctl enable vault haproxy filebeat rsyslog",
      "echo result is $?"
    ]
  }
  triggers = {
    vault_token = vault_token.haproxy-vault-token.id
  }
}