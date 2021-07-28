locals {
  tenant  = data.terraform_remote_state.tenant.outputs
  sim_ips = [for name in var.simulator_names : "${var.simulator_cidr_block},${local.tenant.wireguard_public_ip}/32,${local.tenant.wireguard_private_ip}/32,${data.aws_nat_gateway.default.public_ip}/32,${local.tenant.gitlab_ci_public_ip}/32"]
  hub_ips = [for block in var.hub_account_cidr_blocks : "${block},${local.tenant.wireguard_public_ip}/32,${local.tenant.wireguard_private_ip}/32,${data.aws_nat_gateway.default.public_ip}/32,${local.tenant.gitlab_ci_public_ip}/32"]
}

data "aws_nat_gateway" "default" {
  vpc_id = data.terraform_remote_state.tenant.outputs.vpc_id
}

resource "vault_generic_secret" "sim_whitelist" {
  path      = data.terraform_remote_state.k8s-base.outputs.sim_whitelist_secret_name
  data_json = jsonencode(merge(zipmap(var.simulator_names, local.sim_ips), zipmap(var.hub_account_names, local.hub_ips)))
}

resource "null_resource" "haproxy-wso2-bump-confd" {
  
  provisioner "remote-exec" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    inline = [   
      "sudo systemctl restart confd",
      "echo result is $?"
    ]

  }
  depends_on = [vault_generic_secret.sim_whitelist]
}