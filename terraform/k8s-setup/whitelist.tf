locals {
  tenant = data.terraform_remote_state.tenant.outputs
  env    = data.terraform_remote_state.infrastructure.outputs
}

data "aws_nat_gateway" "default" {
  vpc_id = data.terraform_remote_state.tenant.outputs.vpc_id
}

resource "vault_generic_secret" "whitelist_vpn" {
  path = "${var.whitelist_secret_name_prefix}_vpn"

  data_json = jsonencode({
    "wireguard-private" = local.tenant.wireguard_private_ip
    "wireguard-public"  = local.tenant.wireguard_public_ip
  })
}

resource "vault_generic_secret" "whitelist_nat" {
  path = "${var.whitelist_secret_name_prefix}_nat"

  data_json = jsonencode({
    "public_ip"  = data.aws_nat_gateway.default.public_ip
    "private_ip" = data.aws_nat_gateway.default.private_ip
  })
}
resource "vault_generic_secret" "whitelist_fsp" {
  path = "${var.whitelist_secret_name_prefix}_fsp"

  data_json = jsonencode({ "dummy_fsp" : "127.0.0.1,127.0.0.2" })
}

resource "vault_generic_secret" "whitelist_sims" {
  path = "${var.whitelist_secret_name_prefix}_sims"

  data_json = jsonencode({ "dummy_fsp" : "127.0.0.1,127.0.0.2" })
}

resource "vault_generic_secret" "whitelist_support_services" {
  path = "${var.whitelist_secret_name_prefix}_support_services"

  data_json = jsonencode({
    "k8s-workernodes" = join(",", local.env.support_services_k8s_worker_nodes_private_ip)
    "gitlab"          = local.tenant.gitlab_ci_private_ip
    "gitlab_public"   = local.tenant.gitlab_ci_public_ip
  })
}
resource "vault_generic_secret" "whitelist_addons" {
  path = "${var.whitelist_secret_name_prefix}_addons"

  data_json = jsonencode({
    "k8s-workernodes" = join(",", local.env.addons_k8s_worker_nodes_private_ip)
  })
}
resource "vault_generic_secret" "whitelist_mojaloop" {
  path = "${var.whitelist_secret_name_prefix}_mojaloop"

  data_json = jsonencode({
    "k8s-workernodes" = join(",", local.env.mojaloop_k8s_worker_nodes_private_ip)
  })
}
resource "vault_generic_secret" "whitelist_gateway" {
  path = "${var.whitelist_secret_name_prefix}_gateway"

  data_json = jsonencode({
    "k8s-workernodes" = join(",", local.env.mojaloop_k8s_worker_nodes_private_ip)
  })
}
resource "vault_generic_secret" "whitelist_mcm" {
  path = "${var.whitelist_secret_name_prefix}_mcm"

  data_json = jsonencode({
    "users" = join(",", length(var.whitelist_mcm) > 0 ? var.whitelist_mcm : ["0.0.0.0/0"])
  })
}
