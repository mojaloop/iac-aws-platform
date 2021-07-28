# This will be moved to its own set of files
resource "vault_pki_secret_backend_role" "role-server-cert-simulators" {
  for_each           = toset(var.simulator_names)
  backend            = vault_mount.pki_int_simulators[each.value].path
  name               = "server-cert-role-${each.value}"
  allowed_domains    = [data.terraform_remote_state.infrastructure.outputs.private_subdomain, trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")]
  allow_subdomains   = true
  allow_glob_domains = false
  allow_any_name     = false
  enforce_hostnames  = true
  allow_ip_sans      = true
  server_flag        = true
  client_flag        = false
  ou                 = ["Infrastructure Team"]
  organization       = ["ModusBox"]
  # 2 years
  max_ttl = 63113904
  # 30 days
  ttl      = 63113904
  no_store = true
}

resource "vault_pki_secret_backend_role" "role-client-cert-simulators" {
  for_each           = toset(var.simulator_names)
  backend            = vault_mount.pki_int_simulators[each.value].path
  name               = "client-cert-role-${each.value}"
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
  organization       = ["ModusBox"]
  # 2 years
  max_ttl = 63113904
  # 30 days
  ttl      = 63113904
  no_store = true
}
