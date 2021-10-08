locals {
  #tenant  = data.terraform_remote_state.tenant.outputs
  #sim_ips = [for name in var.simulator_names : "${var.simulator_cidr_block},${local.tenant.wireguard_public_ip}/32,${local.tenant.wireguard_private_ip}/32,${data.aws_nat_gateway.default.public_ip}/32,${local.tenant.gitlab_ci_public_ip}/32"]
  #hub_ips = [for block in var.hub_account_cidr_blocks : "${block},${local.tenant.wireguard_public_ip}/32,${local.tenant.wireguard_private_ip}/32,${data.aws_nat_gateway.default.public_ip}/32,${local.tenant.gitlab_ci_public_ip}/32"]
  
  sim_whitelist = {
    for name in var.simulator_names :
    name => join(",", [for natip in var.pm4ml_nat_ips : "${natip}/32"])
  }
  internal_pm4ml_whitelist = {
    for pm4ml_config in var.internal_pm4ml_configs :
    pm4ml_config.DFSP_NAME => join(",", [for natip in var.pm4ml_nat_ips : "${natip}/32"])
  }
  external_pm4ml_whitelist = {
    for k, v in yamldecode(fileexists("${path.module}/ext-pm4ml-certs.yaml") ? file("${path.module}/ext-pm4ml-certs.yaml") : "{\"dummyfsp\": { \"nat_ips\":  \"127.0.0.1/32\" } }") :
    k => v.nat_ips
  }
}

resource "vault_generic_secret" "internal_pm4ml_whitelist" {
  path      = data.terraform_remote_state.k8s-base.outputs.pm4ml_whitelist_secret_name
  data_json = jsonencode(local.internal_pm4ml_whitelist)
}

resource "vault_generic_secret" "fsp_whitelist" {
  path      = data.terraform_remote_state.k8s-base.outputs.fsp_whitelist_secret_name
  data_json = jsonencode(local.external_pm4ml_whitelist)
}

resource "vault_generic_secret" "sim_whitelist" {
  path      = data.terraform_remote_state.k8s-base.outputs.sim_whitelist_secret_name
  data_json = jsonencode(local.sim_whitelist)
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
  depends_on = [vault_generic_secret.sim_whitelist, vault_generic_secret.fsp_whitelist, vault_generic_secret.internal_pm4ml_whitelist]
}