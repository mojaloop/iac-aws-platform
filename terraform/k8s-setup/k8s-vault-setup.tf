locals {
  vault_addr = "http://vault.${data.terraform_remote_state.infrastructure.outputs.private_subdomain}"
}

provider "vault" {
  address = local.vault_addr
  token   = jsondecode(file("${var.project_root_path}/vault_seal_key"))["root_token"]
}

resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "callback-haproxy" {
  backend        = vault_auth_backend.approle.path
  role_name      = "callback-haproxy-role"
  token_ttl      = 3600
  policies = [vault_policy.read-onboarding-details.name]
}

resource "vault_approle_auth_backend_role_secret_id" "callback-haproxy-secret-id" {
  backend   = "${vault_auth_backend.approle.path}"
  role_name = "${vault_approle_auth_backend_role.callback-haproxy.role_name}"
}

resource "vault_policy" "read-onboarding-details" {
  name = "read-onboarding-details"

  policy = <<EOT
path "${var.onboarding_secret_name_prefix}*" {
  capabilities = ["read", "list"]
}
EOT
}