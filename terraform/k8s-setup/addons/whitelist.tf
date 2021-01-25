locals {
  tenant  = data.terraform_remote_state.tenant.outputs
  sim_ips = [for block in var.simulator_cidr_blocks : "${block},${local.tenant.wireguard_public_ip}/32,${local.tenant.wireguard_private_ip}/32,${data.aws_nat_gateway.default.public_ip}/32,${local.tenant.gitlab_ci_public_ip}/32"]
  hub_ips = [for block in var.hub_account_cidr_blocks : "${block},${local.tenant.wireguard_public_ip}/32,${local.tenant.wireguard_private_ip}/32,${data.aws_nat_gateway.default.public_ip}/32,${local.tenant.gitlab_ci_public_ip}/32"]
  # TODO: the problem is this remote state only exists if an SDK VM has been created
  sdk_ips           = [for ip in jsondecode(data.terraform_remote_state.sdk.outputs.publicIPs) : "${ip}/32"]
  sdk_whitelist_map = { for sdk in var.sdks : sdk.name => local.sdk_ips }
}

data "aws_nat_gateway" "default" {
  vpc_id = data.terraform_remote_state.tenant.outputs.vpc_id
}

resource "vault_generic_secret" "sim_whitelist" {
  path      = data.terraform_remote_state.k8s-base.outputs.sim_whitelist_secret_name
  data_json = jsonencode(merge(zipmap(var.simulator_names, local.sim_ips), zipmap(var.hub_account_names, local.hub_ips), local.sdk_whitelist_map))
}
