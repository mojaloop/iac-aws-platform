# This will be moved to its own set of files
locals {
  vault_addr = "http://vault.${data.terraform_remote_state.infrastructure.outputs.private_subdomain}"
}

provider "vault" {
  address = local.vault_addr
  token   = jsondecode(file("${var.project_root_path}/vault_seal_key"))["root_token"]
}

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
  provisioner "remote-exec" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    inline = [
      "sudo apt update",
      "sudo apt install -y haproxy",
      "sudo wget https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64",
      "sudo cp confd-0.16.0-linux-amd64 /usr/bin/confd",
      "sudo chmod 0755 /usr/bin/confd",
      "sudo mkdir -p /etc/confd/conf.d/",
      "sudo mkdir -p /etc/confd/templates/",
      "sudo cp /tmp/*.toml /etc/confd/conf.d/",
      "sudo cp /tmp/*.tmpl /etc/confd/templates/",
      "sudo cp /tmp/confd.service /etc/systemd/system/",
      "sudo cp /tmp/49-haproxy.conf /etc/rsyslog.d/49-haproxy.conf",
      "sudo chown root:root /etc/rsyslog.d/49-haproxy.conf",
      "sudo chown root:root /etc/systemd/system/confd.service",
      "sudo chmod 0600 /etc/systemd/system/confd.service",
      "sudo mkdir -p /etc/haproxy/certs",
      "sudo cp /tmp/*.crt /etc/haproxy/certs/",
      "sudo chmod 0640 -R /etc/haproxy/certs/",
      "sudo openssl dhparam -out /etc/haproxy/certs/dhparams.pem  1024",
      "sudo chown root:root -R /etc/haproxy/certs/",
      "sudo cp /tmp/haproxy.cfg /etc/haproxy/",
      "sudo chmod 0644 /etc/haproxy/haproxy.cfg",
      "sudo systemctl enable confd.service",
      "sudo systemctl start confd",
      "sudo systemctl restart rsyslog",
      "sudo systemctl stop haproxy",
      "sudo killall -s SIGKILL -e haproxy",
      "sudo systemctl start haproxy",
      "echo result is $?"
    ]
  }

  triggers = {
    vault_token = vault_token.haproxy-vault-token.id
  }
}

resource "vault_pki_secret_backend_cert" "haproxy-callback-cert" {
  depends_on = [vault_pki_secret_backend_role.role-server-cert, vault_pki_secret_backend_intermediate_set_signed.intermediate]

  backend = vault_mount.pki_int.path
  name    = vault_pki_secret_backend_role.role-server-cert.name

  common_name = "haproxy-callback.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.private_subdomain, ".")}"
}

resource "vault_pki_secret_backend_cert" "extgw" {
  depends_on = [vault_pki_secret_backend_role.role-server-cert, vault_pki_secret_backend_intermediate_set_signed.intermediate]

  backend = vault_mount.pki_int.path
  name    = vault_pki_secret_backend_role.role-server-cert.name

  common_name = "extgw.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")}"
}

resource "vault_pki_secret_backend_cert" "intgw" {
  depends_on = [vault_pki_secret_backend_role.role-server-cert, vault_pki_secret_backend_intermediate_set_signed.intermediate]

  backend = vault_mount.pki_int.path
  name    = vault_pki_secret_backend_role.role-server-cert.name

  common_name = "intgw.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.private_subdomain, ".")}"
}

resource "vault_pki_secret_backend_cert" "iskm" {
  depends_on = [vault_pki_secret_backend_role.role-server-cert, vault_pki_secret_backend_intermediate_set_signed.intermediate]

  backend = vault_mount.pki_int.path
  name    = vault_pki_secret_backend_role.role-server-cert.name

  common_name = "iskm.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.private_subdomain, ".")}"
}

resource "null_resource" "haproxy-wso2-calbacks" {
  provisioner "file" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = templatefile("${path.module}/templates/haproxy-callback-base.cfg.tpl", {})
    destination = "/tmp/haproxy.cfg"
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
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    content     = "${vault_pki_secret_backend_cert.haproxy-callback-cert.private_key}\n${vault_pki_secret_backend_cert.haproxy-callback-cert.certificate}\n${vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate}\n${tls_self_signed_cert.ca_cert.cert_pem}"
    destination = "/tmp/haproxy-callback.fullchain.crt"
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
      "sudo chmod 0640 /etc/haproxy/certificates",
      "sudo cp /tmp/haproxy-callback.fullchain.crt /etc/haproxy/certificates/",
      "sudo cp /tmp/49-haproxy.conf /etc/rsyslog.d/49-haproxy.conf",
      "sudo chown root:root /etc/rsyslog.d/49-haproxy.conf",
      "sudo systemctl restart rsyslog",
      "sudo systemctl stop haproxy",
      "sudo killall -s SIGKILL -e haproxy",
      "sudo systemctl start haproxy",
      "echo result is $?"
    ]
  }
  triggers = {
    vault_token = vault_token.haproxy-vault-token.id
  }
}

resource "vault_pki_secret_backend_role" "role-server-cert" {
  backend            = vault_mount.pki_int.path
  name               = "server-cert-role"
  allowed_domains    = [trimsuffix(data.terraform_remote_state.infrastructure.outputs.private_subdomain, "."), trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")]
  allow_subdomains   = true
  allow_glob_domains = false
  allow_any_name     = false
  enforce_hostnames  = true
  allow_ip_sans      = true
  server_flag        = true
  client_flag        = false
  ou                 = ["Infrastructure Team"]
  organization       = ["Infra"]
  key_bits           = 4096
  # 2 years
  max_ttl  = 63113904
  ttl      = 63113904
  no_store = true
}

resource "vault_pki_secret_backend_role" "role-client-cert" {
  backend            = vault_mount.pki_int.path
  name               = "client-cert-role"
  allowed_domains    = [data.terraform_remote_state.infrastructure.outputs.private_subdomain, trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")]
  allow_subdomains   = true
  allow_glob_domains = false
  allow_bare_domains = true # needed for email address verification
  allow_any_name     = false
  enforce_hostnames  = true
  allow_ip_sans      = true
  server_flag        = false
  client_flag        = true
  ou                 = ["Infrastructure Team"]
  organization       = ["Infra"]
  key_bits           = 4096
  # 2 years
  max_ttl  = 63113904
  ttl      = 63113904
  no_store = true
}

resource "helm_release" "deploy-gateway-nginx-ingress-controller" {
  namespace  = "kube-public"
  name       = "nginx-ingress"
  repository = "https://charts.helm.sh/stable"
  chart      = "nginx-ingress"
  version    = var.helm_nginx_version
  wait       = false

  set {
    name  = "controller.service.nodePorts.http"
    value = 30001
  }
  provider = helm.helm-gateway
}
