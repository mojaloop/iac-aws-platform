
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

resource "kubernetes_secret" "secrets_tls_simulators" {
  for_each = toset(var.simulator_names)
  metadata {
    name      = "${each.value}-tls-sec"
    namespace = each.value
  }
  data = {
    "${each.value}_client.key"    = vault_pki_secret_backend_cert.switch-simulators-client[each.value].private_key
    "${each.value}_server.key"    = vault_pki_secret_backend_cert.simulators-server[each.value].private_key
    "${each.value}_server_ca.pem" = "${vault_pki_secret_backend_root_sign_intermediate.intermediate_simulators[each.value].issuing_ca}\n${vault_pki_secret_backend_root_sign_intermediate.intermediate_simulators[each.value].certificate}"
    "${each.value}_server.crt"    = vault_pki_secret_backend_cert.simulators-server[each.value].certificate
    "${each.value}_client.crt"    = vault_pki_secret_backend_cert.switch-simulators-client[each.value].certificate
    "switch_server_ca.pem"        = data.terraform_remote_state.k8s-base.outputs.root_signed_intermediate_ca_cert_chain
  }
  type       = "Opaque"
  provider   = kubernetes
  depends_on = [kubernetes_namespace.simulators, local_file.root_ca_switch_certificate, local_file.simulators_server_certificate, local_file.simulators_server_key, local_file.root_ca_switch_certificate_simulators, local_file.simulators_personal_client_certificate, local_file.switch_simulators_client_certificate, local_file.simulators_personal_client_key, local_file.switch_simulators_client_key, local_file.simulators_server_ca]
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
  source            = "git::git@github.com:mojaloop/iac-shared-modules.git//wso2/create-test-user?ref=v0.0.2"
  extgw_fqdn        = data.terraform_remote_state.infrastructure.outputs.extgw_public_fqdn
  test_user_details = local.sim_details
  admin_user        = "admin"
  admin_password    = local.wso2_admin_pw
}

module "provision_sim_callbacks_to_wso2" {
  source            = "git::git@github.com:mojaloop/iac-shared-modules.git//wso2/callbacks-post-config?ref=v0.0.2"
  intgw_fqdn        = data.terraform_remote_state.infrastructure.outputs.intgw_private_fqdn
  test_user_details = local.sim_details
  fspiop_version    = split(".", var.helm_mojaloop_version)[0] == "11" ? "1.1" : "1.0"
  user              = "admin"
  password          = local.wso2_admin_pw
}

resource "helm_release" "simulators" {
  for_each  = toset(var.simulator_names)
  name      = each.value
  chart     = "./sims_chart"
  namespace = each.value
  timeout   = 420

  values = [templatefile("templates/sims_values.yml.tpl", { name = each.value, INGRESS_ENABLED = "yes", INGRESS_HOST = "${each.value}.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")}" })]

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.secrets.jws.privKeySecretName"
    value = "${each.value}-jws-pvt-key"
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.secrets.jws.publicKeyConfigMapName"
    value = "${each.value}-jws-pub"
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.secrets.tlsSecretName"
    value = "${each.value}-tls-sec"
  }

  set_string {
    name  = "simulators.${each.value}.config.schemeAdapter.env.JWS_SIGN"
    value = "TRUE"
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.env.IN_CA_CERT_PATH"
    value = "/secrets/${each.value}_server_ca.pem"
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.env.IN_SERVER_CERT_PATH"
    value = "/secrets/${each.value}_server.crt"
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.env.IN_SERVER_KEY_PATH"
    value = "/secrets/${each.value}_server.key"
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.env.OUT_CA_CERT_PATH"
    value = "/secrets/switch_server_ca.pem"
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.env.OUT_CLIENT_CERT_PATH"
    value = "/secrets/${each.value}_client.crt"
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.env.OUT_CLIENT_KEY_PATH"
    value = "/secrets/${each.value}_client.key"
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.env.PEER_ENDPOINT"
    value = "extgw.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")}:8243/fsp/1.0"
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.env.DFSP_ID"
    value = each.value
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.env.ILP_SECRET"
    value = "Quaixohyaesahju3thivuiChai5cahng"
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.env.AUTO_ACCEPT_QUOTES"
    value = "true"
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.env.AUTO_ACCEPT_PARTY"
    value = "true"
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.env.USE_QUOTE_SOURCE_FSP_AS_TRANSFER_PAYEE_FSP"
    value = "true"
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.simBackend.env.DFSP_ID"
    value = each.value
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.env.INBOUND_MUTUAL_TLS_ENABLED"
    value = "false"
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.env.OUTBOUND_MUTUAL_TLS_ENABLED"
    value = "true"
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.env.VALIDATE_INBOUND_JWS"
    value = "false"
  }

  set {
    name  = "ingress.modernIngressController"
    value = true
  }

  set {
    name  = "ingress.modernIngressControllerRegex"
    value = "(/|$)(\\.*)"
  }

  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/rewrite-target"
    value = "/$2"

  }
  set {
    name  = "simulators.${each.value}.config.schemeAdapter.env.OAUTH_CLIENT_KEY"
    value = module.provision_sims_to_wso2.client-ids[each.value]
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.env.OAUTH_CLIENT_SECRET"
    value = module.provision_sims_to_wso2.client-secrets[each.value]
  }

  set {
    name  = "simulators.${each.value}.config.schemeAdapter.env.OAUTH_TOKEN_ENDPOINT"
    value = "https://${data.terraform_remote_state.infrastructure.outputs.iskm_private_fqdn}:9443/oauth2/token"
  }

  provider = helm

  depends_on = [module.provision_sims_to_wso2, kubernetes_namespace.simulators, kubernetes_secret.secrets_tls_simulators,
    kubernetes_secret.secrets_jws_privkey_simulators, kubernetes_config_map.jws_pub_simulators,
    local_file.root_ca_switch_certificate, local_file.simulators_server_certificate, local_file.simulators_server_key, local_file.root_ca_switch_certificate_simulators,
    local_file.simulators_personal_client_certificate, local_file.switch_simulators_client_certificate, local_file.simulators_personal_client_key,
  local_file.switch_simulators_client_key, local_file.simulators_server_ca]

}
resource "local_file" "mojaloop_backend_newman" {
  for_each = toset(var.simulator_names)
  content = templatefile("${path.module}/templates/provision_sim_to_backend.json.tpl", { sim_name = each.value,
    sim_currency = var.hub_currency_code,
    extgw_host   = data.terraform_remote_state.infrastructure.outputs.extgw_public_fqdn,
  intgw_host = data.terraform_remote_state.infrastructure.outputs.intgw_private_fqdn })
  filename   = "${path.root}/sim_tests/${each.value}-env.json"
  depends_on = [module.provision_sims_to_wso2, module.provision_accounts_to_wso2]
}

