provider "vault" {
  address = "http://vault.${data.terraform_remote_state.infrastructure.outputs.private_subdomain}"
  token   = jsondecode(file("${var.project_root_path}/vault_seal_key"))["root_token"]
}