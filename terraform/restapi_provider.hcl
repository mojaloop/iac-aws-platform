generate "provider" {
  path = "restapi_provider.tf"
 
  if_exists = "overwrite_terragrunt"
 
  contents = <<EOF
provider "restapi" {
  alias                = "restapi_mcm"
  uri                  = "https://${var.mcm_name}.${dependency.baseinfra.outputs.public_subdomain}"
  debug                = true
  write_returns_object = false
  create_returns_object = true

  oauth_client_credentials {
    oauth_client_id = dependency.supportsvcs.outputs.mcm_portal_client_id
    oauth_client_secret = dependency.supportsvcs.outputs.mcm_portal_client_secret
    oauth_token_endpoint = "https://iskm.${dependency.baseinfra.outputs.public_subdomain}:443/oauth2/token"
    oauth_scopes = ["openid"]
  }
}
 
EOF
}