locals {
  tenant  = data.terraform_remote_state.tenant.outputs
  hub_ips = [for block in var.hub_account_cidr_blocks : "${block},${local.tenant.wireguard_public_ip}/32,${local.tenant.wireguard_private_ip}/32,${local.tenant.natgw_public_ip}/32,${local.tenant.gitlab_ci_public_ip}/32"]
}

resource "vault_generic_secret" "tenant_whitelist" {
  path      = var.sim_whitelist_secret_name
  data_json = jsonencode(zipmap(var.hub_account_names, local.hub_ips))
}