resource "local_file" "gp_postman_certlist_file" {
  content = templatefile("${path.module}/templates/sim_cert_list.json.tpl", {
    LAB_DOMAIN                     = trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, "."),
    PAYERFSP_KEY_FILENAME          = "../secrets_chart/payerfsp/tls/payerfsp_client.key"
    PAYEEFSP_KEY_FILENAME          = "../secrets_chart/payeefsp/tls/payeefsp_client.key"
    TESTFSP1_KEY_FILENAME          = "../secrets_chart/testfsp1/tls/testfsp1_client.key",
    TESTFSP2_KEY_FILENAME          = "../secrets_chart/testfsp2/tls/testfsp2_client.key",
    TESTFSP3_KEY_FILENAME          = "../secrets_chart/testfsp3/tls/testfsp3_client.key",
    TESTFSP4_KEY_FILENAME          = "../secrets_chart/testfsp4/tls/testfsp4_client.key",
    PM4MLSENDERFSP_KEY_FILENAME    = "../secrets_chart/pm4mlsenderfsp/tls/pm4mlsenderfsp_client.key",
    PM4MLRECEIVERFSP_KEY_FILENAME  = "../secrets_chart/pm4mlreceiverfsp/tls/pm4mlreceiverfsp_client.key",
    PAYERFSP_CERT_FILENAME         = "../secrets_chart/payerfsp/tls/payerfsp_client.crt",
    PAYEEFSP_CERT_FILENAME         = "../secrets_chart/payeefsp/tls/payeefsp_client.crt",
    TESTFSP1_CERT_FILENAME         = "../secrets_chart/testfsp1/tls/testfsp1_client.crt",
    TESTFSP2_CERT_FILENAME         = "../secrets_chart/testfsp2/tls/testfsp2_client.crt",
    TESTFSP3_CERT_FILENAME         = "../secrets_chart/testfsp3/tls/testfsp3_client.crt",
    TESTFSP4_CERT_FILENAME         = "../secrets_chart/testfsp4/tls/testfsp4_client.crt",
    PM4MLSENDERFSP_CERT_FILENAME   = "../secrets_chart/pm4mlsenderfsp/tls/pm4mlsenderfsp_client.crt",
    PM4MLRECEIVERFSP_CERT_FILENAME = "../secrets_chart/pm4mlreceiverfsp/tls/pm4mlreceiverfsp_client.crt",
  })
  filename   = "${path.root}/sim_tests/sim_cert_list.json"
  depends_on = [module.provision_sims_to_wso2, module.provision_accounts_to_wso2]
}

