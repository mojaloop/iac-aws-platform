generate "provider" {
  path = "vault_provider.tf"
 
  if_exists = "overwrite_terragrunt"
 
  contents = <<EOF
provider "vault" {
  address = "https://vault.${dependency.baseinfra.outputs.public_subdomain}"
  token   = jsondecode("${local.common_vars.vault_token_location}/vault_seal_key"))["root_token"]
}
 
EOF
}