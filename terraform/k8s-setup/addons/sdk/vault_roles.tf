resource "vault_pki_secret_backend_role" "server" {
  backend            = vault_mount.pki_int.path
  name               = "server-${var.name}"
  allowed_domains    = [var.private_subdomain, trimsuffix(var.public_subdomain, ".")]
  allow_subdomains   = true
  allow_glob_domains = false
  allow_any_name     = false
  enforce_hostnames  = true
  allow_ip_sans      = true
  server_flag        = true
  client_flag        = false
  ou                 = ["Infrastructure Team"]
  organization       = ["Infra"]
  # 2 years
  max_ttl = 63113904
  # 30 days
  ttl      = 63113904
  no_store = true
}

resource "vault_pki_secret_backend_role" "client" {
  backend            = vault_mount.pki_int.path
  name               = "client-${var.name}"
  allowed_domains    = [var.private_subdomain, trimsuffix(var.public_subdomain, ".")]
  allow_subdomains   = true
  allow_glob_domains = false
  allow_bare_domains = true # needed for email address verification
  allow_any_name     = false
  enforce_hostnames  = true
  allow_ip_sans      = true
  server_flag        = false
  client_flag        = true
  ou                 = ["Infrastructure Team"]
  organization       = ["Infra"]
  # 2 years
  max_ttl = 63113904
  # 30 days
  ttl      = 63113904
  no_store = true
}