resource "local_file" "gp_postman_environment_file" {
  content = templatefile("${path.module}/templates/Lab.postman_environment.json.tpl", {
    LAB_DOMAIN                         = trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, "."),
    CURRENCY_CODE                      = var.hub_currency_code,
    HUB_OPERATOR_CONSUMER_KEY          = module.provision_accounts_to_wso2.client-ids["hub_operator"],
    HUB_OPERATOR_CONSUMER_SECRET       = module.provision_accounts_to_wso2.client-secrets["hub_operator"],
    NORESPONSEPAYEEFSP_CONSUMER_KEY    = module.provision_accounts_to_wso2.client-ids["noresponsepayeefsp"],
    NORESPONSEPAYEEFSP_CONSUMER_SECRET = module.provision_accounts_to_wso2.client-secrets["noresponsepayeefsp"],
    PAYERFSP_CONSUMER_KEY              = module.provision_sims_to_wso2.client-ids["payerfsp"],
    PAYEEFSP_CONSUMER_KEY              = module.provision_sims_to_wso2.client-ids["payeefsp"],
    TESTFSP1_CONSUMER_KEY              = module.provision_sims_to_wso2.client-ids["testfsp1"],
    TESTFSP2_CONSUMER_KEY              = module.provision_sims_to_wso2.client-ids["testfsp2"],
    TESTFSP3_CONSUMER_KEY              = module.provision_sims_to_wso2.client-ids["testfsp3"],
    TESTFSP4_CONSUMER_KEY              = module.provision_sims_to_wso2.client-ids["testfsp4"],
    PM4MLSENDERFSP_CONSUMER_KEY        = module.provision_sims_to_wso2.client-ids["pm4mlsenderfsp"],
    PM4MLRECEIVERFSP_CONSUMER_KEY      = module.provision_sims_to_wso2.client-ids["pm4mlreceiverfsp"],
    PAYERFSP_CONSUMER_SECRET           = module.provision_sims_to_wso2.client-secrets["payerfsp"],
    PAYEEFSP_CONSUMER_SECRET           = module.provision_sims_to_wso2.client-secrets["payeefsp"],
    TESTFSP1_CONSUMER_SECRET           = module.provision_sims_to_wso2.client-secrets["testfsp1"],
    TESTFSP2_CONSUMER_SECRET           = module.provision_sims_to_wso2.client-secrets["testfsp2"],
    TESTFSP3_CONSUMER_SECRET           = module.provision_sims_to_wso2.client-secrets["testfsp3"],
    TESTFSP4_CONSUMER_SECRET           = module.provision_sims_to_wso2.client-secrets["testfsp4"],
    PM4MLSENDERFSP_CONSUMER_SECRET     = module.provision_sims_to_wso2.client-secrets["pm4mlsenderfsp"],
    PM4MLRECEIVERFSP_CONSUMER_SECRET   = module.provision_sims_to_wso2.client-secrets["pm4mlreceiverfsp"],
    payerfspJWSKey                     = replace(tls_private_key.simulators["payerfsp"].private_key_pem, "\n", "\\n"),
    payeefspJWSKey                     = replace(tls_private_key.simulators["payeefsp"].private_key_pem, "\n", "\\n"),
    testfsp1JWSKey                     = replace(tls_private_key.simulators["testfsp1"].private_key_pem, "\n", "\\n"),
    testfsp2JWSKey                     = replace(tls_private_key.simulators["testfsp2"].private_key_pem, "\n", "\\n"),
    testfsp3JWSKey                     = replace(tls_private_key.simulators["testfsp3"].private_key_pem, "\n", "\\n"),
    testfsp4JWSKey                     = replace(tls_private_key.simulators["testfsp4"].private_key_pem, "\n", "\\n"),
    pm4mlsenderfspJWSKey               = replace(tls_private_key.simulators["pm4mlsenderfsp"].private_key_pem, "\n", "\\n"),
    pm4mlreceiverfspJWSKey             = replace(tls_private_key.simulators["pm4mlreceiverfsp"].private_key_pem, "\n", "\\n")
  })
  filename   = "${path.root}/sim_tests/Lab.postman_environment.json"
  depends_on = [module.provision_sims_to_wso2, module.provision_accounts_to_wso2]
}

resource "local_file" "token_env_file" {
  content = templatefile("${path.module}/templates/provision_to_backend.sh.tpl", {
    token_endpoint   = "https://${data.terraform_remote_state.infrastructure.outputs.extgw_public_fqdn}:8243/token",
    hub_op_cons_auth = module.provision_accounts_to_wso2.client-basic-auth-headers["hub_operator"]
  })
  filename = "${path.root}/sim_tests/provision_to_backend.sh"
}

resource "kubernetes_job" "sim_post_install" {
  for_each = toset(var.simulator_names)

  metadata {
    name      = each.value
    namespace = each.value
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "sim-post-install"
          image   = "alpine"
          command = ["/bin/sh", "-c", "apk add git curl && git clone -b ${var.iac_post_init_version} https://github.com/mojaloop/iac_post_deploy.git && cd iac_post_deploy/sims-post-setup && export SIM_NAME=${each.value} && sh post_deploy_setup.sh"]
        }
        restart_policy = "Never"
      }
    }
    #ttl_seconds_after_finished = 60
    backoff_limit = 4
  }
  provider   = kubernetes
  depends_on = [helm_release.simulators]
}
