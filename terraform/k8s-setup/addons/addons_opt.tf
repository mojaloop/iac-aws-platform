module "sdk" {
  source              = "./sdk"
  for_each            = { for sdk in var.sdks : sdk.name => sdk }
  name                = each.value.name
  haproxy_callback_ip = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
  public_subdomain    = data.terraform_remote_state.infrastructure.outputs.public_subdomain
  private_subdomain   = data.terraform_remote_state.infrastructure.outputs.private_subdomain

  ca_cert_cert_pem                     = data.terraform_remote_state.k8s-base.outputs.ca_cert_cert_pem
  vault_root_path                      = data.terraform_remote_state.k8s-base.outputs.vault_root_path
  root_signed_intermediate_certificate = data.terraform_remote_state.k8s-base.outputs.root_signed_intermediate_certificate
  project_root_path                    = var.project_root_path
  haproxy_callback_private_ip          = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
  extgw_fqdn                           = data.terraform_remote_state.infrastructure.outputs.extgw_public_fqdn
  intgw_fqdn                           = data.terraform_remote_state.infrastructure.outputs.intgw_private_fqdn
  helm_mojaloop_version                = var.helm_mojaloop_version

  jws_pub_key_data = local.jws_pub
  providers = {
    external   = external.v1_2_0
    kubernetes = kubernetes
    helm       = helm
  }
}
