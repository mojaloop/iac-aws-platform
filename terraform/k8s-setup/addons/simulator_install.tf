
resource "kubernetes_namespace" "simulators" {
  for_each = toset(var.simulator_names)
  metadata {
    annotations = {
      name = each.value
    }
    name = each.value
  }
  provider = kubernetes
}

resource "kubernetes_secret" "secrets_jws_privkey_simulators" {
  for_each = toset(var.simulator_names)
  metadata {
    name      = "${each.value}-jws-pvt-key"
    namespace = each.value
  }
  data = {
    "private.key" = tls_private_key.simulators[each.value].private_key_pem
  }
  type       = "Opaque"
  provider   = kubernetes
  depends_on = [kubernetes_namespace.simulators]
}

resource "kubernetes_config_map" "jws_pub_simulators" {
  for_each = toset(var.simulator_names)
  metadata {
    name      = "${each.value}-jws-pub"
    namespace = each.value
  }
  data       = local.jws_pub
  provider   = kubernetes
  depends_on = [kubernetes_namespace.simulators]
}

locals {
  sim_details = {
    for sim_name in var.simulator_names :
    sim_name => {
      sim_name              = sim_name
      sim_password          = "${sim_name}123"
      sim_callback_url      = "https://${data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_fqdn}/sim/${sim_name}/inbound"
      subscribe_to_api_list = "FSPIOP"
    }
  }
}

module "provision_sims_to_wso2" {
  source            = "git::https://github.com/mojaloop/iac-shared-modules.git//wso2/create-test-user?ref=v1.0.22"
  extgw_fqdn        = data.terraform_remote_state.infrastructure.outputs.extgw_public_fqdn
  test_user_details = local.sim_details
  admin_user        = "admin"
  admin_password    = local.wso2_admin_pw
}

module "provision_sim_callbacks_to_wso2" {
  source            = "git::https://github.com/mojaloop/iac-shared-modules.git//wso2/callbacks-post-config?ref=v1.0.22"
  intgw_fqdn        = data.terraform_remote_state.infrastructure.outputs.intgw_private_fqdn
  test_user_details = local.sim_details
  fspiop_version    = split(".", var.helm_mojaloop_version)[0] == "10" ? "1.0" : "1.1"
  user              = "admin"
  password          = local.wso2_admin_pw
}

resource "helm_release" "simulators" {
  for_each  = toset(var.simulator_names)
  name       = each.value
  repository = "http://mojaloop.io/helm/repo"
  chart      = "mojaloop-simulator"
  version    = var.helm_mojaloop_simulator_version
  namespace  = each.value
  timeout    = 420
  create_namespace = true

  values = [templatefile("templates/sims_values.yml.tpl", { 
    name = each.value, 
    INGRESS_ENABLED = "yes", 
    INGRESS_HOST = "${each.value}.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")}" ,
    SIM_BACKEND_SERVICE_NAME = "${each.value}-sim-${each.value}-backend",
    SIM_CACHE_SERVICE_NAME = "${each.value}-sim-${each.value}-cache",
    SIM_SCHEME_ADAPTER_SERVICE_NAME = "${each.value}-sim-${each.value}-scheme-adapter",
    PRIV_KEY_SECRET_NAME = "${each.value}-jws-pvt-key",
    PUBLIC_KEY_CONFIG_MAP_NAME = "${each.value}-jws-pub",
    PEER_ENDPOINT = "extgw.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")}:8243/fsp/1.0",
    OAUTH_CLIENT_KEY = module.provision_sims_to_wso2.client-ids[each.value],
    OAUTH_CLIENT_SECRET = module.provision_sims_to_wso2.client-secrets[each.value],
    OAUTH_TOKEN_ENDPOINT = "https://${data.terraform_remote_state.infrastructure.outputs.iskm_private_fqdn}:9443/oauth2/token"})]

  provider = helm

  depends_on = [module.provision_sims_to_wso2, kubernetes_namespace.simulators,
    kubernetes_secret.secrets_jws_privkey_simulators, kubernetes_config_map.jws_pub_simulators,
    local_file.root_ca_switch_certificate, local_file.simulators_server_certificate, local_file.simulators_server_key, local_file.root_ca_switch_certificate_simulators,
    local_file.simulators_personal_client_certificate, local_file.switch_simulators_client_certificate, local_file.simulators_personal_client_key,
  local_file.switch_simulators_client_key, local_file.simulators_server_ca]

}
data "kubernetes_secret" "sim-client-certs" {
  for_each  = toset(var.simulator_names)
  metadata {
    name      = {{ each.value }}-clientcert-tls
    namespace = each.value
  }
  provider   = kubernetes
  depends_on = [helm_release.simulators]
}