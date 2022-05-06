resource "local_file" "gp_postman_pm4ml_certlist_file" {
  content = templatefile("${path.module}/templates/test_cert_list.json.tpl", {
    LAB_DOMAIN                     = var.public_subdomain,
    PM4ML_DOMAIN                = "${replace(var.client, "-", "")}${replace(var.environment, "-", "")}k3s.${var.public_subdomain}",
    DFSP1_KEY_FILENAME          = "../secrets_chart/pm4mlsenderfsp/tls/pm4mlsenderfsp_client.key",
    DFSP2_KEY_FILENAME          = "../secrets_chart/pm4mlreceiverfsp/tls/pm4mlreceiverfsp_client.key",
    DEMOWALLET_KEY_FILENAME     = "../secrets_chart/demowallet/tls/demowallet_client.key",
    DEMOMFI_KEY_FILENAME        = "../secrets_chart/demomfi/tls/demomfi_client.key",
    DFSP1_CERT_FILENAME         = "../secrets_chart/pm4mlsenderfsp/tls/pm4mlsenderfsp_client.crt",
    DFSP2_CERT_FILENAME         = "../secrets_chart/pm4mlreceiverfsp/tls/pm4mlreceiverfsp_client.crt",
    DEMOWALLET_CERT_FILENAME    = "../secrets_chart/demowallet/tls/demowallet_client.crt",
    DEMOMFI_CERT_FILENAME       = "../secrets_chart/demomfi/tls/demomfi_client.crt"
  })
  filename   = "${path.root}/sim_tests/test_cert_list.json"
}

resource "local_file" "gp_postman_environment_file" {
  content = templatefile("${path.module}/templates/Lab.postman_environment.json.tpl", {
    LAB_DOMAIN                         = var.public_subdomain,
    CURRENCY_CODE                      = var.hub_currency_code,
    HUB_OPERATOR_CONSUMER_KEY          = module.provision_accounts_to_wso2.client-ids["hub_operator"],
    HUB_OPERATOR_CONSUMER_SECRET       = module.provision_accounts_to_wso2.client-secrets["hub_operator"],
    NORESPONSEPAYEEFSP_CONSUMER_KEY    = "noresponsepayeefsp",
    NORESPONSEPAYEEFSP_CONSUMER_SECRET = "noresponsepayeefsp",
    PAYERFSP_CONSUMER_KEY              = "payerfsp",
    PAYEEFSP_CONSUMER_KEY              = "payeefsp",
    TESTFSP1_CONSUMER_KEY              = "testfsp1",
    TESTFSP2_CONSUMER_KEY              = "testfsp2",
    TESTFSP3_CONSUMER_KEY              = "testfsp3",
    TESTFSP4_CONSUMER_KEY              = "testfsp4",
    PAYERFSP_CONSUMER_SECRET           = "payerfsp",
    PAYEEFSP_CONSUMER_SECRET           = "payeefsp",
    TESTFSP1_CONSUMER_SECRET           = "testfsp1",
    TESTFSP2_CONSUMER_SECRET           = "testfsp2",
    TESTFSP3_CONSUMER_SECRET           = "testfsp3",
    TESTFSP4_CONSUMER_SECRET           = "testfsp4",
    payerfspJWSKey                     = "payerfsp",
    payeefspJWSKey                     = "payeefsp",
    testfsp1JWSKey                     = "testfsp1",
    testfsp2JWSKey                     = "testfsp2",
    testfsp3JWSKey                     = "testfsp3",
    testfsp4JWSKey                     = "testfsp4",
    MERCHANT_ORACLE_ENDPOINT           = "http://moja-simulator.${var.private_subdomain}/oracle",
    ALIAS_ORACLE_ENDPOINT              = "http://${var.alias-oracle-fqdn}/als-api",
    ALIAS_ORACLE_ADMIN_API_ENDPOINT    = "http://${var.alias-oracle-fqdn}/admin-api",
    ACCOUNT_ORACLE_ENDPOINT            = "http://${var.mfi-account-oracle-fqdn}/als-api",
    ACCOUNT_ORACLE_ADMIN_API_ENDPOINT  = "http://${var.mfi-account-oracle-fqdn}/admin-api",
    P2P_ORACLE_ENDPOINT                = "http://${var.mfi-p2p-oracle-fqdn}/als-api",
    P2P_ORACLE_ADMIN_API_ENDPOINT      = "http://${var.mfi-p2p-oracle-fqdn}/admin-api",
    PM4ML_DOMAIN                       = "${replace(var.client, "-", "")}${replace(var.environment, "-", "")}k3s.${var.public_subdomain}",
    MOJALOOP_RELEASE                   = var.helm_mojaloop_release_name
    MCM_FQDN                           = var.mcm_fqdn
  })
  filename   = "${path.root}/sim_tests/Lab.postman_environment.json"
  depends_on = [module.provision_accounts_to_wso2]
}